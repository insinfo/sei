import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:ngdart/angular.dart';

/// Falha de comunicação, `state`/PKCE inválido ou contrato inesperado no
/// fluxo de autenticação.
class AuthApiException implements Exception {
  AuthApiException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Guarda a sessão autenticada e conduz o frontend como cliente OpenID
/// Connect (Authorization Code + PKCE S256) do provider implementado em
/// `backend/lib/src/modules/oidc/`.
///
/// Segue o mesmo padrão de `SessaoUnidadeService`
/// (`shared/services/sessao_unidade_service.dart`): serviço singleton
/// provido na raiz da aplicação (`AppComponent.providers`), com campos
/// mutáveis — não é um DTO de transporte, é estado de sessão que muda com
/// login/logout, então não faz sentido como value object imutável (ver
/// AGENTS.md, "DTOs/models usados por binding ou estado mutável da UI podem
/// ter campos mutáveis").
///
/// ## Por que redirect, e não formulário na SPA
///
/// O SEI em Dart passa a atuar como Identity Provider (IdP) para os
/// sistemas clientes de uma instituição, e este frontend é o primeiro
/// Relying Party registrado (`backend/scripts/migrations/
/// 0002_oidc_seed_cliente_frontend.sql`). Um cliente SPA público (`web_spa`,
/// sem `client_secret`) nunca deve coletar usuário/senha diretamente — quem
/// é dono da tela de login e das credenciais é o backend
/// (`GET/POST /login`, página HTML própria). Este serviço só: (1) gera os
/// parâmetros PKCE e navega o navegador de verdade para
/// `GET /oauth2/authorize`; (2) depois que o backend redireciona de volta
/// para `RoutePaths.oidcCallback` com `code`/`state`, troca o código por
/// tokens em `POST /oauth2/token`.
///
/// ## Fronteiras deliberadas desta rodada
///
/// - **Sem renovação automática de `access_token`.** [refreshToken] é
///   guardado quando o backend devolve um (isso só acontece quando o
///   escopo `offline_access` é concedido — hoje este cliente pede só
///   `openid profile`, então normalmente não há refresh token ainda), mas
///   nenhuma rotina dispara `grant_type=refresh_token` sozinha antes do
///   `access_token` expirar. Próximo passo natural quando alguma tela
///   passar a chamar uma API protegida por `access_token` de verdade.
/// - **Sem verificação de assinatura RS256 do `id_token` no navegador.**
///   [processarCallback] decodifica só o *payload* do JWT (a parte do meio,
///   base64url) para ler claims e exibir nome/usuário — verificar a
///   assinatura exigiria buscar `GET /oauth2/jwks` e implementar validação
///   JWS em Dart, responsabilidade que continua do backend/servidor de
///   recursos, não deste cliente.
///
/// Persistência: a sessão é guardada em `window.localStorage` (chave
/// `sei.sessao`, mesma chave do fluxo de login local anterior — só o
/// formato interno mudou, de `token`/`id_orgao` para
/// `access_token`/`refresh_token`/`id_token`) para sobreviver a um F5.
/// `code_verifier`/`state`/`nonce` do PKCE em trânsito ficam em
/// `window.sessionStorage`, não em `localStorage`: só precisam sobreviver
/// ao redirect de ida e volta para `/oauth2/authorize`, não a sessões
/// futuras — deixá-los em `sessionStorage` também os limpa sozinho quando a
/// aba fecha, reduzindo a janela de uso indevido de um `code_verifier`
/// abandonado.
@Injectable()
class AuthService {
  AuthService({http.Client? cliente, Uri? baseUri})
      : _cliente = cliente ?? http.Client(),
        _baseUri = baseUri ?? Uri.parse('http://localhost:3350/api/v1') {
    _restaurarSessao();
  }

  static const String _chaveArmazenamento = 'sei.sessao';
  static const String _chaveSessionCodeVerifier = 'sei.oidc.code_verifier';
  static const String _chaveSessionState = 'sei.oidc.state';
  static const String _chaveSessionRedirectUri = 'sei.oidc.redirect_uri';

  /// `client_id` do frontend AngularDart cadastrado como cliente OIDC
  /// `web_spa` (sem `client_secret`) em
  /// `backend/scripts/migrations/0002_oidc_seed_cliente_frontend.sql`.
  static const String _clientId =
      'VtmSvvPTcSi11_bmtW8ncd-NmW-4LFAQ0sqNps6XlHw';

  static const String _escopos = 'openid profile';

