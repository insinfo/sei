import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/oidc/controllers/oidc_controller.dart';
import 'package:sei_backend/src/modules/oidc/controllers/oidc_login_controller.dart';

/// Registra os endpoints do provider OpenID Connect e a página de login
/// local que serve o passo interativo do fluxo `authorize` → `login` →
/// `token`.
///
/// Nenhuma rota exige `AuthMiddleware`: são o ponto de entrada de todo o
/// fluxo de autenticação, antes de existir qualquer sessão ou token — o
/// mesmo raciocínio das rotas de `POST /api/v1/auth/login`.
void registrarRotasOidc(
  Angel app,
  OidcController oidcController,
  OidcLoginController loginController, {
  required RequestHandler middlewareConexao,
}) {
  final List<RequestHandler> middlewares = <RequestHandler>[middlewareConexao];

  app.get(
    '/.well-known/openid-configuration',
    oidcController.discovery,
    middleware: middlewares,
  );
  app.get('/oauth2/jwks', oidcController.jwks, middleware: middlewares);

  app.get('/oauth2/authorize', oidcController.authorize,
      middleware: middlewares);
  app.post('/oauth2/token', oidcController.token, middleware: middlewares);

  app.get('/oauth2/userinfo', oidcController.userinfo, middleware: middlewares);
  app.post('/oauth2/userinfo', oidcController.userinfo,
      middleware: middlewares);

  app.get('/oauth2/logout', oidcController.logout, middleware: middlewares);
  app.post('/oauth2/logout', oidcController.logout, middleware: middlewares);

  app.get('/login', loginController.mostrarPaginaLogin,
      middleware: middlewares);
  app.post('/login', loginController.autenticar, middleware: middlewares);
}
