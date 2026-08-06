import 'package:eloquent/eloquent.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_backend/src/shared/services/servico_conexao.dart';

/// Centraliza as conexões somente leitura com a Base de Referência do SIP.
class SipDatabaseService implements ServicoConexao {
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
  @override
  Future<Connection> conectar() async {
    return _manager.getConnection('default');
  }

  /// Indica se o gerenciador mantém conexões reutilizáveis no pool.
  @override
  bool get usaPool => _config.sipDbUsePool;

  /// Encerra o pool SIP mantido pelo processo durante o desligamento da API.
  @override
  Future<void> dispose() async {
    if (_config.sipDbUsePool) {
      await _manager.getDatabaseManager().disconnect('default');
    }
  }
}