  final http.Client _cliente;
  final Uri _baseUri;

  /// Token de acesso emitido por `POST /oauth2/token`, ou `null` quando não
  /// autenticado.
  String? accessToken;

  /// Token de renovação, quando o backend devolveu um (escopo
  /// `offline_access`). Guardado para uso futuro; nenhuma renovação
  /// automática é feita nesta rodada — ver dartdoc da classe.
  String? refreshToken;

  /// `id_token` (JWT RS256) recebido do provider, guardado íntegro para uso
  /// futuro (ex.: `id_token_hint` em `GET /oauth2/logout`).
  String? idToken;

  /// Identificador do usuário autenticado, extraído da claim `sub` do
  /// `id_token`.
  int? idUsuario;

  /// Sigla do usuário autenticado, extraída da claim `preferred_username`
  /// do `id_token` (só presente quando o escopo `profile` foi concedido).
  String? siglaUsuario;

  /// Nome do usuário autenticado, extraído da claim `name` do `id_token`
  /// (só presente quando o escopo `profile` foi concedido).
  String? nomeUsuario;

  /// `true` quando há uma sessão autenticada em memória.
  bool get autenticado => accessToken != null && accessToken!.isNotEmpty;

  /// Inicia o fluxo OpenID Connect: gera `code_verifier`/`code_challenge`
  /// (PKCE S256) e `state`/`nonce` aleatórios, guarda o que precisa
  /// sobreviver ao redirect em `sessionStorage` e navega o navegador de
  /// verdade (não roteamento interno do `ngrouter`) para
  /// `GET /oauth2/authorize` no backend.
  ///
  /// A navegação sai da SPA por um instante — isso é esperado e correto em
  /// OIDC, não um bug: o backend é quem mostra a tela de login e devolve o
  /// navegador para [RoutePaths.oidcCallback] com `code`/`state` depois.
  void iniciarLogin() {
    final String codeVerifier = _gerarCodeVerifier();
    final String codeChallenge = _gerarCodeChallengeS256(codeVerifier);
    final String state = _gerarValorAleatorio();
    final String nonce = _gerarValorAleatorio();
    final String redirectUri = _redirectUriAtual();

    try {
      html.window.sessionStorage[_chaveSessionCodeVerifier] = codeVerifier;
      html.window.sessionStorage[_chaveSessionState] = state;
      html.window.sessionStorage[_chaveSessionRedirectUri] = redirectUri;
    } catch (_) {
      // sessionStorage indisponível (ex.: modo privado); o callback vai
      // falhar na checagem de `state` logo abaixo e mostrar instrução clara
      // para tentar de novo, em vez de travar aqui.
    }

    final Uri uriAutorizacao = _oidcBaseUri.replace(
      path: '/oauth2/authorize',
      queryParameters: <String, String>{
        'response_type': 'code',
        'client_id': _clientId,
        'redirect_uri': redirectUri,
        'scope': _escopos,
        'state': state,
        'nonce': nonce,
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
      },
    );
    html.window.location.href = uriAutorizacao.toString();
  }

  /// Processa o retorno de `GET /oauth2/authorize` em
  /// [RoutePaths.oidcCallback]: confere o `state` contra o que foi salvo em
  /// [iniciarLogin], troca `code` por tokens em `POST /oauth2/token`
  /// (`application/x-www-form-urlencoded`, sem `client_secret` — cliente
  /// `web_spa` é público e se autentica só por PKCE) e guarda a sessão
  /// resultante.
  ///
  /// Lança [AuthApiException] com mensagem específica em cada etapa que
  /// pode falhar (state divergente, sessão PKCE expirada, falha de
  /// comunicação, resposta inesperada) para a página de callback mostrar um
  /// erro claro em vez de travar em "carregando".
  Future<void> processarCallback({
    required String? code,
    required String? state,
  }) async {
    if (code == null || code.isEmpty) {
      throw AuthApiException(
        'O provedor de login não retornou um código de autorização.',
      );
    }

    String? codeVerifier;
    String? stateSalvo;
    String? redirectUriSalvo;
    try {
      codeVerifier = html.window.sessionStorage[_chaveSessionCodeVerifier];
      stateSalvo = html.window.sessionStorage[_chaveSessionState];
      redirectUriSalvo = html.window.sessionStorage[_chaveSessionRedirectUri];
    } catch (_) {
      // Sem sessionStorage disponível, os valores seguem nulos e a
      // validação abaixo já cobre esse caso com uma mensagem clara.
    }

    if (codeVerifier == null || codeVerifier.isEmpty || stateSalvo == null) {
      throw AuthApiException(
        'A sessão de login expirou ou foi iniciada em outra aba. '
        'Tente entrar novamente.',
      );
    }
    if (state == null || state != stateSalvo) {
      throw AuthApiException(
        'O parâmetro "state" retornado não confere com o esperado. Por '
        'segurança, tente entrar novamente.',
      );
    }

    final String redirectUri = redirectUriSalvo ?? _redirectUriAtual();
    final Uri uriToken = _oidcBaseUri.replace(path: '/oauth2/token');

    http.Response resposta;
    try {
      resposta = await _cliente.post(
        uriToken,
        headers: const <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: <String, String>{
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'client_id': _clientId,
          'code_verifier': codeVerifier,
        },
      );
    } catch (_) {
      _limparPendenciaPkce();
      throw AuthApiException(
        'Não foi possível conectar ao servidor de login do SEI.',
      );
    }

    _limparPendenciaPkce();

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw AuthApiException(
        'A API respondeu ${resposta.statusCode} ao trocar o código de '
        'autorização por tokens.',
      );
    }

