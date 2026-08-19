import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:jose/jose.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_core/sei_core.dart';

/// Carrega o par de chaves RSA do provider OIDC e emite/verifica os tokens
/// assinados com RS256: `id_token`, `access_token` e o `jwks`/`discovery
/// document` publicados nos endpoints públicos da especificação.
///
/// Assinatura assimétrica (diferente do JWT de sessão do login local, que é
/// HS256 simétrico em `AutenticacaoTokenService`): um provider OIDC precisa
/// que qualquer Relying Party valide o token sem conhecer um segredo
/// compartilhado — só a chave pública publicada em `GET /oauth2/jwks`.
class OidcService {
  OidcService(this._config) {
    _chavePrivada = _carregarChave(_config.oidcChavePrivadaCaminho);
    _chavePublica = _carregarChave(_config.oidcChavePublicaCaminho);
  }

  final SeiAppConfig _config;
  late final JsonWebKey _chavePrivada;
  late final JsonWebKey _chavePublica;

  /// Algoritmo de assinatura fixo do provider — as chaves são sempre RSA
  /// 2048, geradas por `backend/scripts/gera_chave_oidc.dart`.
  static const String algoritmo = 'RS256';

  JsonWebKey _carregarChave(String caminho) {
    final File arquivo = File(caminho);
    if (!arquivo.existsSync()) {
      throw StateError(
        'Chave do provider OIDC não encontrada em "$caminho". Rode '
        '"dart run backend/scripts/gera_chave_oidc.dart" a partir da raiz '
        'do backend para gerar o par de chaves de desenvolvimento antes de '
        'iniciar o servidor ou os testes.',
      );
    }
    final Map<String, dynamic> jwk =
        jsonDecode(arquivo.readAsStringSync()) as Map<String, dynamic>;
    return JsonWebKey.fromJson(jwk);
  }

  /// Conjunto de chaves públicas publicado em `GET /oauth2/jwks`.
  JsonWebKeySet get jwks => JsonWebKeySet.fromKeys(<JsonWebKey>[_chavePublica]);

  /// Documento de descoberta publicado em
  /// `GET /.well-known/openid-configuration`.
  Map<String, dynamic> get discoveryDocument {
    final String issuer = _config.oidcIssuerUrl;
    return <String, dynamic>{
      'issuer': issuer,
      'authorization_endpoint': '$issuer/oauth2/authorize',
      'token_endpoint': '$issuer/oauth2/token',
      'userinfo_endpoint': '$issuer/oauth2/userinfo',
      'jwks_uri': '$issuer/oauth2/jwks',
      'end_session_endpoint': '$issuer/oauth2/logout',
      'response_types_supported': const <String>['code'],
      'subject_types_supported': const <String>['public'],
      'id_token_signing_alg_values_supported': const <String>[algoritmo],
      'scopes_supported': const <String>['openid', 'profile', 'offline_access'],
      'token_endpoint_auth_methods_supported': const <String>[
        'none',
        'client_secret_post',
      ],
      'claims_supported': const <String>[
        'sub',
        'iss',
        'aud',
        'exp',
        'iat',
        'auth_time',
        'nonce',
        'name',
        'preferred_username',
      ],
      'code_challenge_methods_supported': const <String>['S256'],
      'grant_types_supported': const <String>[
        'authorization_code',
        'refresh_token',
      ],
    };
  }

  /// Emite o `id_token` do fluxo `authorization_code`.
  ///
  /// Claims deliberadamente enxutas nesta rodada: nenhuma informação de
  /// unidade/órgão é incluída (ver decisão registrada no roteiro mestre).
  /// Quando o escopo concedido inclui `profile`, inclui `name` e
  /// `preferred_username` a partir de [usuario] — resolvido pelo controller
  /// via `UsuarioRepository.buscarPorId` no momento da troca do código.
  String criarIdToken({
    required int idUsuario,
    required OidcCliente cliente,
    required List<String> escopos,
    required DateTime authTime,
    String? nonce,
    Usuario? usuario,
  }) {
    final DateTime agora = DateTime.now();
    final DateTime expiracao = agora.add(_config.oidcIdTokenDuracao);

    final Map<String, dynamic> claims = <String, dynamic>{
      'iss': _config.oidcIssuerUrl,
      'sub': idUsuario.toString(),
      'aud': cliente.idCliente,
      'iat': agora.millisecondsSinceEpoch ~/ 1000,
      'exp': expiracao.millisecondsSinceEpoch ~/ 1000,
      'auth_time': authTime.millisecondsSinceEpoch ~/ 1000,
      if (nonce != null) 'nonce': nonce,
      if (escopos.contains('profile') && usuario != null) ...<String, dynamic>{
        'name': usuario.nome,
        'preferred_username': usuario.sigla,
      },
    };

    return _assinar(claims);
  }

