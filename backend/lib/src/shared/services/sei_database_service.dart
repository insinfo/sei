import 'package:eloquent/eloquent.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_backend/src/shared/services/servico_conexao.dart';

/// Centraliza a criação, o reuso e o encerramento de conexões PostgreSQL.
class SeiDatabaseService implements ServicoConexao {
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
  @override
  Future<Connection> conectar() async {
    return _manager.getConnection('default');
  }

  /// Indica se o gerenciador mantém conexões reutilizáveis no pool.
  @override
  bool get usaPool => _config.dbUsePool;

  /// Encerra o pool mantido pelo processo durante o desligamento da API.
  @override
  Future<void> dispose() async {
    if (_config.dbUsePool) {
      await _manager.getDatabaseManager().disconnect('default');
    }
  }
}
