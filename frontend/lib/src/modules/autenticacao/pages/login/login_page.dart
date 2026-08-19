import 'package:ngdart/angular.dart';
import 'package:sei_frontend/src/shared/services/auth_service.dart';

/// Ponto de entrada do login do SEI.
///
/// Deixou de ser um formulário de usuário/senha/órgão dentro da SPA: com o
/// provider OpenID Connect implementado no backend
/// (`backend/lib/src/modules/oidc/`), a coleta de credenciais passou a ser
/// responsabilidade exclusiva do Identity Provider — `GET /login`, página
/// HTML própria renderizada pelo backend, fora desta SPA. Um cliente SPA
/// público (`web_spa`, sem `client_secret`) nunca deve coletar credenciais
/// diretamente.
///
/// Esta página só mostra o botão "Entrar", que dispara
/// `AuthService.iniciarLogin()`: gera os parâmetros PKCE, guarda o que
/// precisa sobreviver ao redirect em `sessionStorage` e navega o navegador
/// para `GET /oauth2/authorize` no backend. De lá, o usuário autentica na
/// tela do backend e volta para `RoutePaths.oidcCallback`, que troca o
/// código de autorização por tokens — ver dartdoc de [AuthService] para o
/// fluxo completo.
@Component(
  selector: 'sei-login-page',
  templateUrl: 'login_page.html',
  styleUrls: <String>['login_page.css'],
)
class LoginPage {
  LoginPage(this._authService);

  final AuthService _authService;

  /// Inicia o fluxo OpenID Connect (Authorization Code + PKCE) que leva o
  /// navegador até a tela de login do backend.
  void entrar() {
    _authService.iniciarLogin();
  }
}
