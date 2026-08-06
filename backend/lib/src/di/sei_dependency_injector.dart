import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_backend/src/modules/catalogos/controllers/catalogo_controller.dart';
import 'package:sei_backend/src/modules/catalogos/controllers/status_ambiente_controller.dart';
import 'package:sei_backend/src/modules/catalogos/repositories/catalogo_repository.dart';
import 'package:sei_backend/src/modules/contexto/controllers/contexto_desenvolvimento_controller.dart';
import 'package:sei_backend/src/modules/contexto/repositories/contexto_desenvolvimento_repository.dart';
import 'package:sei_backend/src/modules/controle_processos/controllers/controle_processos_controller.dart';
import 'package:sei_backend/src/modules/controle_processos/repositories/controle_processos_repository.dart';
import 'package:sei_backend/src/modules/processos/controllers/processo_detalhe_controller.dart';
import 'package:sei_backend/src/modules/processos/repositories/processo_detalhe_repository.dart';
import 'package:sei_backend/src/modules/sip/controllers/sip_referencia_controller.dart';
import 'package:sei_backend/src/modules/sip/repositories/sip_referencia_repository.dart';
import 'package:sei_backend/src/shared/middlewares/conexao_banco_middleware.dart';
import 'package:sei_backend/src/shared/services/sei_database_service.dart';
import 'package:sei_backend/src/shared/services/sip_database_service.dart';

/// Registra dependências globais e fábricas resolvidas no escopo da requisição.
///
/// Cada repositório é uma fábrica do Angel e recebe a [Connection] que o
/// middleware registrou no contêiner filho da requisição. Portanto, os
/// controladores usam `request.make<Repositorio>()` sem construir
/// `Repositorio(connection)` e sem compartilhar conexões entre requisições.
class SeiDependencyInjector {
  static void configurar(Angel app, SeiAppConfig config) {
    final SeiDatabaseService bancoSei = SeiDatabaseService(config);
    final SipDatabaseService bancoSip = SipDatabaseService(config);

    app.container.registerSingleton<SeiAppConfig>(config);
    app.container.registerSingleton<SeiDatabaseService>(bancoSei);
    app.container.registerSingleton<SipDatabaseService>(bancoSip);
    app.container.registerSingleton<MiddlewareConexaoSei>(
      MiddlewareConexaoSei(bancoSei),
    );
    app.container.registerSingleton<MiddlewareConexaoSip>(
      MiddlewareConexaoSip(bancoSip),
    );

    app.container.registerFactory<CatalogoRepository>(
      (container) => CatalogoRepository(container.make<Connection>()),
    );
    app.container.registerFactory<ContextoDesenvolvimentoRepository>(
      (container) => ContextoDesenvolvimentoRepository(
        container.make<Connection>(),
      ),
    );
    app.container.registerFactory<ControleProcessosRepository>(
      (container) => ControleProcessosRepository(container.make<Connection>()),
    );
    app.container.registerFactory<ProcessoDetalheRepository>(
      (container) => ProcessoDetalheRepository(container.make<Connection>()),
    );
    app.container.registerFactory<SipReferenciaRepository>(
      (container) => SipReferenciaRepository(container.make<Connection>()),
    );

    app.container.registerSingleton<StatusAmbienteController>(
      StatusAmbienteController(),
    );
    app.container.registerSingleton<ContextoDesenvolvimentoController>(
      ContextoDesenvolvimentoController(),
    );
    app.container.registerSingleton<CatalogoController>(CatalogoController());
    app.container.registerSingleton<ControleProcessosController>(
      ControleProcessosController(),
    );
    app.container.registerSingleton<ProcessoDetalheController>(
      ProcessoDetalheController(),
    );
    app.container.registerSingleton<SipReferenciaController>(
      SipReferenciaController(),
    );

    app.shutdownHooks.add((Angel _) async {
      await bancoSei.dispose();
      await bancoSip.dispose();
    });
  }
}
