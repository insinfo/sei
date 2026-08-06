import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Atividade aberta de processo, projetada para o Controle de Processos.
class ProcessoRecebidoItem extends BaseModel {
  static const schemaName = 'public';

  static const atividadeFqtn = '$schemaName.atividade';
  static const protocoloFqtn = '$schemaName.protocolo';
  static const procedimentoFqtn = '$schemaName.procedimento';
  static const tipoProcedimentoFqtn = '$schemaName.tipo_procedimento';
  static const unidadeFqtn = '$schemaName.unidade';
  static const tarefaFqtn = '$schemaName.tarefa';
  static const usuarioFqtn = '$schemaName.usuario';

  static const unidadeOrigemAlias = 'unidade_origem';
  static const unidadeOrigemAliasTable = '$unidadeFqtn as $unidadeOrigemAlias';
  static const usuarioAtribuicaoAlias = 'usuario_atribuicao';
  static const usuarioAtribuicaoAliasTable =
      '$usuarioFqtn as $usuarioAtribuicaoAlias';
  static const usuarioAtividadeAlias = 'usuario_atividade';
  static const usuarioAtividadeAliasTable =
      '$usuarioFqtn as $usuarioAtividadeAlias';

  static const atividadeIdCol = 'id_atividade';
  static const atividadeIdFqCol = '$atividadeFqtn.$atividadeIdCol';
  static const atividadeIdProtocoloCol = 'id_protocolo';
  static const atividadeIdProtocoloFqCol =
      '$atividadeFqtn.$atividadeIdProtocoloCol';
  static const atividadeIdUnidadeCol = 'id_unidade';
  static const atividadeIdUnidadeFqCol =
      '$atividadeFqtn.$atividadeIdUnidadeCol';
  static const atividadeIdUnidadeOrigemCol = 'id_unidade_origem';
  static const atividadeIdUnidadeOrigemFqCol =
      '$atividadeFqtn.$atividadeIdUnidadeOrigemCol';
  static const atividadeIdTarefaCol = 'id_tarefa';
  static const atividadeIdTarefaFqCol = '$atividadeFqtn.$atividadeIdTarefaCol';
  static const atividadeIdUsuarioAtribuicaoCol = 'id_usuario_atribuicao';
  static const atividadeIdUsuarioAtribuicaoFqCol =
      '$atividadeFqtn.$atividadeIdUsuarioAtribuicaoCol';
  static const atividadeIdUsuarioCol = 'id_usuario';
  static const atividadeIdUsuarioFqCol =
      '$atividadeFqtn.$atividadeIdUsuarioCol';
  static const atividadeAberturaCol = 'dth_abertura';
  static const atividadeAberturaFqCol = '$atividadeFqtn.$atividadeAberturaCol';
  static const atividadeConclusaoCol = 'dth_conclusao';
  static const atividadeConclusaoFqCol =
      '$atividadeFqtn.$atividadeConclusaoCol';
  static const atividadePrazoCol = 'dta_prazo';
  static const atividadePrazoFqCol = '$atividadeFqtn.$atividadePrazoCol';
  static const atividadeInicialSourceCol = 'sin_inicial';
  static const atividadeInicialFqCol =
      '$atividadeFqtn.$atividadeInicialSourceCol';
  static const atividadeTipoVisualizacaoCol = 'tipo_visualizacao';
  static const atividadeTipoVisualizacaoFqCol =
      '$atividadeFqtn.$atividadeTipoVisualizacaoCol';

  static const protocoloIdCol = 'id_protocolo';
  static const protocoloIdFqCol = '$protocoloFqtn.$protocoloIdCol';
  static const protocoloFormatadoSourceCol = 'protocolo_formatado';
  static const protocoloFormatadoFqCol =
      '$protocoloFqtn.$protocoloFormatadoSourceCol';
  static const protocoloDescricaoSourceCol = 'descricao';
  static const protocoloDescricaoFqCol =
      '$protocoloFqtn.$protocoloDescricaoSourceCol';
  static const protocoloEstadoSourceCol = 'sta_estado';
  static const protocoloEstadoFqCol =
      '$protocoloFqtn.$protocoloEstadoSourceCol';

