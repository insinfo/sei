import 'dart:convert';

import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Consulta projeções somente leitura usadas no detalhe de um processo SEI.
///
/// A árvore e o histórico usam paginação por cursor para não executar
/// contagens nem varrer relações transacionais a cada página.
class ProcessoDetalheRepository {
  ProcessoDetalheRepository(this._connection);

  final Connection _connection;

  Future<ProcessoCabecalho?> obterCabecalho(int idProcesso) async {
    final row = await _connection
        .table(ProcessoCabecalho.procedimentoFqtn)
        .join(
            ProcessoCabecalho.protocoloFqtn,
            ProcessoCabecalho.protocoloIdFqCol,
            '=',
            ProcessoCabecalho.procedimentoIdFqCol)
        .join(
            ProcessoCabecalho.tipoProcedimentoFqtn,
            ProcessoCabecalho.tipoProcedimentoIdFqCol,
            '=',
            ProcessoCabecalho.procedimentoIdTipoFqCol)
        .join(ProcessoCabecalho.unidadeFqtn, ProcessoCabecalho.unidadeIdFqCol,
            '=', ProcessoCabecalho.protocoloIdUnidadeGeradoraFqCol)
        .join(ProcessoCabecalho.usuarioFqtn, ProcessoCabecalho.usuarioIdFqCol,
            '=', ProcessoCabecalho.protocoloIdUsuarioGeradorFqCol)
        .selectRaw('''
          ${ProcessoCabecalho.procedimentoIdFqCol} AS ${ProcessoCabecalho.idProcessoCol},
          ${ProcessoCabecalho.protocoloFormatadoFqCol} AS ${ProcessoCabecalho.protocoloFormatadoCol},
          ${ProcessoCabecalho.protocoloDescricaoFqCol} AS ${ProcessoCabecalho.descricaoCol},
          ${ProcessoCabecalho.protocoloEstadoFqCol} AS ${ProcessoCabecalho.estadoProtocoloCol},
          ${ProcessoCabecalho.protocoloGeracaoFqCol} AS ${ProcessoCabecalho.dataGeracaoCol},
          ${ProcessoCabecalho.protocoloNivelAcessoLocalFqCol} AS ${ProcessoCabecalho.nivelAcessoLocalCol},
          ${ProcessoCabecalho.protocoloNivelAcessoGlobalFqCol} AS ${ProcessoCabecalho.nivelAcessoGlobalCol},
          ${ProcessoCabecalho.protocoloEliminadoFqCol} AS ${ProcessoCabecalho.eliminadoCol},
          ${ProcessoCabecalho.procedimentoConclusaoFqCol} AS ${ProcessoCabecalho.dataConclusaoCol},
          ${ProcessoCabecalho.procedimentoIdTipoFqCol} AS ${ProcessoCabecalho.idTipoProcedimentoCol},
          ${ProcessoCabecalho.tipoProcedimentoNomeFqCol} AS ${ProcessoCabecalho.tipoProcedimentoNomeCol},
          ${ProcessoCabecalho.protocoloIdUnidadeGeradoraFqCol} AS ${ProcessoCabecalho.idUnidadeGeradoraCol},
          ${ProcessoCabecalho.unidadeSiglaFqCol} AS ${ProcessoCabecalho.unidadeGeradoraSiglaCol},
          ${ProcessoCabecalho.unidadeDescricaoFqCol} AS ${ProcessoCabecalho.unidadeGeradoraDescricaoCol},
          ${ProcessoCabecalho.protocoloIdUsuarioGeradorFqCol} AS ${ProcessoCabecalho.idUsuarioGeradorCol},
          ${ProcessoCabecalho.usuarioSiglaFqCol} AS ${ProcessoCabecalho.usuarioGeradorSiglaCol},
          ${ProcessoCabecalho.usuarioNomeFqCol} AS ${ProcessoCabecalho.usuarioGeradorNomeCol}
        ''')
        .where(ProcessoCabecalho.procedimentoIdFqCol, '=', idProcesso)
        .first();

    return row == null ? null : ProcessoCabecalho.fromMap(row);
  }

