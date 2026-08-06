import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Atividade aberta de processo, projetada para o Controle de Processos.
class ProcessoRecebidoItem extends BaseModel {
  static const String schemaName = 'public';

  static const String atividadeTableName = 'atividade';
  static const String atividadeFqtn = '$schemaName.$atividadeTableName';
  static const String protocoloTableName = 'protocolo';
  static const String protocoloFqtn = '$schemaName.$protocoloTableName';
  static const String procedimentoTableName = 'procedimento';
  static const String procedimentoFqtn = '$schemaName.$procedimentoTableName';
  static const String tipoProcedimentoTableName = 'tipo_procedimento';
  static const String tipoProcedimentoFqtn =
      '$schemaName.$tipoProcedimentoTableName';
  static const String unidadeTableName = 'unidade';
  static const String unidadeFqtn = '$schemaName.$unidadeTableName';
  static const String tarefaTableName = 'tarefa';
  static const String tarefaFqtn = '$schemaName.$tarefaTableName';
  static const String usuarioTableName = 'usuario';
  static const String usuarioFqtn = '$schemaName.$usuarioTableName';

  static const String unidadeOrigemAlias = 'unidade_origem';
  static const String unidadeOrigemAliasTable =
      '$unidadeFqtn as $unidadeOrigemAlias';
  static const String usuarioAtribuicaoAlias = 'usuario_atribuicao';
  static const String usuarioAtribuicaoAliasTable =
      '$usuarioFqtn as $usuarioAtribuicaoAlias';
  static const String usuarioAtividadeAlias = 'usuario_atividade';
  static const String usuarioAtividadeAliasTable =
      '$usuarioFqtn as $usuarioAtividadeAlias';

  static const String atividadeIdCol = 'id_atividade';
  static const String atividadeIdFqCol = '$atividadeFqtn.$atividadeIdCol';
  static const String atividadeIdProtocoloCol = 'id_protocolo';
  static const String atividadeIdProtocoloFqCol =
      '$atividadeFqtn.$atividadeIdProtocoloCol';
  static const String atividadeIdUnidadeCol = 'id_unidade';
  static const String atividadeIdUnidadeFqCol =
      '$atividadeFqtn.$atividadeIdUnidadeCol';
  static const String atividadeIdUnidadeOrigemCol = 'id_unidade_origem';
  static const String atividadeIdUnidadeOrigemFqCol =
      '$atividadeFqtn.$atividadeIdUnidadeOrigemCol';
  static const String atividadeIdTarefaCol = 'id_tarefa';
  static const String atividadeIdTarefaFqCol =
      '$atividadeFqtn.$atividadeIdTarefaCol';
  static const String atividadeIdUsuarioAtribuicaoCol = 'id_usuario_atribuicao';
  static const String atividadeIdUsuarioAtribuicaoFqCol =
      '$atividadeFqtn.$atividadeIdUsuarioAtribuicaoCol';
  static const String atividadeIdUsuarioCol = 'id_usuario';
  static const String atividadeIdUsuarioFqCol =
      '$atividadeFqtn.$atividadeIdUsuarioCol';
  static const String atividadeAberturaCol = 'dth_abertura';
  static const String atividadeAberturaFqCol =
      '$atividadeFqtn.$atividadeAberturaCol';
  static const String atividadeConclusaoCol = 'dth_conclusao';
  static const String atividadeConclusaoFqCol =
      '$atividadeFqtn.$atividadeConclusaoCol';
  static const String atividadePrazoCol = 'dta_prazo';
  static const String atividadePrazoFqCol = '$atividadeFqtn.$atividadePrazoCol';
  static const String atividadeInicialSourceCol = 'sin_inicial';
  static const String atividadeInicialFqCol =
      '$atividadeFqtn.$atividadeInicialSourceCol';
  static const String atividadeTipoVisualizacaoCol = 'tipo_visualizacao';
  static const String atividadeTipoVisualizacaoFqCol =
      '$atividadeFqtn.$atividadeTipoVisualizacaoCol';

  static const String protocoloIdCol = 'id_protocolo';
  static const String protocoloIdFqCol = '$protocoloFqtn.$protocoloIdCol';
  static const String protocoloFormatadoSourceCol = 'protocolo_formatado';
  static const String protocoloFormatadoFqCol =
      '$protocoloFqtn.$protocoloFormatadoSourceCol';
  static const String protocoloDescricaoSourceCol = 'descricao';
  static const String protocoloDescricaoFqCol =
      '$protocoloFqtn.$protocoloDescricaoSourceCol';
  static const String protocoloEstadoSourceCol = 'sta_estado';
  static const String protocoloEstadoFqCol =
      '$protocoloFqtn.$protocoloEstadoSourceCol';

  static const String procedimentoIdCol = 'id_procedimento';
  static const String procedimentoIdFqCol =
      '$procedimentoFqtn.$procedimentoIdCol';
  static const String procedimentoIdTipoCol = 'id_tipo_procedimento';
  static const String procedimentoIdTipoFqCol =
      '$procedimentoFqtn.$procedimentoIdTipoCol';

