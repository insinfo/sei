import 'package:sei_backend/src/db/sei_database_service.dart';
import 'package:sei_backend/src/modules/controle_processos/controle_processos_repository.dart';
import 'package:sei_core/sei_core.dart';

/// Orquestra a leitura paginada de atividades abertas por unidade.
class ControleProcessosService {
  ControleProcessosService(this._databaseService);

  final SeiDatabaseService _databaseService;

  Future<PaginaProcessosRecebidos> listarRecebidos(
    ControleProcessosFiltro filtro,
  ) async {
    if (filtro.modo != ControleProcessosModo.recebidos) {
      throw ArgumentError.value(
        filtro.modo,
        ControleProcessosFiltro.modoCol,
        'A consulta de recebidos requer o modo recebidos.',
      );
    }
    return _listar(filtro);
  }

  /// Lista atividades iniciadas pela unidade, exibidas na aba Gerados do SEI.
  Future<PaginaProcessosRecebidos> listarGerados(
    ControleProcessosFiltro filtro,
  ) async {
    if (filtro.modo != ControleProcessosModo.gerados) {
      throw ArgumentError.value(
        filtro.modo,
        ControleProcessosFiltro.modoCol,
        'A consulta de gerados requer o modo gerados.',
      );
    }
    return _listar(filtro);
  }

  Future<PaginaProcessosRecebidos> _listar(
    ControleProcessosFiltro filtro,
  ) {
    return _databaseService.executar(
      (connection) => ControleProcessosRepository(connection).listar(filtro),
    );
  }
}
