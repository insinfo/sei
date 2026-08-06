import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/controle_processos/controllers/controle_processos_controller.dart';

/// Registra as rotas de consulta de processos em aberto da unidade.
void registrarRotasControleProcessos(
  Angel app,
  ControleProcessosController controller, {
  required RequestHandler middlewareConexao,
}) {
  final List<RequestHandler> middlewares = <RequestHandler>[
    middlewareConexao,
  ];

  app.get(
    '/api/v1/controle-processos/recebidos',
    controller.recebidos,
    middleware: middlewares,
  );
  app.get(
    '/api/v1/controle-processos/gerados',
    controller.gerados,
    middleware: middlewares,
  );
}