  Future<PaginaProcessoArvoreDocumentos> listarDocumentos(
    int idProcesso,
    ProcessoDetalhePaginacao paginacao,
  ) async {
    final cursor = paginacao.cursor == null
        ? null
        : _CursorArvoreDocumentos.decodificar(paginacao.cursor!);
    final query = _connection
        .table(ProcessoArvoreDocumentoItem.relacaoFqtn)
        .join(
          ProcessoArvoreDocumentoItem.documentoFqtn,
          ProcessoArvoreDocumentoItem.documentoIdFqCol,
          '=',
          ProcessoArvoreDocumentoItem.relacaoIdProtocoloFilhoFqCol,
        )
        .join(
          ProcessoArvoreDocumentoItem.protocoloFqtn,
          ProcessoArvoreDocumentoItem.protocoloIdFqCol,
          '=',
          ProcessoArvoreDocumentoItem.documentoIdFqCol,
        )
        .join(
          ProcessoArvoreDocumentoItem.serieFqtn,
          ProcessoArvoreDocumentoItem.serieIdFqCol,
          '=',
          ProcessoArvoreDocumentoItem.documentoIdSerieFqCol,
        )
        .join(
          ProcessoArvoreDocumentoItem.unidadeFqtn,
          ProcessoArvoreDocumentoItem.unidadeIdFqCol,
          '=',
          ProcessoArvoreDocumentoItem.documentoIdUnidadeResponsavelFqCol,
        )
        .selectRaw('''
          ${ProcessoArvoreDocumentoItem.relacaoIdFqCol} AS ${ProcessoArvoreDocumentoItem.idRelacaoCol},
          ${ProcessoArvoreDocumentoItem.documentoIdFqCol} AS ${ProcessoArvoreDocumentoItem.idDocumentoCol},
          ${ProcessoArvoreDocumentoItem.protocoloFormatadoFqCol} AS ${ProcessoArvoreDocumentoItem.protocoloFormatadoCol},
          ${ProcessoArvoreDocumentoItem.documentoNomeArvoreFqCol} AS ${ProcessoArvoreDocumentoItem.nomeArvoreCol},
          ${ProcessoArvoreDocumentoItem.documentoNumeroFqCol} AS ${ProcessoArvoreDocumentoItem.numeroCol},
          ${ProcessoArvoreDocumentoItem.serieNomeFqCol} AS ${ProcessoArvoreDocumentoItem.serieNomeCol},
          ${ProcessoArvoreDocumentoItem.documentoIdUnidadeResponsavelFqCol} AS ${ProcessoArvoreDocumentoItem.idUnidadeResponsavelCol},
          ${ProcessoArvoreDocumentoItem.unidadeSiglaFqCol} AS ${ProcessoArvoreDocumentoItem.unidadeResponsavelSiglaCol},
          ${ProcessoArvoreDocumentoItem.documentoEstadoFqCol} AS ${ProcessoArvoreDocumentoItem.estadoDocumentoCol},
          ${ProcessoArvoreDocumentoItem.protocoloNivelAcessoFqCol} AS ${ProcessoArvoreDocumentoItem.nivelAcessoCol},
          ${ProcessoArvoreDocumentoItem.documentoBloqueadoFqCol} AS ${ProcessoArvoreDocumentoItem.bloqueadoCol},
          ${ProcessoArvoreDocumentoItem.documentoArquivamentoFqCol} AS ${ProcessoArvoreDocumentoItem.arquivamentoCol},
          ${ProcessoArvoreDocumentoItem.documentoVersoesFqCol} AS ${ProcessoArvoreDocumentoItem.possuiVersoesCol},
          ${ProcessoArvoreDocumentoItem.relacaoSequenciaFqCol} AS ${ProcessoArvoreDocumentoItem.sequenciaCol},
          ${ProcessoArvoreDocumentoItem.relacaoEstadoAssociacaoFqCol} AS ${ProcessoArvoreDocumentoItem.estadoAssociacaoCol},
          ${ProcessoArvoreDocumentoItem.relacaoDataAssociacaoFqCol} AS ${ProcessoArvoreDocumentoItem.dataAssociacaoCol},
          ${ProcessoArvoreDocumentoItem.relacaoCienciaFqCol} AS ${ProcessoArvoreDocumentoItem.cienciaCol},
          ${ProcessoArvoreDocumentoItem.protocoloGeracaoFqCol} AS ${ProcessoArvoreDocumentoItem.dataGeracaoCol}
        ''')
        .where(
          ProcessoArvoreDocumentoItem.relacaoIdProtocoloPaiFqCol,
          '=',
          idProcesso,
        )
        .where(
          ProcessoArvoreDocumentoItem.relacaoEstadoAssociacaoFqCol,
          '=',
          AssociacaoProtocolo.documentoNoProcesso.valor,
        );

    if (cursor != null) {
      query.whereRaw(
        '(${ProcessoArvoreDocumentoItem.relacaoSequenciaFqCol} > ? OR '
        '(${ProcessoArvoreDocumentoItem.relacaoSequenciaFqCol} = ? AND '
        '${ProcessoArvoreDocumentoItem.relacaoIdFqCol} > ?))',
        <dynamic>[cursor.sequencia, cursor.sequencia, cursor.idRelacao],
      );
    }

    final rows = await (query
          ..orderBy(ProcessoArvoreDocumentoItem.relacaoSequenciaFqCol, 'asc')
          ..orderBy(ProcessoArvoreDocumentoItem.relacaoIdFqCol, 'asc')
          ..limit(paginacao.limite + 1))
        .get();
    final bool temProximaPagina = rows.length > paginacao.limite;
    final paginaRows =
        temProximaPagina ? rows.sublist(0, paginacao.limite) : rows;
    final itens = paginaRows
        .map(
          (Map<String, dynamic> row) =>
              ProcessoArvoreDocumentoItem.fromMap(row),
        )
        .toList(growable: false);
    final proximoCursor = temProximaPagina
        ? _CursorArvoreDocumentos.de(
            itens.last.sequencia,
            int.parse(itens.last.idRelacao),
          ).codificar()
        : null;

    return PaginaProcessoArvoreDocumentos(
      itens: itens,
      limite: paginacao.limite,
      proximoCursor: proximoCursor,
    );
  }

