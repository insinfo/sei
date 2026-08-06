import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_backend/src/db/sei_database_service.dart';
import 'package:sei_backend/src/db/sip_database_service.dart';
import 'package:sei_backend/src/modules/catalogos/catalogo_controller.dart';
import 'package:sei_backend/src/modules/catalogos/catalogo_service.dart';
import 'package:sei_backend/src/modules/catalogos/status_ambiente_controller.dart';
import 'package:sei_backend/src/modules/contexto/contexto_desenvolvimento_controller.dart';
import 'package:sei_backend/src/modules/contexto/contexto_desenvolvimento_service.dart';
import 'package:sei_backend/src/modules/controle_processos/controle_processos_controller.dart';
import 'package:sei_backend/src/modules/controle_processos/controle_processos_service.dart';
import 'package:sei_backend/src/modules/sip/sip_referencia_controller.dart';
import 'package:sei_backend/src/modules/sip/sip_referencia_service.dart';

/// Cria a aplicação Angel com as rotas públicas somente leitura iniciais.
Angel criarAplicacao(SeiAppConfig config) {
  final app = Angel();
  final databaseService = SeiDatabaseService(config);
  final sipDatabaseService = SipDatabaseService(config);
  final catalogoService = CatalogoService(databaseService);
  final catalogoController = CatalogoController(catalogoService);
  final statusController = StatusAmbienteController(config, catalogoService);
  final contextoDesenvolvimentoService = ContextoDesenvolvimentoService(
    databaseService,
    config,
  );
  final contextoDesenvolvimentoController = ContextoDesenvolvimentoController(
    contextoDesenvolvimentoService,
  );
  final controleProcessosService = ControleProcessosService(databaseService);
  final controleProcessosController =
      ControleProcessosController(controleProcessosService);
  final sipReferenciaService = SipReferenciaService(sipDatabaseService);
  final sipReferenciaController = SipReferenciaController(sipReferenciaService);

  app.get('/api/v1/saude', statusController.obter);
  app.get(
    '/api/v1/contexto/desenvolvimento',
    contextoDesenvolvimentoController.obter,
  );
  app.get('/api/v1/catalogos/resumo', catalogoController.resumo);
  app.get(
    '/api/v1/catalogos/tipos-procedimento',
    catalogoController.tiposProcedimento,
  );
  app.get('/api/v1/catalogos/series', catalogoController.series);
  app.get('/api/v1/sip/referencia/sistemas', sipReferenciaController.sistemas);
  app.get(
    '/api/v1/controle-processos/recebidos',
    controleProcessosController.recebidos,
  );
  app.get(
    '/api/v1/controle-processos/gerados',
    controleProcessosController.gerados,
  );
  app.shutdownHooks.add((_) => databaseService.dispose());
  app.shutdownHooks.add((_) => sipDatabaseService.dispose());
  return app;
}
