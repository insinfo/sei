import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/autenticacao/controllers/autenticacao_controller.dart';

/// Registra as rotas públicas de autenticação: login e órgãos para o
/// seletor de login. Nenhuma das duas exige `AuthMiddleware` — são o ponto
/// de entrada antes de existir sessão.
void registrarRotasAutenticacao(
  Angel app,
  AutenticacaoController controller, {
  required RequestHandler middlewareConexao,
}) {
  final List<RequestHandler> middlewares = <RequestHandler>[
    middlewareConexao,
  ];

  app.post(
    '/api/v1/auth/login',
    controller.login,
    middleware: middlewares,
  );
  app.get(
    '/api/v1/auth/orgaos',
    controller.orgaos,
    middleware: middlewares,
  );
}
