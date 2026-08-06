import 'package:eloquent/eloquent.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';

typedef AcaoBanco<T> = Future<T> Function(Connection connection);

/// Centraliza a criação, o reuso e o encerramento de conexões PostgreSQL.
class SeiDatabaseService {
  SeiDatabaseService(this._config);

  final SeiAppConfig _config;

  late final Manager _manager = Manager()
    ..addConnection(_configuracaoBase, 'default');

  Map<String, dynamic> get _configuracaoBase => <String, dynamic>{
        'driver': 'pgsql',
        'driver_implementation': 'postgres',
        'host': _config.dbHost,
        'port': _config.dbPort,
        'database': _config.dbName,
        'username': _config.dbUser,
        'password': _config.dbPass,
        'charset': _config.dbCharset,
        'schema': _config.dbSchemas,
        'pool': _config.dbUsePool,
        'poolsize': _config.dbPoolSize,
        'timezone': 'America/Sao_Paulo',
        'application_name': _config.applicationName,
      };

  /// Obtém uma conexão configurada para o banco de referência do SEI.
  Future<Connection> conectar() async {
    return _manager.getConnection('default');
  }

  /// Executa uma ação com conexão e encerra conexões sem pool ao final.
  Future<T> executar<T>(AcaoBanco<T> acao) async {
    final connection = await conectar();
    try {
      return await acao(connection);
    } finally {
      if (!_config.dbUsePool) {
        await connection.disconnect();
      }
    }
  }

  /// Encerra o pool mantido pelo processo durante o desligamento da API.
  Future<void> dispose() async {
    if (_config.dbUsePool) {
      await _manager.getDatabaseManager().disconnect('default');
    }
  }
}
