import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Consulta atividades abertas sem alterar o banco de referência do SEI.
class ControleProcessosRepository {
  ControleProcessosRepository(this._connection);

  final Connection _connection;

  Future<PaginaProcessosRecebidos> listar(
    ControleProcessosFiltro filtro,
  ) async {
    final int total = await _connection
        .table(ProcessoRecebidoItem.atividadeFqtn)
        .where(
          ProcessoRecebidoItem.atividadeIdUnidadeFqCol,
          '=',
          filtro.idUnidade,
        )
        .whereNull(ProcessoRecebidoItem.atividadeConclusaoFqCol)
        .where(
          ProcessoRecebidoItem.atividadeInicialFqCol,
          '=',
          filtro.modo.valorAtividadeInicial,
        )
        .count();

    final query = _connection
        .table(ProcessoRecebidoItem.atividadeFqtn)
        .join(
          ProcessoRecebidoItem.protocoloFqtn,
          ProcessoRecebidoItem.protocoloIdFqCol,
          '=',
          ProcessoRecebidoItem.atividadeIdProtocoloFqCol,
        )
        .join(
          ProcessoRecebidoItem.procedimentoFqtn,
          ProcessoRecebidoItem.procedimentoIdFqCol,
          '=',
          ProcessoRecebidoItem.protocoloIdFqCol,
        )
        .join(
          ProcessoRecebidoItem.tipoProcedimentoFqtn,
          ProcessoRecebidoItem.tipoProcedimentoIdFqCol,
          '=',
          ProcessoRecebidoItem.procedimentoIdTipoFqCol,
        )
        .join(
          ProcessoRecebidoItem.unidadeFqtn,
          ProcessoRecebidoItem.unidadeIdFqCol,
          '=',
          ProcessoRecebidoItem.atividadeIdUnidadeFqCol,
        )
        .join(
          ProcessoRecebidoItem.unidadeOrigemAliasTable,
          ProcessoRecebidoItem.unidadeOrigemIdFqCol,
          '=',
          ProcessoRecebidoItem.atividadeIdUnidadeOrigemFqCol,
        )
        .leftJoin(
          ProcessoRecebidoItem.tarefaFqtn,
          ProcessoRecebidoItem.tarefaIdFqCol,
          '=',
          ProcessoRecebidoItem.atividadeIdTarefaFqCol,
        )
        .leftJoin(
          ProcessoRecebidoItem.usuarioAtribuicaoAliasTable,
          ProcessoRecebidoItem.usuarioAtribuicaoIdFqCol,
          '=',
          ProcessoRecebidoItem.atividadeIdUsuarioAtribuicaoFqCol,
        )
        .leftJoin(
          ProcessoRecebidoItem.usuarioAtividadeAliasTable,
          ProcessoRecebidoItem.usuarioAtividadeIdFqCol,
          '=',
          ProcessoRecebidoItem.atividadeIdUsuarioFqCol,
        )
        .where(
          ProcessoRecebidoItem.atividadeIdUnidadeFqCol,
          '=',
          filtro.idUnidade,
        )
        .whereNull(ProcessoRecebidoItem.atividadeConclusaoFqCol)
        .where(
          ProcessoRecebidoItem.atividadeInicialFqCol,
          '=',
          filtro.modo.valorAtividadeInicial,
        );

    query.selectRaw('''
      ${ProcessoRecebidoItem.atividadeIdFqCol} AS ${ProcessoRecebidoItem.idAtividadeCol},
      ${ProcessoRecebidoItem.atividadeIdProtocoloFqCol} AS ${ProcessoRecebidoItem.idProcessoCol},
      ${ProcessoRecebidoItem.protocoloFormatadoFqCol} AS ${ProcessoRecebidoItem.protocoloFormatadoCol},
      ${ProcessoRecebidoItem.protocoloDescricaoFqCol} AS ${ProcessoRecebidoItem.descricaoCol},
      ${ProcessoRecebidoItem.protocoloEstadoFqCol} AS ${ProcessoRecebidoItem.estadoProtocoloCol},
      ${ProcessoRecebidoItem.procedimentoIdTipoFqCol} AS ${ProcessoRecebidoItem.idTipoProcedimentoCol},
      ${ProcessoRecebidoItem.tipoProcedimentoNomeFqCol} AS ${ProcessoRecebidoItem.tipoProcedimentoNomeCol},
      ${ProcessoRecebidoItem.atividadeIdUnidadeFqCol} AS ${ProcessoRecebidoItem.idUnidadeCol},
      ${ProcessoRecebidoItem.unidadeSiglaFqCol} AS ${ProcessoRecebidoItem.unidadeSiglaCol},
      ${ProcessoRecebidoItem.unidadeDescricaoFqCol} AS ${ProcessoRecebidoItem.unidadeDescricaoCol},
      ${ProcessoRecebidoItem.atividadeIdUnidadeOrigemFqCol} AS ${ProcessoRecebidoItem.idUnidadeOrigemCol},
      ${ProcessoRecebidoItem.unidadeOrigemSiglaFqCol} AS ${ProcessoRecebidoItem.unidadeOrigemSiglaCol},
      ${ProcessoRecebidoItem.unidadeOrigemDescricaoFqCol} AS ${ProcessoRecebidoItem.unidadeOrigemDescricaoCol},
      ${ProcessoRecebidoItem.atividadeIdTarefaFqCol} AS ${ProcessoRecebidoItem.idTarefaCol},
      ${ProcessoRecebidoItem.tarefaNomeFqCol} AS ${ProcessoRecebidoItem.tarefaNomeCol},
      ${ProcessoRecebidoItem.atividadeIdUsuarioAtribuicaoFqCol} AS ${ProcessoRecebidoItem.idUsuarioAtribuicaoCol},
      ${ProcessoRecebidoItem.usuarioAtribuicaoNomeFqCol} AS ${ProcessoRecebidoItem.usuarioAtribuicaoNomeCol},
      ${ProcessoRecebidoItem.atividadeIdUsuarioFqCol} AS ${ProcessoRecebidoItem.idUsuarioAtividadeCol},
      ${ProcessoRecebidoItem.usuarioAtividadeNomeFqCol} AS ${ProcessoRecebidoItem.usuarioAtividadeNomeCol},
      ${ProcessoRecebidoItem.atividadeAberturaFqCol} AS ${ProcessoRecebidoItem.dataAberturaCol},
      ${ProcessoRecebidoItem.atividadePrazoFqCol} AS ${ProcessoRecebidoItem.dataPrazoCol},
      ${ProcessoRecebidoItem.atividadeInicialFqCol} AS ${ProcessoRecebidoItem.atividadeInicialCol},
      ${ProcessoRecebidoItem.atividadeTipoVisualizacaoFqCol} AS ${ProcessoRecebidoItem.tipoVisualizacaoCol}
    ''');
    query
      ..orderBy(ProcessoRecebidoItem.atividadeAberturaFqCol, 'desc')
      ..orderBy(ProcessoRecebidoItem.atividadeIdFqCol, 'desc')
      ..limit(filtro.limite)
      ..offset(filtro.deslocamento);

    final rows = await query.get();
    final itens = rows
        .map(
          (Map<String, dynamic> row) => ProcessoRecebidoItem.fromMap(row),
        )
        .toList(growable: false);
    return PaginaProcessosRecebidos(
      itens: itens,
      total: total,
      limite: filtro.limite,
      deslocamento: filtro.deslocamento,
    );
  }
}
