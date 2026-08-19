import 'dart:convert';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:crypto/crypto.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_backend/src/modules/oidc/models/oidc_pendencia_autorizacao.dart';
import 'package:sei_backend/src/modules/oidc/repositories/oidc_cliente_repository.dart';
import 'package:sei_backend/src/modules/oidc/repositories/oidc_codigo_autorizacao_repository.dart';
import 'package:sei_backend/src/modules/oidc/repositories/oidc_token_renovacao_repository.dart';
import 'package:sei_backend/src/modules/oidc/services/oidc_service.dart';
import 'package:sei_backend/src/modules/usuarios/repositories/usuario_repository.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Endpoints do provider OpenID Connect do SEI: descoberta, chaves
/// públicas, autorização, token, userinfo e logout.
///
/// O SEI em Dart passa a atuar como Identity Provider (IdP) para os
/// sistemas clientes de uma instituição — o mesmo papel que o SIP
/// desempenha no SEI verdadeiro como serviço de autorização compartilhado
/// por múltiplos sistemas. O frontend AngularDart do SEI é o primeiro
/// Relying Party registrado (ver `backend/scripts/migrations/`).
class OidcController {
  /// Chave usada para guardar a [OidcPendenciaAutorizacao] na sessão HTTP
  /// entre `GET /oauth2/authorize` e `POST /login`.
  static const String chaveSessaoPendencia = 'oidc_pendencia_autorizacao';

  static const String _prefixoBearer = 'Bearer ';

  Future<void> discovery(
      RequestContext request, ResponseContext response) async {
    final OidcService servico = request.make<OidcService>();
    await response.json(servico.discoveryDocument);
  }

  Future<void> jwks(RequestContext request, ResponseContext response) async {
    final OidcService servico = request.make<OidcService>();
    await response.json(servico.jwks.toJson());
  }

  /// `GET /oauth2/authorize`: valida `client_id`/`redirect_uri`, negocia os
  /// escopos concedidos contra `oidc_cliente.escopos_permitidos`, guarda a
  /// requisição pendente na sessão e redireciona para a página de login.
  Future<void> authorize(
      RequestContext request, ResponseContext response) async {
    final Map<String, String> query =
        request.uri?.queryParameters ?? const <String, String>{};

    final String? idCliente = _valorOuNulo(query['client_id']);
    final String? uriRedirecionamento = _valorOuNulo(query['redirect_uri']);
    if (idCliente == null || uriRedirecionamento == null) {
      return _erro(response, 400, 'client_id e redirect_uri são obrigatórios.');
    }

    final OidcClienteRepository clienteRepositorio =
        request.make<OidcClienteRepository>();
    final OidcCliente? cliente =
        await clienteRepositorio.buscarAtivoPorId(idCliente);
    if (cliente == null) {
      return _erro(response, 400, 'Cliente OIDC desconhecido ou inativo.');
    }
    if (!cliente.urisRedirecionamento.contains(uriRedirecionamento)) {
      return _erro(
          response, 400, 'redirect_uri não cadastrada para este cliente.');
    }

    final String? responseType = query['response_type'];
    if (responseType != 'code') {
      return _erro(response, 400, 'Apenas response_type "code" é suportado.');
    }

    final List<String> escoposSolicitados = (query['scope'] ?? 'openid')
        .split(' ')
        .map((String escopo) => escopo.trim())
        .where((String escopo) => escopo.isNotEmpty)
        .toList(growable: false);
    final List<String> escoposConcedidos = escoposSolicitados
        .where(cliente.escoposPermitidos.contains)
        .toList(growable: false);
    if (!escoposConcedidos.contains('openid')) {
      return _erro(
        response,
        400,
        'O escopo "openid" precisa ser solicitado e estar entre os escopos '
        'permitidos do cliente.',
      );
    }

    final String? codeChallengeMethod = query['code_challenge_method'];
    if (codeChallengeMethod != null && codeChallengeMethod != 'S256') {
      return _erro(response, 400, 'Só o método PKCE "S256" é suportado.');
    }

    final OidcPendenciaAutorizacao pendencia = OidcPendenciaAutorizacao(
      idCliente: cliente.idCliente,
      uriRedirecionamento: uriRedirecionamento,
      escopos: escoposConcedidos,
      state: query['state'],
      nonce: _valorOuNulo(query['nonce']),
      codeChallenge: _valorOuNulo(query['code_challenge']),
      codeChallengeMethod: codeChallengeMethod,
    );
    request.session![chaveSessaoPendencia] = pendencia;

    final Uri destinoLogin = Uri(
      path: '/login',
      queryParameters: query.isEmpty ? null : query,
    );
    await response.redirect(destinoLogin, code: 302);
  }

