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
          _estadoAssociacaoAtiva,
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

const String _estadoAssociacaoAtiva = '1';

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
