import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Consulta cadastros públicos de referência do SIP sem interpretar permissões.
class SipReferenciaRepository {
  SipReferenciaRepository(this._connection);

  final Connection _connection;

  Future<List<SistemaSipResumo>> listarSistemasAtivos() async {
    final rows = await _connection
        .table(SistemaSipResumo.fqtn)
        .select(const <String>[
          SistemaSipResumo.idSistemaCol,
          SistemaSipResumo.siglaCol,
          SistemaSipResumo.descricaoCol,
          SistemaSipResumo.ativoCol,
        ])
        .where(
          SistemaSipResumo.ativoCol,
          '=',
          SeiCoreUtils.boolParaSimNao(true),
        )
        .orderBy(SistemaSipResumo.idSistemaCol, 'asc')
        .get();
    return rows
        .map((Map<String, dynamic> row) => SistemaSipResumo.fromMap(row))
        .toList(growable: false);
  }
}