  Future<PaginaProcessoAndamentos> listarAndamentos(
    int idProcesso,
    ProcessoDetalhePaginacao paginacao,
  ) async {
    final cursor = paginacao.cursor == null
        ? null
        : _CursorAndamentos.decodificar(paginacao.cursor!);
    final query = _connection
        .table(ProcessoAndamentoItem.atividadeFqtn)
        .join(
          ProcessoAndamentoItem.unidadeFqtn,
          ProcessoAndamentoItem.unidadeIdFqCol,
          '=',
          ProcessoAndamentoItem.atividadeIdUnidadeFqCol,
        )
        .join(
          ProcessoAndamentoItem.unidadeOrigemAliasTable,
          ProcessoAndamentoItem.unidadeOrigemIdFqCol,
          '=',
          ProcessoAndamentoItem.atividadeIdUnidadeOrigemFqCol,
        )
        .leftJoin(
          ProcessoAndamentoItem.tarefaFqtn,
          ProcessoAndamentoItem.tarefaIdFqCol,
          '=',
          ProcessoAndamentoItem.atividadeIdTarefaFqCol,
        )
        .leftJoin(
          ProcessoAndamentoItem.usuarioFqtn,
          ProcessoAndamentoItem.usuarioIdFqCol,
          '=',
          ProcessoAndamentoItem.atividadeIdUsuarioFqCol,
        )
        .join(
          ProcessoAndamentoItem.usuarioOrigemAliasTable,
          ProcessoAndamentoItem.usuarioOrigemIdFqCol,
          '=',
          ProcessoAndamentoItem.atividadeIdUsuarioOrigemFqCol,
        )
        .leftJoin(
          ProcessoAndamentoItem.usuarioConclusaoAliasTable,
          ProcessoAndamentoItem.usuarioConclusaoIdFqCol,
          '=',
          ProcessoAndamentoItem.atividadeIdUsuarioConclusaoFqCol,
        )
        .selectRaw('''
          ${ProcessoAndamentoItem.atividadeIdFqCol} AS ${ProcessoAndamentoItem.idAtividadeCol},
          ${ProcessoAndamentoItem.atividadeIdProtocoloFqCol} AS ${ProcessoAndamentoItem.idProcessoCol},
          ${ProcessoAndamentoItem.atividadeIdTarefaFqCol} AS ${ProcessoAndamentoItem.idTarefaCol},
          ${ProcessoAndamentoItem.tarefaNomeFqCol} AS ${ProcessoAndamentoItem.tarefaNomeCol},
          ${ProcessoAndamentoItem.atividadeIdUnidadeFqCol} AS ${ProcessoAndamentoItem.idUnidadeCol},
          ${ProcessoAndamentoItem.unidadeSiglaFqCol} AS ${ProcessoAndamentoItem.unidadeSiglaCol},
          ${ProcessoAndamentoItem.unidadeDescricaoFqCol} AS ${ProcessoAndamentoItem.unidadeDescricaoCol},
          ${ProcessoAndamentoItem.atividadeIdUnidadeOrigemFqCol} AS ${ProcessoAndamentoItem.idUnidadeOrigemCol},
          ${ProcessoAndamentoItem.unidadeOrigemSiglaFqCol} AS ${ProcessoAndamentoItem.unidadeOrigemSiglaCol},
          ${ProcessoAndamentoItem.unidadeOrigemDescricaoFqCol} AS ${ProcessoAndamentoItem.unidadeOrigemDescricaoCol},
          ${ProcessoAndamentoItem.atividadeIdUsuarioFqCol} AS ${ProcessoAndamentoItem.idUsuarioCol},
          ${ProcessoAndamentoItem.usuarioNomeFqCol} AS ${ProcessoAndamentoItem.usuarioNomeCol},
          ${ProcessoAndamentoItem.atividadeIdUsuarioOrigemFqCol} AS ${ProcessoAndamentoItem.idUsuarioOrigemCol},
          ${ProcessoAndamentoItem.usuarioOrigemNomeFqCol} AS ${ProcessoAndamentoItem.usuarioOrigemNomeCol},
          ${ProcessoAndamentoItem.atividadeIdUsuarioConclusaoFqCol} AS ${ProcessoAndamentoItem.idUsuarioConclusaoCol},
          ${ProcessoAndamentoItem.usuarioConclusaoNomeFqCol} AS ${ProcessoAndamentoItem.usuarioConclusaoNomeCol},
          ${ProcessoAndamentoItem.atividadeAberturaFqCol} AS ${ProcessoAndamentoItem.dataAberturaCol},
          ${ProcessoAndamentoItem.atividadeConclusaoFqCol} AS ${ProcessoAndamentoItem.dataConclusaoCol},
          ${ProcessoAndamentoItem.atividadePrazoFqCol} AS ${ProcessoAndamentoItem.dataPrazoCol},
          ${ProcessoAndamentoItem.atividadeInicialFqCol} AS ${ProcessoAndamentoItem.atividadeInicialCol},
          ${ProcessoAndamentoItem.atividadeTipoVisualizacaoFqCol} AS ${ProcessoAndamentoItem.tipoVisualizacaoCol}
        ''').where(
      ProcessoAndamentoItem.atividadeIdProtocoloFqCol,
      '=',
      idProcesso,
    );

    if (cursor != null) {
      query.whereRaw(
        '(${ProcessoAndamentoItem.atividadeAberturaFqCol} < ? OR '
        '(${ProcessoAndamentoItem.atividadeAberturaFqCol} = ? AND '
        '${ProcessoAndamentoItem.atividadeIdFqCol} < ?))',
        <dynamic>[
          cursor.dataAbertura,
          cursor.dataAbertura,
          cursor.idAtividade,
        ],
      );
    }

    final rows = await (query
          ..orderBy(ProcessoAndamentoItem.atividadeAberturaFqCol, 'desc')
          ..orderBy(ProcessoAndamentoItem.atividadeIdFqCol, 'desc')
          ..limit(paginacao.limite + 1))
        .get();
    final bool temProximaPagina = rows.length > paginacao.limite;
    final paginaRows =
        temProximaPagina ? rows.sublist(0, paginacao.limite) : rows;
    final atributosPorAtividade = await _atributosPorAtividade(paginaRows);
    final itens = paginaRows.map((Map<String, dynamic> row) {
      final idAtividade = row[ProcessoAndamentoItem.idAtividadeCol] as int;
      return ProcessoAndamentoItem.fromMap(
        row,
        atributos: atributosPorAtividade[idAtividade] ??
            const <ProcessoAndamentoAtributo>[],
      );
    }).toList(growable: false);
    final proximoCursor = temProximaPagina
        ? _CursorAndamentos.de(
            itens.last.dataAbertura,
            itens.last.idAtividade,
          ).codificar()
        : null;

    return PaginaProcessoAndamentos(
      itens: itens,
      limite: paginacao.limite,
      proximoCursor: proximoCursor,
    );
  }

  /// Lista as unidades em que o processo está aberto, uma linha por unidade.
  ///
  /// A abertura é por unidade e vive em `atividade` com `dth_conclusao` nula.
  /// Como nem toda tarefa fecha os andamentos anteriores, a unidade pode ter
  /// mais de uma atividade aberta; a agregação preserva essa contagem e mantém
  /// a atividade mais recente para resolver a atribuição.
  Future<List<ProcessoUnidadeAberta>> listarUnidadesAbertas(
    int idProcesso,
  ) async {
    final rows = await _connection
        .table(ProcessoUnidadeAberta.atividadeFqtn)
        .join(
          ProcessoUnidadeAberta.unidadeFqtn,
          ProcessoUnidadeAberta.unidadeIdFqCol,
          '=',
          ProcessoUnidadeAberta.atividadeIdUnidadeFqCol,
        )
        .selectRaw('''
          ${ProcessoUnidadeAberta.atividadeIdUnidadeFqCol} AS ${ProcessoUnidadeAberta.idUnidadeCol},
          ${ProcessoUnidadeAberta.unidadeSiglaFqCol} AS ${ProcessoUnidadeAberta.unidadeSiglaCol},
          ${ProcessoUnidadeAberta.unidadeDescricaoFqCol} AS ${ProcessoUnidadeAberta.unidadeDescricaoCol},
          MIN(${ProcessoUnidadeAberta.atividadeAberturaFqCol}) AS ${ProcessoUnidadeAberta.dataAberturaCol},
          MAX(${ProcessoUnidadeAberta.atividadeAberturaFqCol}) AS ${ProcessoUnidadeAberta.dataUltimaAtividadeCol},
          COUNT(*) AS ${ProcessoUnidadeAberta.atividadesAbertasCol},
          MAX(${ProcessoUnidadeAberta.atividadeIdFqCol}) AS ${ProcessoUnidadeAberta.idAtividadeRecenteCol},
          MAX(CASE WHEN ${ProcessoUnidadeAberta.atividadeInicialFqCol} = '${ControleProcessosModo.gerados.valorAtividadeInicial}'
                   THEN '${ControleProcessosModo.gerados.valorAtividadeInicial}'
                   ELSE '${ControleProcessosModo.recebidos.valorAtividadeInicial}' END)
            AS ${ProcessoUnidadeAberta.geradoNaUnidadeCol}
        ''')
        .where(
          ProcessoUnidadeAberta.atividadeIdProtocoloFqCol,
          '=',
          idProcesso,
        )
        .whereNull(ProcessoUnidadeAberta.atividadeConclusaoFqCol)
        .groupBy(<String>[
          ProcessoUnidadeAberta.atividadeIdUnidadeFqCol,
          ProcessoUnidadeAberta.unidadeSiglaFqCol,
          ProcessoUnidadeAberta.unidadeDescricaoFqCol,
        ])
        .orderByRaw(
          '${ProcessoUnidadeAberta.dataAberturaCol} ASC, '
          '${ProcessoUnidadeAberta.idUnidadeCol} ASC',
        )
        .get();

    final atribuicoes = await _atribuicaoPorAtividade(rows);
    return rows.map((Map<String, dynamic> row) {
      final int idAtividadeRecente = SeiCoreUtils.inteiro(
        row[ProcessoUnidadeAberta.idAtividadeRecenteCol],
        nomeCampo: ProcessoUnidadeAberta.idAtividadeRecenteCol,
      );
      final _AtribuicaoAtividade? atribuicao = atribuicoes[idAtividadeRecente];
      return ProcessoUnidadeAberta.fromMap(
        row,
        idUsuarioAtribuicao: atribuicao?.idUsuario,
        usuarioAtribuicaoNome: atribuicao?.nomeUsuario,
      );
    }).toList(growable: false);
  }

