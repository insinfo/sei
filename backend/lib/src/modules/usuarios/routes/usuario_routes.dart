import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/usuarios/controllers/usuario_controller.dart';

/// Registra as rotas de cadastro de usuário, todas atrás de `AuthMiddleware`.
void registrarRotasUsuarios(
  Angel app,
  UsuarioController controller, {
  required RequestHandler middlewareConexao,
  required RequestHandler middlewareAuth,
}) {
  final List<RequestHandler> middlewares = <RequestHandler>[
    middlewareConexao,
    middlewareAuth,
  ];

  app.get(
    '/api/v1/usuarios',
    controller.listar,
    middleware: middlewares,
  );
  app.get(
    '/api/v1/usuarios/:${UsuarioController.idUsuarioParam}',
    controller.detalhe,
    middleware: middlewares,
  );
  app.post(
    '/api/v1/usuarios',
    controller.criar,
    middleware: middlewares,
  );
  app.put(
    '/api/v1/usuarios/:${UsuarioController.idUsuarioParam}',
    controller.atualizar,
    middleware: middlewares,
  );
  app.put(
    '/api/v1/usuarios/:${UsuarioController.idUsuarioParam}/senha',
    controller.trocarSenha,
    middleware: middlewares,
  );
}
