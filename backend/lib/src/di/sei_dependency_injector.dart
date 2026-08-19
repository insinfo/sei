import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_backend/src/modules/autenticacao/controllers/autenticacao_controller.dart';
import 'package:sei_backend/src/modules/autenticacao/repositories/autenticacao_repository.dart';
import 'package:sei_backend/src/modules/autenticacao/services/autenticacao_service.dart';
import 'package:sei_backend/src/modules/autenticacao/services/autenticacao_token_service.dart';
import 'package:sei_backend/src/modules/catalogos/controllers/catalogo_controller.dart';
import 'package:sei_backend/src/modules/catalogos/controllers/status_ambiente_controller.dart';
import 'package:sei_backend/src/modules/catalogos/repositories/catalogo_repository.dart';
import 'package:sei_backend/src/modules/contexto/controllers/contexto_desenvolvimento_controller.dart';
import 'package:sei_backend/src/modules/contexto/repositories/contexto_desenvolvimento_repository.dart';
import 'package:sei_backend/src/modules/controle_processos/controllers/controle_processos_controller.dart';
import 'package:sei_backend/src/modules/controle_processos/repositories/controle_processos_repository.dart';
import 'package:sei_backend/src/modules/oidc/controllers/oidc_controller.dart';
import 'package:sei_backend/src/modules/oidc/controllers/oidc_login_controller.dart';
import 'package:sei_backend/src/modules/oidc/repositories/oidc_cliente_repository.dart';
import 'package:sei_backend/src/modules/oidc/repositories/oidc_codigo_autorizacao_repository.dart';
import 'package:sei_backend/src/modules/oidc/repositories/oidc_token_renovacao_repository.dart';
import 'package:sei_backend/src/modules/oidc/services/oidc_service.dart';
import 'package:sei_backend/src/modules/orgaos/controllers/orgao_controller.dart';
import 'package:sei_backend/src/modules/orgaos/repositories/orgao_repository.dart';
import 'package:sei_backend/src/modules/orgaos/services/orgao_service.dart';
import 'package:sei_backend/src/modules/processos/controllers/processo_detalhe_controller.dart';
import 'package:sei_backend/src/modules/processos/repositories/processo_detalhe_repository.dart';
import 'package:sei_backend/src/modules/sip/controllers/sip_referencia_controller.dart';
import 'package:sei_backend/src/modules/sip/repositories/sip_referencia_repository.dart';
import 'package:sei_backend/src/modules/unidades/controllers/unidade_controller.dart';
import 'package:sei_backend/src/modules/unidades/repositories/unidade_repository.dart';
import 'package:sei_backend/src/modules/unidades/services/unidade_service.dart';
import 'package:sei_backend/src/modules/usuarios/controllers/usuario_controller.dart';
import 'package:sei_backend/src/modules/usuarios/repositories/usuario_repository.dart';
import 'package:sei_backend/src/modules/usuarios/services/usuario_service.dart';
import 'package:sei_backend/src/shared/middlewares/auth_middleware.dart';
import 'package:sei_backend/src/shared/middlewares/conexao_banco_middleware.dart';
import 'package:sei_backend/src/shared/repositories/contato_repository.dart';
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

    final AutenticacaoTokenService tokenService = AutenticacaoTokenService(
      config.jwtSecret,
      duracao: config.jwtDuracao,
    );
    app.container.registerSingleton<AutenticacaoTokenService>(tokenService);
    app.container.registerSingleton<AuthMiddleware>(
      AuthMiddleware(tokenService),
    );

    // Carrega o par de chaves RSA uma única vez na subida do processo —
    // falha rápido e explícito se `gera_chave_oidc.dart` ainda não rodou.
    app.container.registerSingleton<OidcService>(OidcService(config));

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
    app.container.registerFactory<ContatoRepository>(
      (container) => ContatoRepository(container.make<Connection>()),
    );
    app.container.registerFactory<OrgaoRepository>(
      (container) => OrgaoRepository(container.make<Connection>()),
    );
    app.container.registerFactory<UnidadeRepository>(
      (container) => UnidadeRepository(container.make<Connection>()),
    );
    app.container.registerFactory<UsuarioRepository>(
      (container) => UsuarioRepository(container.make<Connection>()),
    );
    app.container.registerFactory<AutenticacaoRepository>(
      (container) => AutenticacaoRepository(container.make<Connection>()),
    );
    app.container.registerFactory<OidcClienteRepository>(
      (container) => OidcClienteRepository(container.make<Connection>()),
    );
    app.container.registerFactory<OidcCodigoAutorizacaoRepository>(
      (container) =>
          OidcCodigoAutorizacaoRepository(container.make<Connection>()),
    );
    app.container.registerFactory<OidcTokenRenovacaoRepository>(
      (container) => OidcTokenRenovacaoRepository(container.make<Connection>()),
    );

    app.container.registerFactory<OrgaoService>(
      (container) => OrgaoService(
        container.make<Connection>(),
        container.make<OrgaoRepository>(),
        container.make<ContatoRepository>(),
      ),
    );
    app.container.registerFactory<UnidadeService>(
      (container) => UnidadeService(
        container.make<Connection>(),
        container.make<UnidadeRepository>(),
        container.make<ContatoRepository>(),
        container.make<OrgaoRepository>(),
      ),
    );
    app.container.registerFactory<UsuarioService>(
      (container) => UsuarioService(
        container.make<Connection>(),
        container.make<UsuarioRepository>(),
        container.make<ContatoRepository>(),
        container.make<OrgaoRepository>(),
      ),
    );
    app.container.registerFactory<AutenticacaoService>(
      (container) => AutenticacaoService(
        container.make<OrgaoRepository>(),
        container.make<AutenticacaoRepository>(),
        container.make<AutenticacaoTokenService>(),
      ),
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
    app.container.registerSingleton<AutenticacaoController>(
      AutenticacaoController(),
    );
    app.container.registerSingleton<OidcController>(OidcController());
    app.container.registerSingleton<OidcLoginController>(
      OidcLoginController(),
    );
    app.container.registerSingleton<OrgaoController>(OrgaoController());
    app.container.registerSingleton<UnidadeController>(UnidadeController());
    app.container.registerSingleton<UsuarioController>(UsuarioController());

    app.shutdownHooks.add((Angel _) async {
      await bancoSei.dispose();
      await bancoSip.dispose();
    });
  }
}