  /// Lista os processos relacionados ao processo consultado, nos dois sentidos.
  ///
  /// O vínculo é gravado uma única vez e é direcionado, mas o SEI o exibe nos
  /// dois processos. As duas consultas mantêm cada sentido explícito porque
  /// somente a unidade que criou o vínculo pode removê-lo.
  Future<List<ProcessoRelacionado>> listarRelacionados(int idProcesso) async {
    final relacionados = <ProcessoRelacionado>[];
    for (final SentidoRelacionamento sentido in SentidoRelacionamento.values) {
      final bool consultaOrigem = sentido == SentidoRelacionamento.origem;
      final String colunaFiltro = consultaOrigem
          ? ProcessoRelacionado.relacaoIdProtocolo1FqCol
          : ProcessoRelacionado.relacaoIdProtocolo2FqCol;
      final String colunaRelacionado = consultaOrigem
          ? ProcessoRelacionado.relacaoIdProtocolo2FqCol
          : ProcessoRelacionado.relacaoIdProtocolo1FqCol;

      final rows = await _connection
          .table(ProcessoRelacionado.relacaoFqtn)
          .join(
            ProcessoRelacionado.protocoloFqtn,
            ProcessoRelacionado.protocoloIdFqCol,
            '=',
            colunaRelacionado,
          )
          .join(
            ProcessoRelacionado.procedimentoFqtn,
            ProcessoRelacionado.procedimentoIdFqCol,
            '=',
            ProcessoRelacionado.protocoloIdFqCol,
          )
          .join(
            ProcessoRelacionado.tipoProcedimentoFqtn,
            ProcessoRelacionado.tipoProcedimentoIdFqCol,
            '=',
            ProcessoRelacionado.procedimentoIdTipoFqCol,
          )
          .join(
            ProcessoRelacionado.unidadeFqtn,
            ProcessoRelacionado.unidadeIdFqCol,
            '=',
            ProcessoRelacionado.relacaoIdUnidadeFqCol,
          )
          .selectRaw('''
            ${ProcessoRelacionado.relacaoIdFqCol} AS ${ProcessoRelacionado.idRelacaoCol},
            $colunaRelacionado AS ${ProcessoRelacionado.idProcessoRelacionadoCol},
            ${ProcessoRelacionado.protocoloFormatadoFqCol} AS ${ProcessoRelacionado.protocoloFormatadoCol},
            ${ProcessoRelacionado.protocoloDescricaoFqCol} AS ${ProcessoRelacionado.descricaoCol},
            ${ProcessoRelacionado.protocoloEstadoFqCol} AS ${ProcessoRelacionado.estadoProtocoloCol},
            ${ProcessoRelacionado.protocoloNivelAcessoGlobalFqCol} AS ${ProcessoRelacionado.nivelAcessoGlobalCol},
            ${ProcessoRelacionado.procedimentoIdTipoFqCol} AS ${ProcessoRelacionado.idTipoProcedimentoCol},
            ${ProcessoRelacionado.tipoProcedimentoNomeFqCol} AS ${ProcessoRelacionado.tipoProcedimentoNomeCol},
            ${ProcessoRelacionado.relacaoDataAssociacaoFqCol} AS ${ProcessoRelacionado.dataAssociacaoCol},
            ${ProcessoRelacionado.relacaoIdUnidadeFqCol} AS ${ProcessoRelacionado.idUnidadeAssociacaoCol},
            ${ProcessoRelacionado.unidadeSiglaFqCol} AS ${ProcessoRelacionado.unidadeAssociacaoSiglaCol}
          ''')
          .where(colunaFiltro, '=', idProcesso)
          .where(
            ProcessoRelacionado.relacaoStaAssociacaoFqCol,
            '=',
            AssociacaoProtocolo.processoRelacionado.valor,
          )
          .orderBy(ProcessoRelacionado.relacaoDataAssociacaoFqCol, 'asc')
          .orderBy(ProcessoRelacionado.relacaoIdFqCol, 'asc')
          .get();

      for (final Map<String, dynamic> row in rows) {
        relacionados.add(ProcessoRelacionado.fromMap(row, sentido: sentido));
      }
    }

    relacionados.sort(
      (ProcessoRelacionado a, ProcessoRelacionado b) =>
          a.dataAssociacao.compareTo(b.dataAssociacao),
    );
    return List<ProcessoRelacionado>.unmodifiable(relacionados);
  }

