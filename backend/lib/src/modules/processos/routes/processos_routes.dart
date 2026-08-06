import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/processos/controllers/processo_detalhe_controller.dart';

/// Registra as rotas de consulta detalhada de processos.
void registrarRotasProcessos(
  Angel app,
  ProcessoDetalheController processoDetalheController, {
  required RequestHandler middlewareConexao,
}) {
  final List<RequestHandler> middlewares = <RequestHandler>[
    middlewareConexao,
  ];

  app.get(
    '/api/v1/processos/:${ProcessoDetalheController.idProcessoParam}/cabecalho',
    processoDetalheController.cabecalho,
    middleware: middlewares,
  );
  app.get(
    '/api/v1/processos/:${ProcessoDetalheController.idProcessoParam}/documentos',
    processoDetalheController.documentos,
    middleware: middlewares,
  );
  app.get(
    '/api/v1/processos/:${ProcessoDetalheController.idProcessoParam}/andamentos',
    processoDetalheController.andamentos,
    middleware: middlewares,
  );
}
