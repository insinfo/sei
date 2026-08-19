import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/orgaos/controllers/orgao_controller.dart';

/// Registra as rotas de cadastro de órgão, todas atrás de `AuthMiddleware`.
void registrarRotasOrgaos(
  Angel app,
  OrgaoController controller, {
  required RequestHandler middlewareConexao,
  required RequestHandler middlewareAuth,
}) {
  final List<RequestHandler> middlewares = <RequestHandler>[
    middlewareConexao,
    middlewareAuth,
  ];

  app.get(
    '/api/v1/orgaos',
    controller.listar,
    middleware: middlewares,
  );
  app.get(
    '/api/v1/orgaos/:${OrgaoController.idOrgaoParam}',
    controller.detalhe,
    middleware: middlewares,
  );
  app.post(
    '/api/v1/orgaos',
    controller.criar,
    middleware: middlewares,
  );
  app.put(
    '/api/v1/orgaos/:${OrgaoController.idOrgaoParam}',
    controller.atualizar,
    middleware: middlewares,
  );
}