  /// Lista interessados, remetentes e destinatários vinculados ao processo.
  Future<List<ProcessoParticipante>> listarParticipantes(
    int idProcesso,
  ) async {
    final rows = await _connection
        .table(ProcessoParticipante.participanteFqtn)
        .join(
          ProcessoParticipante.contatoFqtn,
          ProcessoParticipante.contatoIdFqCol,
          '=',
          ProcessoParticipante.participanteIdContatoFqCol,
        )
        .selectRaw('''
          ${ProcessoParticipante.participanteIdFqCol} AS ${ProcessoParticipante.idParticipanteCol},
          ${ProcessoParticipante.participanteIdContatoFqCol} AS ${ProcessoParticipante.idContatoCol},
          ${ProcessoParticipante.contatoNomeFqCol} AS ${ProcessoParticipante.contatoNomeCol},
          ${ProcessoParticipante.contatoSiglaFqCol} AS ${ProcessoParticipante.contatoSiglaCol},
          ${ProcessoParticipante.contatoEmailFqCol} AS ${ProcessoParticipante.contatoEmailCol},
          ${ProcessoParticipante.contatoNaturezaFqCol} AS ${ProcessoParticipante.contatoNaturezaCol},
          ${ProcessoParticipante.contatoIdTipoContatoFqCol} AS ${ProcessoParticipante.idTipoContatoCol},
          ${ProcessoParticipante.participanteStaParticipacaoFqCol} AS ${ProcessoParticipante.codigoParticipacaoCol},
          ${ProcessoParticipante.participanteSequenciaFqCol} AS ${ProcessoParticipante.sequenciaCol},
          ${ProcessoParticipante.participanteIdUnidadeFqCol} AS ${ProcessoParticipante.idUnidadeCol}
        ''')
        .where(
          ProcessoParticipante.participanteIdProtocoloFqCol,
          '=',
          idProcesso,
        )
        .orderBy(ProcessoParticipante.participanteStaParticipacaoFqCol, 'asc')
        .orderBy(ProcessoParticipante.participanteSequenciaFqCol, 'asc')
        .orderBy(ProcessoParticipante.participanteIdFqCol, 'asc')
        .get();

    return rows
        .map(
          (Map<String, dynamic> row) => ProcessoParticipante.fromMap(row),
        )
        .toList(growable: false);
  }

  /// Lista as anotações do processo visíveis para a unidade informada.
  ///
  /// A anotação nunca tramita: é exclusiva da unidade que a criou. O
  /// repositório aplica esse filtro em vez de expor todas as unidades, porque
  /// a visibilidade por unidade é regra de domínio, não escolha de tela.
  Future<List<ProcessoAnotacao>> listarAnotacoes(
    int idProcesso,
    int idUnidade,
  ) async {
    final rows = await _connection
        .table(ProcessoAnotacao.anotacaoFqtn)
        .join(
          ProcessoAnotacao.usuarioFqtn,
          ProcessoAnotacao.usuarioIdFqCol,
          '=',
          ProcessoAnotacao.anotacaoIdUsuarioFqCol,
        )
        .selectRaw('''
          ${ProcessoAnotacao.anotacaoIdFqCol} AS ${ProcessoAnotacao.idAnotacaoCol},
          ${ProcessoAnotacao.anotacaoDescricaoFqCol} AS ${ProcessoAnotacao.descricaoCol},
          ${ProcessoAnotacao.anotacaoDataFqCol} AS ${ProcessoAnotacao.dataAnotacaoCol},
          ${ProcessoAnotacao.anotacaoPrioridadeFqCol} AS ${ProcessoAnotacao.prioridadeCol},
          ${ProcessoAnotacao.anotacaoSituacaoFqCol} AS ${ProcessoAnotacao.situacaoCol},
          ${ProcessoAnotacao.anotacaoIdUsuarioFqCol} AS ${ProcessoAnotacao.idUsuarioCol},
          ${ProcessoAnotacao.usuarioNomeFqCol} AS ${ProcessoAnotacao.usuarioNomeCol}
        ''')
        .where(ProcessoAnotacao.anotacaoIdProtocoloFqCol, '=', idProcesso)
        .where(ProcessoAnotacao.anotacaoIdUnidadeFqCol, '=', idUnidade)
        .orderBy(ProcessoAnotacao.anotacaoDataFqCol, 'desc')
        .get();

    return rows
        .map((Map<String, dynamic> row) => ProcessoAnotacao.fromMap(row))
        .toList(growable: false);
  }

  /// Lista os marcadores atualmente atribuídos ao processo.
  ///
  /// `andamento_marcador` é histórico e nunca é atualizado in-place; a
  /// atribuição vigente é a linha mais recente do par processo e marcador com
  /// `sin_ultimo = 'S'` e `sin_ativo = 'S'`.
  Future<List<ProcessoMarcador>> listarMarcadores(int idProcesso) async {
    final rows = await _connection
        .table(ProcessoMarcador.andamentoFqtn)
        .join(
          ProcessoMarcador.marcadorFqtn,
          ProcessoMarcador.marcadorIdFqCol,
          '=',
          ProcessoMarcador.andamentoIdMarcadorFqCol,
        )
        .join(
          ProcessoMarcador.usuarioFqtn,
          ProcessoMarcador.usuarioIdFqCol,
          '=',
          ProcessoMarcador.andamentoIdUsuarioFqCol,
        )
        .selectRaw('''
          ${ProcessoMarcador.andamentoIdFqCol} AS ${ProcessoMarcador.idAndamentoMarcadorCol},
          ${ProcessoMarcador.andamentoIdMarcadorFqCol} AS ${ProcessoMarcador.idMarcadorCol},
          ${ProcessoMarcador.marcadorNomeFqCol} AS ${ProcessoMarcador.marcadorNomeCol},
          ${ProcessoMarcador.marcadorIconeFqCol} AS ${ProcessoMarcador.marcadorIconeCol},
          ${ProcessoMarcador.andamentoTextoFqCol} AS ${ProcessoMarcador.textoCol},
          ${ProcessoMarcador.andamentoDataFqCol} AS ${ProcessoMarcador.dataExecucaoCol},
          ${ProcessoMarcador.andamentoIdUsuarioFqCol} AS ${ProcessoMarcador.idUsuarioCol},
          ${ProcessoMarcador.usuarioNomeFqCol} AS ${ProcessoMarcador.usuarioNomeCol}
        ''')
        .where(
          ProcessoMarcador.andamentoIdProcedimentoFqCol,
          '=',
          idProcesso,
        )
        .where(
          ProcessoMarcador.andamentoUltimoFqCol,
          '=',
          SeiCoreUtils.boolParaSimNao(true),
        )
        .where(
          ProcessoMarcador.andamentoAtivoFqCol,
          '=',
          SeiCoreUtils.boolParaSimNao(true),
        )
        .orderBy(ProcessoMarcador.andamentoDataFqCol, 'asc')
        .get();

    return rows
        .map((Map<String, dynamic> row) => ProcessoMarcador.fromMap(row))
        .toList(growable: false);
  }