  /// Emite o `access_token` — usado para chamar `GET /oauth2/userinfo` e,
  /// no futuro, outras APIs de recurso que confiarem neste provider.
  ///
  /// Não embute claims de perfil: `GET /oauth2/userinfo` busca o usuário na
  /// hora (dado fresco), em vez de repetir um retrato estático do momento
  /// da emissão.
  String criarAccessToken({
    required int idUsuario,
    required OidcCliente cliente,
    required List<String> escopos,
  }) {
    final DateTime agora = DateTime.now();
    final DateTime expiracao = agora.add(_config.oidcAccessTokenDuracao);

    final Map<String, dynamic> claims = <String, dynamic>{
      'iss': _config.oidcIssuerUrl,
      'sub': idUsuario.toString(),
      'aud': cliente.idCliente,
      'iat': agora.millisecondsSinceEpoch ~/ 1000,
      'exp': expiracao.millisecondsSinceEpoch ~/ 1000,
      'client_id': cliente.idCliente,
      'scope': escopos.join(' '),
      // Identificador único por emissão (RFC 7519 §4.1.7) — sem ele, dois
      // access tokens emitidos no mesmo segundo para o mesmo usuário/
      // cliente/escopo (ex.: token original e o da renovação) teriam
      // exatamente as mesmas claims e, por assinatura determinística,
      // seriam a mesma string. O `jti` também é o que dá rastreabilidade a
      // um token específico em auditoria futura.
      'jti': _gerarJti(),
    };

    return _assinar(claims);
  }

  String _gerarJti() {
    final Random aleatorio = Random.secure();
    final List<int> valores =
        List<int>.generate(16, (int _) => aleatorio.nextInt(256));
    return base64Url.encode(valores).replaceAll('=', '');
  }

  String _assinar(Map<String, dynamic> claims) {
    final JsonWebSignatureBuilder builder = JsonWebSignatureBuilder()
      ..jsonContent = claims
      ..addRecipient(_chavePrivada, algorithm: algoritmo);
    return builder.build().toCompactSerialization();
  }

  /// Verifica assinatura e expiração de um token assinado por este
  /// provider — serve tanto para `access_token` (em `GET /oauth2/userinfo`)
  /// quanto para `id_token` usado como `id_token_hint` (em
  /// `GET /oauth2/logout`), já que os dois são JWT RS256 com a mesma chave
  /// e o mesmo formato de `iss`/`exp`.
  ///
  /// Retorna as claims em caso de sucesso, ou `null` quando o token é
  /// inválido, foi adulterado, está expirado ou não foi emitido por este
  /// `issuer`. Nunca lança exceção: quem chama trata `null` como "não
  /// autenticado" (mesmo contrato de `AutenticacaoTokenService.verificar`).
  Future<Map<String, dynamic>?> verificarTokenAssinado(String token) async {
    try {
      final JsonWebKeyStore keyStore = JsonWebKeyStore()..addKey(_chavePublica);
      final JsonWebToken jwt = await JsonWebToken.decodeAndVerify(
        token,
        keyStore,
        allowedArguments: <String>[algoritmo],
      );

      final DateTime? expiracao = jwt.claims.expiry;
      if (expiracao == null || DateTime.now().isAfter(expiracao)) {
        return null;
      }
      final Map<String, dynamic> claims = jwt.claims.toJson();
      if (claims['iss'] != _config.oidcIssuerUrl) {
        return null;
      }
      return claims;
    } catch (_) {
      return null;
    }
  }
}
