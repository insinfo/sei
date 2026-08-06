import 'package:eloquent/eloquent.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';

typedef AcaoBancoSip<T> = Future<T> Function(Connection connection);

/// Centraliza as conexões somente leitura com a Base de Referência do SIP.
class SipDatabaseService {
  SipDatabaseService(this._config);

  final SeiAppConfig _config;

  late final Manager _manager = Manager()
    ..addConnection(_configuracaoBase, 'default');

  Map<String, dynamic> get _configuracaoBase => <String, dynamic>{
        'driver': 'pgsql',
        'driver_implementation': 'postgres',
        'host': _config.sipDbHost,
        'port': _config.sipDbPort,
        'database': _config.sipDbName,
        'username': _config.sipDbUser,
        'password': _config.sipDbPass,
        'charset': _config.sipDbCharset,
        'schema': _config.dbSchemas,
        'pool': _config.sipDbUsePool,
        'poolsize': _config.sipDbPoolSize,
        'timezone': 'America/Sao_Paulo',
        'application_name': _config.sipApplicationName,
      };

  /// Obtém uma conexão configurada para o banco de referência do SIP.
  Future<Connection> conectar() async {
    return _manager.getConnection('default');
  }

  /// Executa uma leitura e encerra conexões sem pool ao final.
  Future<T> executar<T>(AcaoBancoSip<T> acao) async {
    final connection = await conectar();
    try {
      return await acao(connection);
    } finally {
      if (!_config.sipDbUsePool) {
        await connection.disconnect();
      }
    }
  }

  /// Encerra o pool SIP mantido pelo processo durante o desligamento da API.
  Future<void> dispose() async {
    if (_config.sipDbUsePool) {
      await _manager.getDatabaseManager().disconnect('default');
    }
  }
}