  /// Lista os acompanhamentos especiais do processo, em qualquer unidade.
  ///
  /// Diferente da anotação, o Acompanhamento Especial não é exclusivo de uma
  /// unidade: qualquer unidade que acompanha o processo aparece aqui.
  Future<List<ProcessoAcompanhamento>> listarAcompanhamentos(
    int idProcesso,
  ) async {
    final rows = await _connection
        .table(ProcessoAcompanhamento.acompanhamentoFqtn)
        .join(
          ProcessoAcompanhamento.unidadeFqtn,
          ProcessoAcompanhamento.unidadeIdFqCol,
          '=',
          ProcessoAcompanhamento.acompanhamentoIdUnidadeFqCol,
        )
        .join(
          ProcessoAcompanhamento.usuarioFqtn,
          ProcessoAcompanhamento.usuarioIdFqCol,
          '=',
          ProcessoAcompanhamento.acompanhamentoIdUsuarioFqCol,
        )
        .leftJoin(
          ProcessoAcompanhamento.grupoFqtn,
          ProcessoAcompanhamento.grupoIdFqCol,
          '=',
          ProcessoAcompanhamento.acompanhamentoIdGrupoFqCol,
        )
        .selectRaw('''
          ${ProcessoAcompanhamento.acompanhamentoIdFqCol} AS ${ProcessoAcompanhamento.idAcompanhamentoCol},
          ${ProcessoAcompanhamento.acompanhamentoIdUnidadeFqCol} AS ${ProcessoAcompanhamento.idUnidadeCol},
          ${ProcessoAcompanhamento.unidadeSiglaFqCol} AS ${ProcessoAcompanhamento.unidadeSiglaCol},
          ${ProcessoAcompanhamento.acompanhamentoIdGrupoFqCol} AS ${ProcessoAcompanhamento.idGrupoAcompanhamentoCol},
          ${ProcessoAcompanhamento.grupoNomeFqCol} AS ${ProcessoAcompanhamento.grupoNomeCol},
          ${ProcessoAcompanhamento.acompanhamentoObservacaoFqCol} AS ${ProcessoAcompanhamento.observacaoCol},
          ${ProcessoAcompanhamento.acompanhamentoDataFqCol} AS ${ProcessoAcompanhamento.dataAlteracaoCol},
          ${ProcessoAcompanhamento.acompanhamentoIdUsuarioFqCol} AS ${ProcessoAcompanhamento.idUsuarioCol},
          ${ProcessoAcompanhamento.usuarioNomeFqCol} AS ${ProcessoAcompanhamento.usuarioNomeCol}
        ''')
        .where(
          ProcessoAcompanhamento.acompanhamentoIdProtocoloFqCol,
          '=',
          idProcesso,
        )
        .orderBy(ProcessoAcompanhamento.acompanhamentoDataFqCol, 'asc')
        .get();

    return rows
        .map(
          (Map<String, dynamic> row) => ProcessoAcompanhamento.fromMap(row),
        )
        .toList(growable: false);
  }

  /// Lista os controles de prazo internos da unidade sobre o processo.
  ///
  /// É recurso de organização interna: só a unidade dona do controle o vê.
  Future<List<ProcessoControlePrazo>> listarControlesPrazo(
    int idProcesso,
    int idUnidade,
  ) async {
    final rows = await _connection
        .table(ProcessoControlePrazo.controlePrazoFqtn)
        .join(
          ProcessoControlePrazo.usuarioFqtn,
          ProcessoControlePrazo.usuarioIdFqCol,
          '=',
          ProcessoControlePrazo.controlePrazoIdUsuarioFqCol,
        )
        .selectRaw('''
          ${ProcessoControlePrazo.controlePrazoIdFqCol} AS ${ProcessoControlePrazo.idControlePrazoCol},
          ${ProcessoControlePrazo.controlePrazoDataPrazoFqCol} AS ${ProcessoControlePrazo.dataPrazoCol},
          ${ProcessoControlePrazo.controlePrazoDataConclusaoFqCol} AS ${ProcessoControlePrazo.dataConclusaoCol},
          ${ProcessoControlePrazo.controlePrazoIdUsuarioFqCol} AS ${ProcessoControlePrazo.idUsuarioCol},
          ${ProcessoControlePrazo.usuarioNomeFqCol} AS ${ProcessoControlePrazo.usuarioNomeCol}
        ''')
        .where(
          ProcessoControlePrazo.controlePrazoIdProtocoloFqCol,
          '=',
          idProcesso,
        )
        .where(
          ProcessoControlePrazo.controlePrazoIdUnidadeFqCol,
          '=',
          idUnidade,
        )
        .orderBy(ProcessoControlePrazo.controlePrazoDataPrazoFqCol, 'asc')
        .get();

    return rows
        .map(
          (Map<String, dynamic> row) => ProcessoControlePrazo.fromMap(row),
        )
        .toList(growable: false);
  }