  static const procedimentoIdCol = 'id_procedimento';
  static const procedimentoIdFqCol = '$procedimentoFqtn.$procedimentoIdCol';
  static const procedimentoIdTipoCol = 'id_tipo_procedimento';
  static const procedimentoIdTipoFqCol =
      '$procedimentoFqtn.$procedimentoIdTipoCol';

  static const tipoProcedimentoIdCol = 'id_tipo_procedimento';
  static const tipoProcedimentoIdFqCol =
      '$tipoProcedimentoFqtn.$tipoProcedimentoIdCol';
  static const tipoProcedimentoNomeSourceCol = 'nome';
  static const tipoProcedimentoNomeFqCol =
      '$tipoProcedimentoFqtn.$tipoProcedimentoNomeSourceCol';

  static const unidadeIdCol = 'id_unidade';
  static const unidadeIdFqCol = '$unidadeFqtn.$unidadeIdCol';
  static const unidadeSiglaSourceCol = 'sigla';
  static const unidadeSiglaFqCol = '$unidadeFqtn.$unidadeSiglaSourceCol';
  static const unidadeDescricaoSourceCol = 'descricao';
  static const unidadeDescricaoFqCol =
      '$unidadeFqtn.$unidadeDescricaoSourceCol';
  static const unidadeOrigemIdFqCol = '$unidadeOrigemAlias.$unidadeIdCol';
  static const unidadeOrigemSiglaFqCol =
      '$unidadeOrigemAlias.$unidadeSiglaSourceCol';
  static const unidadeOrigemDescricaoFqCol =
      '$unidadeOrigemAlias.$unidadeDescricaoSourceCol';

  static const tarefaIdCol = 'id_tarefa';
  static const tarefaIdFqCol = '$tarefaFqtn.$tarefaIdCol';
  static const tarefaNomeSourceCol = 'nome';
  static const tarefaNomeFqCol = '$tarefaFqtn.$tarefaNomeSourceCol';

  static const usuarioIdCol = 'id_usuario';
  static const usuarioAtribuicaoIdFqCol =
      '$usuarioAtribuicaoAlias.$usuarioIdCol';
  static const usuarioAtividadeIdFqCol = '$usuarioAtividadeAlias.$usuarioIdCol';
  static const usuarioNomeSourceCol = 'nome';
  static const usuarioAtribuicaoNomeFqCol =
      '$usuarioAtribuicaoAlias.$usuarioNomeSourceCol';
  static const usuarioAtividadeNomeFqCol =
      '$usuarioAtividadeAlias.$usuarioNomeSourceCol';

  static const idAtividadeCol = 'id_atividade';
  static const idProcessoCol = 'id_processo';
  static const protocoloFormatadoCol = 'protocolo_formatado';
  static const descricaoCol = 'descricao';
  static const estadoProtocoloCol = 'estado_protocolo';
  static const idTipoProcedimentoCol = 'id_tipo_procedimento';
  static const tipoProcedimentoNomeCol = 'tipo_procedimento_nome';
  static const idUnidadeCol = 'id_unidade';
  static const unidadeSiglaCol = 'unidade_sigla';
  static const unidadeDescricaoCol = 'unidade_descricao';
  static const idUnidadeOrigemCol = 'id_unidade_origem';
  static const unidadeOrigemSiglaCol = 'unidade_origem_sigla';
  static const unidadeOrigemDescricaoCol = 'unidade_origem_descricao';
  static const idTarefaCol = 'id_tarefa';
  static const tarefaNomeCol = 'tarefa_nome';
  static const idUsuarioAtribuicaoCol = 'id_usuario_atribuicao';
  static const usuarioAtribuicaoNomeCol = 'usuario_atribuicao_nome';
  static const idUsuarioAtividadeCol = 'id_usuario_atividade';
  static const usuarioAtividadeNomeCol = 'usuario_atividade_nome';
  static const dataAberturaCol = 'data_abertura';
  static const dataPrazoCol = 'data_prazo';
  static const atividadeInicialCol = 'atividade_inicial';
  static const tipoVisualizacaoCol = 'tipo_visualizacao';

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
    final map = <String, dynamic>{
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

    return map;
  }
}
