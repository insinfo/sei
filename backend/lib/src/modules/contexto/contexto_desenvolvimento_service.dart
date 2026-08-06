import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_backend/src/db/sei_database_service.dart';
import 'package:sei_backend/src/modules/contexto/contexto_desenvolvimento_repository.dart';
import 'package:sei_core/sei_core.dart';

/// Fornece a identidade e as unidades de referência para desenvolvimento local.
class ContextoDesenvolvimentoService {
  ContextoDesenvolvimentoService(this._databaseService, this._config);

  final SeiDatabaseService _databaseService;
  final SeiAppConfig _config;

  Future<ContextoDesenvolvimento> obter() {
    return _databaseService.executar(
      (connection) => ContextoDesenvolvimentoRepository(
        connection,
      ).obterPorSiglaUsuario(_config.desenvolvimentoUsuarioSigla),
    );
  }
}
