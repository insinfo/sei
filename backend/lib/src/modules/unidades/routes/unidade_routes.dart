import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/unidades/controllers/unidade_controller.dart';

/// Registra as rotas de cadastro de unidade, todas atrás de `AuthMiddleware`.
void registrarRotasUnidades(
  Angel app,
  UnidadeController controller, {
  required RequestHandler middlewareConexao,
  required RequestHandler middlewareAuth,
}) {
  final List<RequestHandler> middlewares = <RequestHandler>[
    middlewareConexao,
    middlewareAuth,
  ];

  app.get(
    '/api/v1/unidades',
    controller.listar,
    middleware: middlewares,
  );
  app.get(
    '/api/v1/unidades/:${UnidadeController.idUnidadeParam}',
    controller.detalhe,
    middleware: middlewares,
  );
  app.post(
    '/api/v1/unidades',
    controller.criar,
    middleware: middlewares,
  );
  app.put(
    '/api/v1/unidades/:${UnidadeController.idUnidadeParam}',
    controller.atualizar,
    middleware: middlewares,
  );
}