  static const String tipoProcedimentoIdCol = 'id_tipo_procedimento';
  static const String tipoProcedimentoIdFqCol =
      '$tipoProcedimentoFqtn.$tipoProcedimentoIdCol';
  static const String tipoProcedimentoNomeSourceCol = 'nome';
  static const String tipoProcedimentoNomeFqCol =
      '$tipoProcedimentoFqtn.$tipoProcedimentoNomeSourceCol';

  static const String unidadeIdCol = 'id_unidade';
  static const String unidadeIdFqCol = '$unidadeFqtn.$unidadeIdCol';
  static const String unidadeSiglaSourceCol = 'sigla';
  static const String unidadeSiglaFqCol = '$unidadeFqtn.$unidadeSiglaSourceCol';
  static const String unidadeDescricaoSourceCol = 'descricao';
  static const String unidadeDescricaoFqCol =
      '$unidadeFqtn.$unidadeDescricaoSourceCol';
  static const String unidadeOrigemIdFqCol =
      '$unidadeOrigemAlias.$unidadeIdCol';
  static const String unidadeOrigemSiglaFqCol =
      '$unidadeOrigemAlias.$unidadeSiglaSourceCol';
  static const String unidadeOrigemDescricaoFqCol =
      '$unidadeOrigemAlias.$unidadeDescricaoSourceCol';

  static const String tarefaIdCol = 'id_tarefa';
  static const String tarefaIdFqCol = '$tarefaFqtn.$tarefaIdCol';
  static const String tarefaNomeSourceCol = 'nome';
  static const String tarefaNomeFqCol = '$tarefaFqtn.$tarefaNomeSourceCol';

  static const String usuarioIdCol = 'id_usuario';
  static const String usuarioAtribuicaoIdFqCol =
      '$usuarioAtribuicaoAlias.$usuarioIdCol';
  static const String usuarioAtividadeIdFqCol =
      '$usuarioAtividadeAlias.$usuarioIdCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioAtribuicaoNomeFqCol =
      '$usuarioAtribuicaoAlias.$usuarioNomeSourceCol';
  static const String usuarioAtividadeNomeFqCol =
      '$usuarioAtividadeAlias.$usuarioNomeSourceCol';

  static const String idAtividadeCol = 'id_atividade';
  static const String idProcessoCol = 'id_processo';
  static const String protocoloFormatadoCol = 'protocolo_formatado';
  static const String descricaoCol = 'descricao';
  static const String estadoProtocoloCol = 'estado_protocolo';
  static const String idTipoProcedimentoCol = 'id_tipo_procedimento';
  static const String tipoProcedimentoNomeCol = 'tipo_procedimento_nome';
  static const String idUnidadeCol = 'id_unidade';
  static const String unidadeSiglaCol = 'unidade_sigla';
  static const String unidadeDescricaoCol = 'unidade_descricao';
  static const String idUnidadeOrigemCol = 'id_unidade_origem';
  static const String unidadeOrigemSiglaCol = 'unidade_origem_sigla';
  static const String unidadeOrigemDescricaoCol = 'unidade_origem_descricao';
  static const String idTarefaCol = 'id_tarefa';
  static const String tarefaNomeCol = 'tarefa_nome';
  static const String idUsuarioAtribuicaoCol = 'id_usuario_atribuicao';
  static const String usuarioAtribuicaoNomeCol = 'usuario_atribuicao_nome';
  static const String idUsuarioAtividadeCol = 'id_usuario_atividade';
  static const String usuarioAtividadeNomeCol = 'usuario_atividade_nome';
  static const String dataAberturaCol = 'data_abertura';
  static const String dataPrazoCol = 'data_prazo';
  static const String atividadeInicialCol = 'atividade_inicial';
  static const String tipoVisualizacaoCol = 'tipo_visualizacao';

  ProcessoRecebidoItem({
    required this.idAtividade,
    required this.idProcesso,
    required this.protocoloFormatado,
    required this.estadoProtocolo,
    required this.idTipoProcedimento,
    required this.tipoProcedimentoNome,
    required this.idUnidade,
    required this.unidadeSigla,
    required this.unidadeDescricao,
    required this.idUnidadeOrigem,
    required this.unidadeOrigemSigla,
    required this.unidadeOrigemDescricao,
    required this.dataAbertura,
    required this.atividadeInicial,
    required this.tipoVisualizacao,
    this.descricao,
    this.idTarefa,
    this.tarefaNome,
    this.idUsuarioAtribuicao,
    this.usuarioAtribuicaoNome,
    this.idUsuarioAtividade,
    this.usuarioAtividadeNome,
    this.dataPrazo,
  });

