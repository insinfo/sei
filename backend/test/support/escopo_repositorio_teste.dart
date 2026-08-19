import 'package:angel3_container/angel3_container.dart';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/sei_backend.dart';

/// Cria um contêiner-filho de teste com uma conexão registrada para repository.
///
/// O helper exercita as mesmas fábricas usadas pela API sem repetir
/// `Repositorio(connection)` nos testes de integração.
class EscopoRepositorioTeste {
  EscopoRepositorioTeste._(
    this._app,
    this._servicoConexao,
    this._connection,
    this._container,
  );

  final Angel _app;
  final ServicoConexao _servicoConexao;
  final Connection _connection;
  final Container _container;

  static Future<EscopoRepositorioTeste> criarSei() async {
    final Angel app = criarAplicacao(SeiAppConfig.carregar());
    final SeiDatabaseService servicoConexao =
        app.container.make<SeiDatabaseService>();
    return _criar(app, servicoConexao);
  }

  static Future<EscopoRepositorioTeste> criarSip() async {
    final Angel app = criarAplicacao(SeiAppConfig.carregar());
    final SipDatabaseService servicoConexao =
        app.container.make<SipDatabaseService>();
    return _criar(app, servicoConexao);
  }

  static Future<EscopoRepositorioTeste> _criar(
    Angel app,
    ServicoConexao servicoConexao,
  ) async {
    final Connection connection = await servicoConexao.conectar();
    final Container container = app.container.createChild();
    container.registerSingleton<Connection>(connection);
    return EscopoRepositorioTeste._(
      app,
      servicoConexao,
      connection,
      container,
    );
  }

  /// Resolve um repository pela mesma factory registrada no DI de produção.
  R make<R>() => _container.make<R>();

  /// Executa o callback dentro de uma transação sempre revertida ao final.
  ///
  /// A Base de Referência não pode ganhar dado sintético, mas as consultas
  /// precisam ser exercitadas contra linhas reais. A transação resolve os dois
  /// lados: a fixture é inserida, as asserções rodam e o `rollback` é forçado
  /// por uma exceção sentinela, de modo que nada é confirmado no banco.
  ///
  /// O escopo recebido é um contêiner-filho com a conexão da transação
  /// registrada, portanto os repositórios saem das mesmas fábricas do DI de
  /// produção e enxergam a fixture.
  Future<void> emTransacaoRevertida(
    Future<void> Function(Container escopo, Connection conexao) callback,
  ) async {
    try {
      await _connection.transaction((Connection contexto) async {
        final Container escopo = _app.container.createChild();
        escopo.registerSingleton<Connection>(contexto);
        await callback(escopo, contexto);
        throw const _ReversaoDaFixture();
      });
    } on _ReversaoDaFixture {
      return;
    }
  }

  /// Libera a conexão e os recursos de infraestrutura do escopo de teste.
  Future<void> dispose() async {
    if (!_servicoConexao.usaPool) {
      await _connection.disconnect();
    }
    await _servicoConexao.dispose();
    await _app.close();
  }
}

/// Sentinela que força o `rollback` da transação de fixture.
///
/// Ela não representa erro: é o mecanismo que garante que a Base de
/// Referência volte exatamente ao estado anterior ao teste.
class _ReversaoDaFixture implements Exception {
  const _ReversaoDaFixture();
}