    final Object? corpo = _decodificarJson(resposta);
    if (corpo is! Map<String, dynamic>) {
      throw AuthApiException(
        'A API retornou uma resposta de token inválida.',
      );
    }

    final String? accessTokenRecebido = corpo['access_token'] as String?;
    final String? idTokenRecebido = corpo['id_token'] as String?;
    if (accessTokenRecebido == null ||
        accessTokenRecebido.isEmpty ||
        idTokenRecebido == null ||
        idTokenRecebido.isEmpty) {
      throw AuthApiException(
        'A API não retornou os tokens esperados (access_token/id_token).',
      );
    }

    final Map<String, dynamic> claims =
        _decodificarClaimsIdToken(idTokenRecebido);

    accessToken = accessTokenRecebido;
    idToken = idTokenRecebido;
    refreshToken = corpo['refresh_token'] as String?;
    idUsuario = _inteiro(claims['sub']);
    nomeUsuario = claims['name'] as String?;
    siglaUsuario = claims['preferred_username'] as String?;
    _salvarSessao();
  }

  /// Encerra a sessão local, sem chamar `GET /oauth2/logout` nesta rodada
  /// (fora do escopo combinado; ver dartdoc da classe).
  void logout() {
    accessToken = null;
    refreshToken = null;
    idToken = null;
    idUsuario = null;
    siglaUsuario = null;
    nomeUsuario = null;
    try {
      html.window.localStorage.remove(_chaveArmazenamento);
    } catch (_) {
      // Armazenamento indisponível (ex.: modo privado); a sessão em memória
      // já foi limpa acima.
    }
  }

  /// URL de retorno registrada para este cliente OIDC.
  ///
  /// Calculada a partir da origem atual da página (`window.location.origin`)
  /// em vez de fixa em código, para casar automaticamente com qualquer host
  /// pelo qual o dev server esteja sendo acessado (`localhost`/`127.0.0.1`)
  /// — ambos cadastrados em `oidc_cliente.uris_redirecionamento`
  /// (`backend/scripts/migrations/0002_oidc_seed_cliente_frontend.sql`).
  String _redirectUriAtual() => '${html.window.location.origin}/callback';

  /// Host:porta do backend (provider OIDC), sem o prefixo `/api/v1` usado
  /// pelas demais APIs REST — os endpoints `/oauth2/*`, `/.well-known/*` e
  /// `/login` são montados na raiz do backend
  /// (`backend/lib/src/modules/oidc/routes/oidc_routes.dart`), não sob
  /// `/api/v1`.
  Uri get _oidcBaseUri => _baseUri.replace(path: '', query: '');

  void _limparPendenciaPkce() {
    try {
      html.window.sessionStorage.remove(_chaveSessionCodeVerifier);
      html.window.sessionStorage.remove(_chaveSessionState);
      html.window.sessionStorage.remove(_chaveSessionRedirectUri);
    } catch (_) {
      // Sem sessionStorage disponível, não há nada para limpar.
    }
  }

  /// Gera um `code_verifier` aleatório de alta entropia (64 caracteres, no
  /// alfabeto `[A-Za-z0-9-._~]` exigido pela RFC 7636 — dentro da faixa
  /// permitida de 43 a 128 caracteres).
  String _gerarCodeVerifier() {
    const String alfabeto =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final Random aleatorio = Random.secure();
    return List<String>.generate(
      64,
      (int _) => alfabeto[aleatorio.nextInt(alfabeto.length)],
    ).join();
  }