  /// Gera o código de autorização de uso único e redireciona de volta ao
  /// `redirect_uri` do cliente pendente na sessão.
  ///
  /// Chamado por `OidcLoginController.autenticar` após login local bem
  /// sucedido — equivalente a `OidcController.issueAuthCodeAndRedirect` do
  /// projeto de referência `new_sali`.
  Future<void> emitirCodigoERedirecionar(
    RequestContext request,
    ResponseContext response, {
    required int idUsuario,
    String? stateOriginal,
  }) async {
    final Object? pendenciaBruta = request.session?[chaveSessaoPendencia];
    if (pendenciaBruta is! OidcPendenciaAutorizacao) {
      return _erro(
        response,
        400,
        'Requisição de autorização original não encontrada ou expirada. '
        'Reinicie o login a partir do cliente OIDC.',
      );
    }

    final SeiAppConfig config = request.make<SeiAppConfig>();
    final OidcCodigoAutorizacaoRepository repositorio =
        request.make<OidcCodigoAutorizacaoRepository>();

    final String valorCodigo = OidcCodigoAutorizacao.gerarValorCodigo();
    final OidcCodigoAutorizacao codigo = OidcCodigoAutorizacao(
      valorCodigo: valorCodigo,
      idCliente: pendenciaBruta.idCliente,
      idUsuario: idUsuario,
      escopos: pendenciaBruta.escopos,
      uriRedirecionamento: pendenciaBruta.uriRedirecionamento,
      dataExpiracao: DateTime.now().add(config.oidcCodigoAutorizacaoDuracao),
      codeChallenge: pendenciaBruta.codeChallenge,
      codeChallengeMethod: pendenciaBruta.codeChallengeMethod,
      nonce: pendenciaBruta.nonce,
    );
    await repositorio.salvar(codigo);
    request.session?.remove(chaveSessaoPendencia);

    final String? state = stateOriginal ?? pendenciaBruta.state;
    final Uri destinoBase = Uri.parse(pendenciaBruta.uriRedirecionamento);
    final Uri destino = destinoBase.replace(
      queryParameters: <String, String>{
        ...destinoBase.queryParameters,
        'code': valorCodigo,
        if (state != null) 'state': state,
      },
    );
    await response.redirect(destino, code: 302);
  }

  /// `POST /oauth2/token`: troca `authorization_code` por
  /// `access_token`/`id_token`/`refresh_token`, ou renova um
  /// `refresh_token` existente.
  Future<void> token(RequestContext request, ResponseContext response) async {
    await request.parseBody();
    final Map<String, dynamic> corpo = request.bodyAsMap;
    final String? tipoConcessao = corpo['grant_type'] as String?;

    switch (tipoConcessao) {
      case 'authorization_code':
        await _trocarCodigoPorToken(request, response, corpo);
        return;
      case 'refresh_token':
        await _renovarToken(request, response, corpo);
        return;
      default:
        await _erro(response, 400, 'grant_type não suportado.');
    }
  }

