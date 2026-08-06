import 'package:sei_backend/src/db/sei_database_service.dart';
import 'package:sei_backend/src/modules/catalogos/catalogo_repository.dart';
import 'package:sei_core/sei_core.dart';

/// Orquestra a leitura dos catálogos disponibilizados pela primeira API SEI.
class CatalogoService {
  CatalogoService(this._databaseService);

  final SeiDatabaseService _databaseService;

  Future<CatalogoResumo> obterResumo() async {
    return _databaseService.executar(
      (connection) => CatalogoRepository(connection).obterResumo(),
    );
  }

  Future<List<TipoProcedimento>> listarTiposProcedimento({
    bool somenteAtivos = true,
  }) async {
    return _databaseService.executar(
      (connection) => CatalogoRepository(connection).listarTiposProcedimento(
        somenteAtivos: somenteAtivos,
      ),
    );
  }

  Future<List<Serie>> listarSeries({bool somenteAtivas = true}) async {
    return _databaseService.executar(
      (connection) => CatalogoRepository(connection).listarSeries(
        somenteAtivas: somenteAtivas,
      ),
    );
  }
}