  /// Lista os retornos programados do processo, cumpridos ou não.
  ///
  /// O prazo cessa apenas quando o processo é enviado de volta à unidade
  /// demandante; a coluna `cumprido` reflete exatamente essa condição, nunca
  /// a data programada em si.
  Future<List<ProcessoRetornoProgramado>> listarRetornosProgramados(
    int idProcesso,
  ) async {
    final rows = await _connection
        .table(ProcessoRetornoProgramado.retornoFqtn)
        .join(
          ProcessoRetornoProgramado.unidadeEnvioFqtn,
          ProcessoRetornoProgramado.unidadeEnvioIdFqCol,
          '=',
          ProcessoRetornoProgramado.retornoIdUnidadeEnvioFqCol,
        )
        .join(
          ProcessoRetornoProgramado.unidadeRetornoAliasTable,
          ProcessoRetornoProgramado.unidadeRetornoIdFqCol,
          '=',
          ProcessoRetornoProgramado.retornoIdUnidadeRetornoFqCol,
        )
        .join(
          ProcessoRetornoProgramado.usuarioFqtn,
          ProcessoRetornoProgramado.usuarioIdFqCol,
          '=',
          ProcessoRetornoProgramado.retornoIdUsuarioFqCol,
        )
        .selectRaw('''
          ${ProcessoRetornoProgramado.retornoIdFqCol} AS ${ProcessoRetornoProgramado.idRetornoProgramadoCol},
          ${ProcessoRetornoProgramado.retornoDataProgramadaFqCol} AS ${ProcessoRetornoProgramado.dataProgramadaCol},
          ${ProcessoRetornoProgramado.retornoDataAlteracaoFqCol} AS ${ProcessoRetornoProgramado.dataAlteracaoCol},
          CASE WHEN ${ProcessoRetornoProgramado.retornoIdAtividadeRetornoFqCol} IS NULL
               THEN '${SeiCoreUtils.boolParaSimNao(false)}'
               ELSE '${SeiCoreUtils.boolParaSimNao(true)}' END
            AS ${ProcessoRetornoProgramado.cumpridoCol},
          ${ProcessoRetornoProgramado.retornoIdUnidadeEnvioFqCol} AS ${ProcessoRetornoProgramado.idUnidadeEnvioCol},
          ${ProcessoRetornoProgramado.unidadeEnvioSiglaFqCol} AS ${ProcessoRetornoProgramado.unidadeEnvioSiglaCol},
          ${ProcessoRetornoProgramado.retornoIdUnidadeRetornoFqCol} AS ${ProcessoRetornoProgramado.idUnidadeRetornoCol},
          ${ProcessoRetornoProgramado.unidadeRetornoSiglaFqCol} AS ${ProcessoRetornoProgramado.unidadeRetornoSiglaCol},
          ${ProcessoRetornoProgramado.retornoIdUsuarioFqCol} AS ${ProcessoRetornoProgramado.idUsuarioCol},
          ${ProcessoRetornoProgramado.usuarioNomeFqCol} AS ${ProcessoRetornoProgramado.usuarioNomeCol}
        ''')
        .where(
          ProcessoRetornoProgramado.retornoIdProtocoloFqCol,
          '=',
          idProcesso,
        )
        .orderBy(ProcessoRetornoProgramado.retornoDataProgramadaFqCol, 'asc')
        .get();

    return rows
        .map(
          (Map<String, dynamic> row) => ProcessoRetornoProgramado.fromMap(row),
        )
        .toList(growable: false);
  }

  /// Obtém o conteúdo de um documento do processo, interno ou externo.
  ///
  /// Documento interno tem corpo HTML em `documento_conteudo`; documento
  /// externo não tem linha ali — o ponteiro para o arquivo vem de `anexo`,
  /// que nesta base nunca tem mais de uma linha por documento externo. Os
  /// dois `LEFT JOIN` coexistem na mesma consulta porque só um dos dois lados
  /// vem preenchido, conforme `Documento.estado`.
  ///
  /// O filtro por [idProcesso] evita que um identificador de documento de
  /// outro processo seja consultado por engano.
  Future<ProcessoDocumentoConteudo?> obterConteudoDocumento(
    int idProcesso,
    int idDocumento,
  ) async {
    final row = await _connection
        .table(ProcessoDocumentoConteudo.documentoFqtn)
        .join(
          ProcessoDocumentoConteudo.protocoloFqtn,
          ProcessoDocumentoConteudo.protocoloIdFqCol,
          '=',
          ProcessoDocumentoConteudo.documentoIdFqCol,
        )
        .leftJoin(
          ProcessoDocumentoConteudo.conteudoFqtn,
          ProcessoDocumentoConteudo.conteudoIdDocumentoFqCol,
          '=',
          ProcessoDocumentoConteudo.documentoIdFqCol,
        )
        .leftJoin(
          ProcessoDocumentoConteudo.anexoFqtn,
          ProcessoDocumentoConteudo.anexoIdProtocoloFqCol,
          '=',
          ProcessoDocumentoConteudo.documentoIdFqCol,
        )
        .selectRaw('''
          ${ProcessoDocumentoConteudo.documentoIdFqCol} AS ${ProcessoDocumentoConteudo.idDocumentoCol},
          ${ProcessoDocumentoConteudo.documentoEstadoFqCol} AS ${ProcessoDocumentoConteudo.estadoCol},
          ${ProcessoDocumentoConteudo.documentoBloqueadoFqCol} AS ${ProcessoDocumentoConteudo.bloqueadoCol},
          ${ProcessoDocumentoConteudo.documentoVersoesFqCol} AS ${ProcessoDocumentoConteudo.possuiVersoesCol},
          ${ProcessoDocumentoConteudo.conteudoConteudoFqCol} AS ${ProcessoDocumentoConteudo.conteudoHtmlCol},
          ${ProcessoDocumentoConteudo.conteudoCrcAssinaturaFqCol} AS ${ProcessoDocumentoConteudo.crcAssinaturaCol},
          ${ProcessoDocumentoConteudo.conteudoQrCodeAssinaturaFqCol} AS ${ProcessoDocumentoConteudo.qrCodeAssinaturaCol},
          ${ProcessoDocumentoConteudo.anexoNomeFqCol} AS ${ProcessoDocumentoConteudo.anexoNomeCol},
          ${ProcessoDocumentoConteudo.anexoTamanhoFqCol} AS ${ProcessoDocumentoConteudo.anexoTamanhoCol},
          ${ProcessoDocumentoConteudo.anexoHashFqCol} AS ${ProcessoDocumentoConteudo.anexoHashCol},
          ${ProcessoDocumentoConteudo.anexoDataInclusaoFqCol} AS ${ProcessoDocumentoConteudo.anexoDataInclusaoCol}
        ''')
        .where(ProcessoDocumentoConteudo.documentoIdFqCol, '=', idDocumento)
        .where(
          ProcessoDocumentoConteudo.documentoIdProcedimentoFqCol,
          '=',
          idProcesso,
        )
        .first();

    return row == null ? null : ProcessoDocumentoConteudo.fromMap(row);
  }