  Future<void> _trocarCodigoPorToken(
    RequestContext request,
    ResponseContext response,
    Map<String, dynamic> corpo,
  ) async {
    final String? valorCodigo = corpo['code'] as String?;
    final String? uriRedirecionamento = corpo['redirect_uri'] as String?;
    final String? idCliente = corpo['client_id'] as String?;
    final String? codeVerifier = corpo['code_verifier'] as String?;
    final String? clientSecret = corpo['client_secret'] as String?;

    if (valorCodigo == null ||
        uriRedirecionamento == null ||
        idCliente == null) {
      return _erro(
          response, 400, 'code, redirect_uri e client_id são obrigatórios.');
    }

    final OidcClienteRepository clienteRepositorio =
        request.make<OidcClienteRepository>();
    final OidcCliente? cliente =
        await clienteRepositorio.buscarAtivoPorId(idCliente);
    if (cliente == null) {
      return _erro(response, 401, 'Cliente OIDC desconhecido ou inativo.');
    }
    if (!OidcCliente.verificarSegredo(clientSecret, cliente.hashSegredo)) {
      return _erro(response, 401, 'client_secret inválido.');
    }

    final OidcCodigoAutorizacaoRepository codigoRepositorio =
        request.make<OidcCodigoAutorizacaoRepository>();
    final OidcCodigoAutorizacao? codigo =
        await codigoRepositorio.buscarPorValor(valorCodigo);
    if (codigo == null ||
        codigo.idCliente != idCliente ||
        codigo.uriRedirecionamento != uriRedirecionamento) {
      return _erro(
          response, 400, 'Código de autorização inválido ou expirado.');
    }
    // Revogado já aqui, antes da checagem do PKCE: código de autorização é
    // de uso único mesmo quando a tentativa de troca falha em seguida.
    await codigoRepositorio.revogar(valorCodigo);

    if (codigo.codeChallenge != null) {
      if (codeVerifier == null || codeVerifier.isEmpty) {
        return _erro(
            response, 400, 'code_verifier é obrigatório para este código.');
      }
      if (!_pkceValido(codeVerifier, codigo.codeChallenge!)) {
        return _erro(response, 400, 'code_verifier inválido.');
      }
    }

    final OidcService servico = request.make<OidcService>();
    final SeiAppConfig config = request.make<SeiAppConfig>();

    Usuario? usuario;
    if (codigo.escopos.contains('profile')) {
      usuario =
          await request.make<UsuarioRepository>().buscarPorId(codigo.idUsuario);
    }

    final String accessToken = servico.criarAccessToken(
      idUsuario: codigo.idUsuario,
      cliente: cliente,
      escopos: codigo.escopos,
    );
    final String idToken = servico.criarIdToken(
      idUsuario: codigo.idUsuario,
      cliente: cliente,
      escopos: codigo.escopos,
      authTime: DateTime.now(),
      nonce: codigo.nonce,
      usuario: usuario,
    );

    String? refreshTokenValor;
    if (codigo.escopos.contains('offline_access')) {
      refreshTokenValor = OidcTokenRenovacao.gerarValorToken();
      final OidcTokenRenovacao refreshToken = OidcTokenRenovacao(
        valorToken: refreshTokenValor,
        idCliente: cliente.idCliente,
        idUsuario: codigo.idUsuario,
        escopos: codigo.escopos,
        dataExpiracao: DateTime.now().add(config.oidcRefreshTokenDuracao),
      );
      await request.make<OidcTokenRenovacaoRepository>().salvar(refreshToken);
    }

    await response.json(<String, dynamic>{
      'access_token': accessToken,
      'token_type': 'Bearer',
      'expires_in': config.oidcAccessTokenDuracao.inSeconds,
      if (refreshTokenValor != null) 'refresh_token': refreshTokenValor,
      'id_token': idToken,
      'scope': codigo.escopos.join(' '),
    });
  }

  Future<void> _renovarToken(
    RequestContext request,
    ResponseContext response,
    Map<String, dynamic> corpo,
  ) async {
    final String? refreshTokenValor = corpo['refresh_token'] as String?;
    if (refreshTokenValor == null || refreshTokenValor.isEmpty) {
      return _erro(response, 400, 'refresh_token é obrigatório.');
    }

    final OidcTokenRenovacaoRepository tokenRepositorio =
        request.make<OidcTokenRenovacaoRepository>();
    final OidcTokenRenovacao? tokenAtual =
        await tokenRepositorio.buscarValidoPorValor(refreshTokenValor);
    if (tokenAtual == null) {
      return _erro(
          response, 401, 'refresh_token inválido, expirado ou revogado.');
    }

    final OidcClienteRepository clienteRepositorio =
        request.make<OidcClienteRepository>();
    final OidcCliente? cliente =
        await clienteRepositorio.buscarAtivoPorId(tokenAtual.idCliente);
    if (cliente == null) {
      return _erro(response, 401,
          'Cliente OIDC do refresh_token não encontrado ou inativo.');
    }

    // Rotação: o token trocado nunca mais é aceito, mesmo que a emissão do
    // novo par falhe em seguida.
    await tokenRepositorio.revogar(refreshTokenValor);

    final OidcService servico = request.make<OidcService>();
    final SeiAppConfig config = request.make<SeiAppConfig>();
    final String accessToken = servico.criarAccessToken(
      idUsuario: tokenAtual.idUsuario,
      cliente: cliente,
      escopos: tokenAtual.escopos,
    );

    final String novoRefreshTokenValor = OidcTokenRenovacao.gerarValorToken();
    final OidcTokenRenovacao novoRefreshToken = OidcTokenRenovacao(
      valorToken: novoRefreshTokenValor,
      idCliente: cliente.idCliente,
      idUsuario: tokenAtual.idUsuario,
      escopos: tokenAtual.escopos,
      dataExpiracao: DateTime.now().add(config.oidcRefreshTokenDuracao),
    );
    await tokenRepositorio.salvar(novoRefreshToken);

    await response.json(<String, dynamic>{
      'access_token': accessToken,
      'token_type': 'Bearer',
      'expires_in': config.oidcAccessTokenDuracao.inSeconds,
      'refresh_token': novoRefreshTokenValor,
      'scope': tokenAtual.escopos.join(' '),
    });
  }

