import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/catalogos/controllers/catalogo_controller.dart';
import 'package:sei_backend/src/modules/catalogos/controllers/status_ambiente_controller.dart';

/// Registra as rotas públicas de saúde e leitura dos catálogos SEI.
void registrarRotasCatalogos(
  Angel app, {
  required StatusAmbienteController statusController,
  required CatalogoController catalogoController,
  required RequestHandler middlewareConexao,
}) {
  final List<RequestHandler> middlewares = <RequestHandler>[
    middlewareConexao,
  ];

  app.get(
    '/api/v1/saude',
    statusController.obter,
    middleware: middlewares,
  );
  app.get(
    '/api/v1/catalogos/resumo',
    catalogoController.resumo,
    middleware: middlewares,
  );
  app.get(
    '/api/v1/catalogos/tipos-procedimento',
    catalogoController.tiposProcedimento,
    middleware: middlewares,
  );
  app.get(
    '/api/v1/catalogos/series',
    catalogoController.series,
    middleware: middlewares,
  );
}