  Future<Map<int, _AtribuicaoAtividade>> _atribuicaoPorAtividade(
    List<Map<String, dynamic>> unidades,
  ) async {
    if (unidades.isEmpty) {
      return const <int, _AtribuicaoAtividade>{};
    }
    // `whereIn` do eloquent exige lista concreta; um iterável preguiçoso
    // chega ao compilador da query e quebra na montagem do SQL.
    final idsAtividades = unidades
        .map(
          (Map<String, dynamic> unidade) => SeiCoreUtils.inteiro(
            unidade[ProcessoUnidadeAberta.idAtividadeRecenteCol],
            nomeCampo: ProcessoUnidadeAberta.idAtividadeRecenteCol,
          ),
        )
        .toList(growable: false);
    final rows = await _connection
        .table(ProcessoUnidadeAberta.atividadeFqtn)
        .join(
          ProcessoUnidadeAberta.usuarioFqtn,
          ProcessoUnidadeAberta.usuarioIdFqCol,
          '=',
          ProcessoUnidadeAberta.atividadeIdUsuarioAtribuicaoFqCol,
        )
        .selectRaw('''
          ${ProcessoUnidadeAberta.atividadeIdFqCol} AS ${ProcessoUnidadeAberta.idAtividadeRecenteCol},
          ${ProcessoUnidadeAberta.atividadeIdUsuarioAtribuicaoFqCol} AS ${ProcessoUnidadeAberta.idUsuarioAtribuicaoCol},
          ${ProcessoUnidadeAberta.usuarioNomeFqCol} AS ${ProcessoUnidadeAberta.usuarioAtribuicaoNomeCol}
        ''')
        .whereIn(ProcessoUnidadeAberta.atividadeIdFqCol, idsAtividades)
        .get();

    final atribuicoes = <int, _AtribuicaoAtividade>{};
    for (final Map<String, dynamic> row in rows) {
      final int idAtividade = SeiCoreUtils.inteiro(
        row[ProcessoUnidadeAberta.idAtividadeRecenteCol],
        nomeCampo: ProcessoUnidadeAberta.idAtividadeRecenteCol,
      );
      atribuicoes[idAtividade] = _AtribuicaoAtividade(
        SeiCoreUtils.inteiro(
          row[ProcessoUnidadeAberta.idUsuarioAtribuicaoCol],
          nomeCampo: ProcessoUnidadeAberta.idUsuarioAtribuicaoCol,
        ),
        row[ProcessoUnidadeAberta.usuarioAtribuicaoNomeCol] as String,
      );
    }
    return atribuicoes;
  }

  Future<Map<int, List<ProcessoAndamentoAtributo>>> _atributosPorAtividade(
    List<Map<String, dynamic>> atividades,
  ) async {
    if (atividades.isEmpty) {
      return const <int, List<ProcessoAndamentoAtributo>>{};
    }
    final idsAtividades = atividades
        .map(
          (Map<String, dynamic> atividade) =>
              atividade[ProcessoAndamentoItem.idAtividadeCol] as int,
        )
        .toList(growable: false);
    final rows = await _connection
        .table(ProcessoAndamentoAtributo.fqtn)
        .select(const <String>[
          ProcessoAndamentoAtributo.idFqCol,
          ProcessoAndamentoAtributo.idAtividadeFqCol,
          ProcessoAndamentoAtributo.idOrigemFqCol,
          ProcessoAndamentoAtributo.nomeFqCol,
          ProcessoAndamentoAtributo.valorFqCol,
        ])
        .whereIn(ProcessoAndamentoAtributo.idAtividadeFqCol, idsAtividades)
        .orderBy(ProcessoAndamentoAtributo.idAtividadeFqCol, 'asc')
        .orderBy(ProcessoAndamentoAtributo.idFqCol, 'asc')
        .get();
    final atributosPorAtividade = <int, List<ProcessoAndamentoAtributo>>{};
    for (final row in rows) {
      final atributo = ProcessoAndamentoAtributo.fromMap(row);
      final idAtividade = row[ProcessoAndamentoAtributo.idAtividadeCol] as int;
      atributosPorAtividade
          .putIfAbsent(idAtividade, () => <ProcessoAndamentoAtributo>[])
          .add(atributo);
    }
    return atributosPorAtividade;
  }
}

/// Atribuição resolvida para a atividade aberta mais recente de uma unidade.
///
/// A atribuição pertence à atividade e não à unidade; este par existe apenas
/// para juntar as duas consultas sem inventar um DTO público.
final class _AtribuicaoAtividade {
  const _AtribuicaoAtividade(this.idUsuario, this.nomeUsuario);

  final int idUsuario;
  final String nomeUsuario;
}

final class _CursorArvoreDocumentos {
  const _CursorArvoreDocumentos._(this.sequencia, this.idRelacao);

  final int sequencia;
  final int idRelacao;

  factory _CursorArvoreDocumentos.de(int sequencia, int idRelacao) {
    return _CursorArvoreDocumentos._(sequencia, idRelacao);
  }

  factory _CursorArvoreDocumentos.decodificar(String cursor) {
    final dados = _CodecCursor.decodificar(cursor);
    return _CursorArvoreDocumentos._(
      SeiCoreUtils.inteiro(dados['sequencia'], nomeCampo: 'sequencia'),
      SeiCoreUtils.inteiro(dados['id_relacao'], nomeCampo: 'id_relacao'),
    );
  }

  String codificar() {
    return _CodecCursor.codificar(<String, dynamic>{
      'versao': 1,
      'sequencia': sequencia,
      'id_relacao': idRelacao,
    });
  }
}

final class _CursorAndamentos {
  const _CursorAndamentos._(this.dataAbertura, this.idAtividade);

  final DateTime dataAbertura;
  final int idAtividade;

  factory _CursorAndamentos.de(DateTime dataAbertura, int idAtividade) {
    return _CursorAndamentos._(dataAbertura, idAtividade);
  }

  factory _CursorAndamentos.decodificar(String cursor) {
    final dados = _CodecCursor.decodificar(cursor);
    return _CursorAndamentos._(
      SeiCoreUtils.dataHoraLocal(
        dados['data_abertura'],
        nomeCampo: 'data_abertura',
      ),
      SeiCoreUtils.inteiro(
        dados['id_atividade'],
        nomeCampo: 'id_atividade',
      ),
    );
  }

  String codificar() {
    return _CodecCursor.codificar(<String, dynamic>{
      'versao': 1,
      'data_abertura': dataAbertura.toIso8601String(),
      'id_atividade': idAtividade,
    });
  }
}

final class _CodecCursor {
  const _CodecCursor._();

  static String codificar(Map<String, dynamic> dados) {
    return base64UrlEncode(utf8.encode(jsonEncode(dados))).replaceAll('=', '');
  }

  static Map<String, dynamic> decodificar(String cursor) {
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(cursor)) {
      throw FormatException('O cursor informado é inválido.');
    }

    try {
      final resto = cursor.length % 4;
      final cursorComPadding =
          resto == 0 ? cursor : '$cursor${'=' * (4 - resto)}';
      final Object? dados = jsonDecode(
        utf8.decode(base64Url.decode(cursorComPadding)),
      );
      if (dados is! Map<String, dynamic> || dados['versao'] != 1) {
        throw const FormatException('O cursor informado é inválido.');
      }
      return dados;
    } on FormatException {
      rethrow;
    } on Object {
      throw FormatException('O cursor informado é inválido.');
    }
  }
}