  factory ProcessoRecebidoItem.fromMap(Map<String, dynamic> map) {
    return ProcessoRecebidoItem(
      idAtividade: SeiCoreUtils.inteiro(
        map[idAtividadeCol],
        nomeCampo: idAtividadeCol,
      ),
      idProcesso: SeiCoreUtils.identificadorParaString(
        map[idProcessoCol],
        nomeCampo: idProcessoCol,
      ),
      protocoloFormatado: map[protocoloFormatadoCol] as String,
      descricao: map[descricaoCol] as String?,
      estadoProtocolo: map[estadoProtocoloCol] as String,
      idTipoProcedimento: SeiCoreUtils.inteiro(
        map[idTipoProcedimentoCol],
        nomeCampo: idTipoProcedimentoCol,
      ),
      tipoProcedimentoNome: map[tipoProcedimentoNomeCol] as String,
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      unidadeSigla: map[unidadeSiglaCol] as String,
      unidadeDescricao: map[unidadeDescricaoCol] as String,
      idUnidadeOrigem: SeiCoreUtils.inteiro(
        map[idUnidadeOrigemCol],
        nomeCampo: idUnidadeOrigemCol,
      ),
      unidadeOrigemSigla: map[unidadeOrigemSiglaCol] as String,
      unidadeOrigemDescricao: map[unidadeOrigemDescricaoCol] as String,
      idTarefa: map[idTarefaCol] == null
          ? null
          : SeiCoreUtils.inteiro(map[idTarefaCol], nomeCampo: idTarefaCol),
      tarefaNome: map[tarefaNomeCol] as String?,
      idUsuarioAtribuicao: map[idUsuarioAtribuicaoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUsuarioAtribuicaoCol],
              nomeCampo: idUsuarioAtribuicaoCol,
            ),
      usuarioAtribuicaoNome: map[usuarioAtribuicaoNomeCol] as String?,
      idUsuarioAtividade: map[idUsuarioAtividadeCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUsuarioAtividadeCol],
              nomeCampo: idUsuarioAtividadeCol,
            ),
      usuarioAtividadeNome: map[usuarioAtividadeNomeCol] as String?,
      dataAbertura: SeiCoreUtils.dataHoraLocal(
        map[dataAberturaCol],
        nomeCampo: dataAberturaCol,
      ),
      dataPrazo: map[dataPrazoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataPrazoCol],
              nomeCampo: dataPrazoCol,
            ),
      atividadeInicial: SeiCoreUtils.simNaoParaBool(
        map[atividadeInicialCol] as String,
        nomeCampo: atividadeInicialCol,
      ),
      tipoVisualizacao: SeiCoreUtils.inteiro(
        map[tipoVisualizacaoCol],
        nomeCampo: tipoVisualizacaoCol,
      ),
    );
  }

  final int idAtividade;
  final String idProcesso;
  final String protocoloFormatado;
  final String? descricao;
  final String estadoProtocolo;
  final int idTipoProcedimento;
  final String tipoProcedimentoNome;
  final int idUnidade;
  final String unidadeSigla;
  final String unidadeDescricao;
  final int idUnidadeOrigem;
  final String unidadeOrigemSigla;
  final String unidadeOrigemDescricao;
  final int? idTarefa;
  final String? tarefaNome;
  final int? idUsuarioAtribuicao;
  final String? usuarioAtribuicaoNome;
  final int? idUsuarioAtividade;
  final String? usuarioAtividadeNome;
  final DateTime dataAbertura;
  final DateTime? dataPrazo;
  final bool atividadeInicial;
  final int tipoVisualizacao;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idAtividadeCol: idAtividade,
      idProcessoCol: idProcesso,
      protocoloFormatadoCol: protocoloFormatado,
      descricaoCol: descricao,
      estadoProtocoloCol: estadoProtocolo,
      idTipoProcedimentoCol: idTipoProcedimento,
      tipoProcedimentoNomeCol: tipoProcedimentoNome,
      idUnidadeCol: idUnidade,
      unidadeSiglaCol: unidadeSigla,
      unidadeDescricaoCol: unidadeDescricao,
      idUnidadeOrigemCol: idUnidadeOrigem,
      unidadeOrigemSiglaCol: unidadeOrigemSigla,
      unidadeOrigemDescricaoCol: unidadeOrigemDescricao,
      idTarefaCol: idTarefa,
      tarefaNomeCol: tarefaNome,
      idUsuarioAtribuicaoCol: idUsuarioAtribuicao,
      usuarioAtribuicaoNomeCol: usuarioAtribuicaoNome,
      idUsuarioAtividadeCol: idUsuarioAtividade,
      usuarioAtividadeNomeCol: usuarioAtividadeNome,
      dataAberturaCol: dataAbertura.toIso8601String(),
      dataPrazoCol: dataPrazo?.toIso8601String(),
      atividadeInicialCol: SeiCoreUtils.boolParaSimNao(atividadeInicial),
      tipoVisualizacaoCol: tipoVisualizacao,
    };
  }
}
