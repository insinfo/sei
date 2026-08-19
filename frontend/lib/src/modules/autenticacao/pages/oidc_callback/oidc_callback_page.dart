import 'dart:async' show unawaited;
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:sei_frontend/src/shared/routes/route_paths.dart';
import 'package:sei_frontend/src/shared/services/auth_service.dart';

/// Callback do fluxo OpenID Connect (Authorization Code + PKCE): recebe de
/// volta `code`/`state` depois que o backend (`GET /oauth2/authorize` →
/// tela de login própria dele → `emitirCodigoERedirecionar`) devolve o
/// navegador para cá, e troca o código por tokens via
/// `AuthService.processarCallback`.
///
/// A navegação até esta página é um reload de página inteira disparado pelo
/// backend (redirect HTTP 302), não uma navegação interna do `ngrouter` —
/// por isso [onActivate] lê `code`/`state` direto de
/// `html.window.location.search`, em vez de confiar em
/// `current.queryParameters`: nesta ativação a frio (primeiro componente
/// montado depois de um F5 real), a disponibilidade desses parâmetros pelo
/// `ngrouter` não é garantida (ver AGENTS.md, "Rotas e query params
/// transitórios").
///
/// Qualquer falha (state divergente, sessão PKCE expirada, troca de token
/// malsucedida, resposta inesperada) é mostrada nesta própria página com
/// uma mensagem clara e um link para tentar de novo — nunca fica em branco
/// nem travada em "carregando".
@Component(
  selector: 'sei-oidc-callback-page',
  templateUrl: 'oidc_callback_page.html',
  styleUrls: <String>['oidc_callback_page.css'],
  directives: <Type>[NgIf],
)
class OidcCallbackPage implements OnActivate {
  OidcCallbackPage(this._authService, this._router);

  final AuthService _authService;
  final Router _router;

  /// `true` enquanto a troca do código por tokens está em andamento.
  bool processando = true;

  /// Mensagem de erro para exibição, ou `null` quando não houve falha.
  String? erro;

  @override
  void onActivate(RouterState? previous, RouterState current) {
    unawaited(_processarRetorno());
  }

  Future<void> _processarRetorno() async {
    processando = true;
    erro = null;
    final Map<String, String> query =
        Uri.parse(html.window.location.href).queryParameters;
    try {
      await _authService.processarCallback(
        code: query['code'],
        state: query['state'],
      );
      unawaited(_router.navigate(RoutePaths.raiz.toUrl()));
    } on AuthApiException catch (excecao) {
      erro = excecao.mensagem;
    } catch (_) {
      erro = 'Não foi possível concluir o login. Tente novamente.';
    } finally {
      processando = false;
    }
  }

  /// Reinicia o fluxo de login do zero a partir de [RoutePaths.login].
  void tentarNovamente() {
    unawaited(_router.navigate(RoutePaths.login.toUrl()));
  }
}