  /// `GET/POST /oauth2/userinfo`: exige `Authorization: Bearer <access_token>`
  /// e devolve os claims do escopo concedido, buscando o usuário na hora —
  /// dado fresco, não um retrato estático do momento da emissão do token.
  Future<void> userinfo(
      RequestContext request, ResponseContext response) async {
    final String? cabecalho = request.headers?.value('authorization');
    if (cabecalho == null || !cabecalho.startsWith(_prefixoBearer)) {
      return _erro(response, 401, 'access_token ausente.');
    }

    final String token = cabecalho.substring(_prefixoBearer.length).trim();
    final OidcService servico = request.make<OidcService>();
    final Map<String, dynamic>? claims =
        await servico.verificarTokenAssinado(token);
    if (claims == null) {
      return _erro(response, 401, 'access_token inválido ou expirado.');
    }

    final int idUsuario = SeiCoreUtils.inteiro(claims['sub'], nomeCampo: 'sub');
    final List<String> escopos = (claims['scope'] as String? ?? '')
        .split(' ')
        .where((String escopo) => escopo.isNotEmpty)
        .toList(growable: false);

    final Map<String, dynamic> corpo = <String, dynamic>{
      'sub': idUsuario.toString()
    };
    if (escopos.contains('profile')) {
      final Usuario? usuario =
          await request.make<UsuarioRepository>().buscarPorId(idUsuario);
      if (usuario != null) {
        corpo['name'] = usuario.nome;
        corpo['preferred_username'] = usuario.sigla;
      }
    }

    await response.json(corpo);
  }

  /// `GET/POST /oauth2/logout`: encerra a sessão local e, quando
  /// `post_logout_redirect_uri` acompanha um `id_token_hint` válido e
  /// cadastrado para o cliente daquele token, redireciona de volta —
  /// nunca redireciona para uma URI não comprovadamente do cliente
  /// (proteção contra open redirect).
  Future<void> logout(RequestContext request, ResponseContext response) async {
    final Map<String, String> query =
        request.uri?.queryParameters ?? const <String, String>{};
    final String? postLogoutRedirectUri =
        _valorOuNulo(query['post_logout_redirect_uri']);
    final String? idTokenHint = _valorOuNulo(query['id_token_hint']);
    final String? state = _valorOuNulo(query['state']);

    Uri? destino = await _resolverDestinoLogout(
      request,
      postLogoutRedirectUri: postLogoutRedirectUri,
      idTokenHint: idTokenHint,
      state: state,
    );

    request.session?.remove(chaveSessaoPendencia);
    request.session?.destroy();

    await response.redirect(destino ?? Uri(path: '/login'), code: 302);
  }

  Future<Uri?> _resolverDestinoLogout(
    RequestContext request, {
    required String? postLogoutRedirectUri,
    required String? idTokenHint,
    required String? state,
  }) async {
    if (postLogoutRedirectUri == null || idTokenHint == null) {
      return null;
    }

    final OidcService servico = request.make<OidcService>();
    final Map<String, dynamic>? claims =
        await servico.verificarTokenAssinado(idTokenHint);
    final String? idCliente = claims?['aud'] as String?;
    if (idCliente == null) {
      return null;
    }

    final OidcCliente? cliente =
        await request.make<OidcClienteRepository>().buscarAtivoPorId(idCliente);
    if (cliente == null ||
        !cliente.urisRedirecionamentoPosLogout
            .contains(postLogoutRedirectUri)) {
      return null;
    }

    final Uri destino = Uri.parse(postLogoutRedirectUri);
    if (state == null) {
      return destino;
    }
    return destino.replace(
      queryParameters: <String, String>{
        ...destino.queryParameters,
        'state': state
      },
    );
  }

  bool _pkceValido(String codeVerifier, String codeChallenge) {
    final List<int> digest = sha256.convert(utf8.encode(codeVerifier)).bytes;
    final String desafioCalculado =
        base64Url.encode(digest).replaceAll('=', '');
    return desafioCalculado == codeChallenge;
  }

  String? _valorOuNulo(String? valor) {
    if (valor == null) {
      return null;
    }
    final String tratado = valor.trim();
    return tratado.isEmpty ? null : tratado;
  }

  Future<void> _erro(
      ResponseContext response, int codigoHttp, String mensagem) {
    return RespostaApiHttp.responderErro(response,
        codigoHttp: codigoHttp, mensagem: mensagem);
  }
}
