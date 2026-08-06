import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Consulta os catálogos nativos do SEI sem alterar a base de referência.
class CatalogoRepository {
  CatalogoRepository(this._connection);

  final Connection _connection;

  Future<CatalogoResumo> obterResumo() async {
    final int tiposProcedimento =
        await _connection.table(TipoProcedimento.fqtn).count();
    final int series = await _connection.table(Serie.fqtn).count();
    final int assuntos =
        await _connection.table(CatalogoResumo.assuntoFqtn).count();
    final int hipotesesLegais =
        await _connection.table(CatalogoResumo.hipoteseLegalFqtn).count();
    final int extensoesArquivo =
        await _connection.table(CatalogoResumo.arquivoExtensaoFqtn).count();
    final int unidades =
        await _connection.table(CatalogoResumo.unidadeFqtn).count();
    final int usuarios =
        await _connection.table(CatalogoResumo.usuarioFqtn).count();

    return CatalogoResumo(
      tiposProcedimento: tiposProcedimento,
      series: series,
      assuntos: assuntos,
      hipotesesLegais: hipotesesLegais,
      extensoesArquivo: extensoesArquivo,
      unidades: unidades,
      usuarios: usuarios,
    );
  }

  Future<List<TipoProcedimento>> listarTiposProcedimento({
    bool somenteAtivos = true,
  }) async {
    final query = _connection.table(TipoProcedimento.fqtn).select([
      TipoProcedimento.idCol,
      TipoProcedimento.idHipoteseLegalSugestaoCol,
      TipoProcedimento.nomeCol,
      TipoProcedimento.descricaoCol,
      TipoProcedimento.ativoCol,
      TipoProcedimento.nivelAcessoSugestaoCol,
      TipoProcedimento.internoCol,
      TipoProcedimento.ouvidoriaCol,
      TipoProcedimento.individualCol,
      TipoProcedimento.grauSigiloSugestaoCol,
      TipoProcedimento.idPlanoTrabalhoCol,
      TipoProcedimento.ouvidoriaAnonimoCol,
    ]);
    if (somenteAtivos) {
      query.where(
          TipoProcedimento.ativoCol, '=', SeiCoreUtils.boolParaSimNao(true));
    }

    final rows = await query.orderBy(TipoProcedimento.nomeCol, 'asc').get();
    return rows
        .map((Map<String, dynamic> row) => TipoProcedimento.fromMap(row))
        .toList(growable: false);
  }

  Future<List<Serie>> listarSeries({bool somenteAtivas = true}) async {
    final query = _connection.table(Serie.fqtn).select(
      const <String>[
        Serie.idCol,
        Serie.idModeloEdocCol,
        Serie.idGrupoSerieCol,
        Serie.idModeloCol,
        Serie.idTipoFormularioCol,
        Serie.nomeCol,
        Serie.descricaoCol,
        Serie.ativoCol,
        Serie.interessadoCol,
        Serie.destinatarioCol,
        Serie.numeracaoCol,
        Serie.assinaturaPublicacaoCol,
        Serie.aplicabilidadeCol,
        Serie.internoCol,
        Serie.usuarioExternoCol,
        Serie.valorMonetarioCol,
      ],
    );
    if (somenteAtivas) {
      query.where(Serie.ativoCol, '=', SeiCoreUtils.boolParaSimNao(true));
    }

    final rows = await query.orderBy(Serie.nomeCol, 'asc').get();
    return rows
        .map((Map<String, dynamic> row) => Serie.fromMap(row))
        .toList(growable: false);
  }
}
