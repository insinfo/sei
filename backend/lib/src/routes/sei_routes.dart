import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/catalogos/controllers/catalogo_controller.dart';
import 'package:sei_backend/src/modules/catalogos/controllers/status_ambiente_controller.dart';
import 'package:sei_backend/src/modules/catalogos/routes/catalogos_routes.dart';
import 'package:sei_backend/src/modules/contexto/controllers/contexto_desenvolvimento_controller.dart';
import 'package:sei_backend/src/modules/contexto/routes/contexto_routes.dart';
import 'package:sei_backend/src/modules/controle_processos/controllers/controle_processos_controller.dart';
import 'package:sei_backend/src/modules/controle_processos/routes/controle_processos_routes.dart';
import 'package:sei_backend/src/modules/processos/controllers/processo_detalhe_controller.dart';
import 'package:sei_backend/src/modules/processos/routes/processos_routes.dart';
import 'package:sei_backend/src/modules/sip/controllers/sip_referencia_controller.dart';
import 'package:sei_backend/src/modules/sip/routes/sip_referencia_routes.dart';
import 'package:sei_backend/src/shared/middlewares/conexao_banco_middleware.dart';
import 'package:sei_backend/src/shared/middlewares/cors_middleware.dart';

/// Registra as rotas HTTP da API SEI e delega cada uma ao controlador próprio.
void registrarRotasSei(Angel app) {
  app.fallback(corsMiddleware);
  final MiddlewareConexaoSei middlewareConexaoSei =
      app.container.make<MiddlewareConexaoSei>();
  final MiddlewareConexaoSip middlewareConexaoSip =
      app.container.make<MiddlewareConexaoSip>();

  registrarRotasCatalogos(
    app,
    statusController: app.container.make<StatusAmbienteController>(),
    catalogoController: app.container.make<CatalogoController>(),
    middlewareConexao: middlewareConexaoSei.executar,
  );
  registrarRotasContexto(
    app,
    app.container.make<ContextoDesenvolvimentoController>(),
    middlewareConexao: middlewareConexaoSei.executar,
  );
  registrarRotasControleProcessos(
    app,
    app.container.make<ControleProcessosController>(),
    middlewareConexao: middlewareConexaoSei.executar,
  );
  registrarRotasProcessos(
    app,
    app.container.make<ProcessoDetalheController>(),
    middlewareConexao: middlewareConexaoSei.executar,
  );
  registrarRotasSipReferencia(
    app,
    app.container.make<SipReferenciaController>(),
    middlewareConexao: middlewareConexaoSip.executar,
  );
}