  /// Calcula `code_challenge = BASE64URL(SHA256(code_verifier))`, sem
  /// preenchimento (`=`), conforme RFC 7636 (método `S256`).
  String _gerarCodeChallengeS256(String codeVerifier) {
    final List<int> digest = sha256.convert(utf8.encode(codeVerifier)).bytes;
    return base64Url.encode(digest).replaceAll('=', '');
  }

  /// Gera um valor aleatório de 32 bytes codificado em base64url, usado
  /// tanto para `state` (proteção CSRF do redirect) quanto para `nonce`
  /// (ligação do `id_token` a esta tentativa de login).
  String _gerarValorAleatorio() {
    final Random aleatorio = Random.secure();
    final List<int> valores =
        List<int>.generate(32, (int _) => aleatorio.nextInt(256));
    return base64Url.encode(valores).replaceAll('=', '');
  }

  /// Decodifica só o *payload* (segunda parte) do `id_token` — um JWT
  /// `header.payload.assinatura` — sem verificar a assinatura RS256: essa
  /// verificação é responsabilidade do backend/servidor de recursos, não
  /// deste cliente (ver dartdoc da classe). Usado só para ler claims e
  /// exibir nome/usuário na tela.
  Map<String, dynamic> _decodificarClaimsIdToken(String idTokenJwt) {
    final List<String> partes = idTokenJwt.split('.');
    if (partes.length != 3) {
      throw AuthApiException(
        'O id_token retornado pela API tem formato inválido.',
      );
    }
    try {
      final String payloadJson =
          utf8.decode(base64Url.decode(_completarBase64Url(partes[1])));
      final Object? decodificado = jsonDecode(payloadJson);
      if (decodificado is! Map<String, dynamic>) {
        throw AuthApiException(
          'O id_token retornado pela API tem payload inválido.',
        );
      }
      return decodificado;
    } on AuthApiException {
      rethrow;
    } catch (_) {
      throw AuthApiException(
        'Não foi possível decodificar o id_token retornado pela API.',
      );
    }
  }

  /// Completa um trecho base64url com o `=` de preenchimento que o JWT
  /// omite, para que `base64Url.decode` (que exige comprimento múltiplo de
  /// 4) não lance [FormatException].
  String _completarBase64Url(String valor) {
    final int resto = valor.length % 4;
    return resto == 0 ? valor : valor + ('=' * (4 - resto));
  }

  void _salvarSessao() {
    try {
      html.window.localStorage[_chaveArmazenamento] =
          jsonEncode(<String, Object?>{
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'id_token': idToken,
        'id_usuario': idUsuario,
        'sigla_usuario': siglaUsuario,
        'nome_usuario': nomeUsuario,
      });
    } catch (_) {
      // Sem `localStorage` disponível, a sessão continua válida em memória
      // até o próximo reload — funcionalidade reduzida, não um erro fatal.
    }
  }

  void _restaurarSessao() {
    String? bruto;
    try {
      bruto = html.window.localStorage[_chaveArmazenamento];
    } catch (_) {
      return;
    }
    if (bruto == null || bruto.isEmpty) {
      return;
    }
    try {
      final Object? decodificado = jsonDecode(bruto);
      if (decodificado is! Map<String, dynamic>) {
        return;
      }
      accessToken = decodificado['access_token'] as String?;
      refreshToken = decodificado['refresh_token'] as String?;
      idToken = decodificado['id_token'] as String?;
      idUsuario = _inteiro(decodificado['id_usuario']);
      siglaUsuario = decodificado['sigla_usuario'] as String?;
      nomeUsuario = decodificado['nome_usuario'] as String?;
    } catch (_) {
      // Conteúdo corrompido em `localStorage`; segue sem sessão restaurada.
    }
  }

  int? _inteiro(Object? valor) {
    if (valor == null) {
      return null;
    }
    if (valor is int) {
      return valor;
    }
    if (valor is String) {
      return int.tryParse(valor);
    }
    return null;
  }

  Object? _decodificarJson(http.Response resposta) {
    try {
      return jsonDecode(utf8.decode(resposta.bodyBytes));
    } on FormatException {
      throw AuthApiException(
        'A API retornou JSON inválido para autenticação.',
      );
    }
  }
}
