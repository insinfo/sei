import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Tipo de andamento do SEI e as marcações que governam o estado do processo.
///
/// A tabela `tarefa` é o catálogo que decide o efeito de cada evento sobre as
/// atividades abertas da unidade. É ela que explica por que enviar um processo
/// não conclui por si só: a tarefa de remessa não fecha andamentos abertos, e
/// quem fecha é a tarefa de conclusão automática lançada em seguida.
///
/// Este DTO é a projeção somente leitura do catálogo; ele não representa uma
/// atividade lançada, que vive em `atividade`.
class TarefaCatalogo extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'tarefa';
  static const String fqtn = '$schemaName.$tableName';

  static const String idTarefaCol = 'id_tarefa';
  static const String idTarefaFqCol = '$fqtn.$idTarefaCol';
  static const String idTarefaModuloCol = 'id_tarefa_modulo';
  static const String idTarefaModuloFqCol = '$fqtn.$idTarefaModuloCol';
  static const String nomeCol = 'nome';
  static const String nomeFqCol = '$fqtn.$nomeCol';
  static const String historicoResumidoCol = 'sin_historico_resumido';
  static const String historicoResumidoFqCol = '$fqtn.$historicoResumidoCol';
  static const String historicoCompletoCol = 'sin_historico_completo';
  static const String historicoCompletoFqCol = '$fqtn.$historicoCompletoCol';
  static const String fecharAndamentosAbertosCol =
      'sin_fechar_andamentos_abertos';
  static const String fecharAndamentosAbertosFqCol =
      '$fqtn.$fecharAndamentosAbertosCol';
  static const String lancarAndamentoFechadoCol =
      'sin_lancar_andamento_fechado';
  static const String lancarAndamentoFechadoFqCol =
      '$fqtn.$lancarAndamentoFechadoCol';
  static const String permiteProcessoFechadoCol =
      'sin_permite_processo_fechado';
  static const String permiteProcessoFechadoFqCol =
      '$fqtn.$permiteProcessoFechadoCol';
  static const String consultaProcessualCol = 'sin_consulta_processual';
  static const String consultaProcessualFqCol = '$fqtn.$consultaProcessualCol';

  TarefaCatalogo({
    required this.idTarefa,
    required this.nome,
    required this.historicoResumido,
    required this.historicoCompleto,
    required this.fechaAndamentosAbertos,
    required this.lancaAndamentoFechado,
    required this.permiteProcessoFechado,
    required this.consultaProcessual,
    this.idTarefaModulo,
  });

  factory TarefaCatalogo.fromMap(Map<String, dynamic> map) {
    return TarefaCatalogo(
      idTarefa: SeiCoreUtils.inteiro(map[idTarefaCol], nomeCampo: idTarefaCol),
      idTarefaModulo: map[idTarefaModuloCol] as String?,
      nome: map[nomeCol] as String,
      historicoResumido: SeiCoreUtils.simNaoParaBool(
        map[historicoResumidoCol] as String,
        nomeCampo: historicoResumidoCol,
      ),
      historicoCompleto: SeiCoreUtils.simNaoParaBool(
        map[historicoCompletoCol] as String,
        nomeCampo: historicoCompletoCol,
      ),
      fechaAndamentosAbertos: SeiCoreUtils.simNaoParaBool(
        map[fecharAndamentosAbertosCol] as String,
        nomeCampo: fecharAndamentosAbertosCol,
      ),
      lancaAndamentoFechado: SeiCoreUtils.simNaoParaBool(
        map[lancarAndamentoFechadoCol] as String,
        nomeCampo: lancarAndamentoFechadoCol,
      ),
      permiteProcessoFechado: SeiCoreUtils.simNaoParaBool(
        map[permiteProcessoFechadoCol] as String,
        nomeCampo: permiteProcessoFechadoCol,
      ),
      consultaProcessual: SeiCoreUtils.simNaoParaBool(
        map[consultaProcessualCol] as String,
        nomeCampo: consultaProcessualCol,
      ),
    );
  }

  final int idTarefa;
  final String? idTarefaModulo;
  final String nome;

  /// Indica que o andamento aparece na visão resumida de Consultar Andamento.
  final bool historicoResumido;

  /// Indica que o andamento aparece na visão completa do histórico.
  final bool historicoCompleto;

  /// Indica que lançar esta tarefa conclui as atividades abertas da unidade.
  final bool fechaAndamentosAbertos;

  /// Indica que a própria atividade nasce concluída e não deixa o processo
  /// aberto na unidade.
  final bool lancaAndamentoFechado;

  /// Indica que o evento é permitido mesmo com o processo já concluído na
  /// unidade, como assinar documento ou movimentar bloco.
  final bool permiteProcessoFechado;

  /// Indica que o andamento é exposto na consulta processual pública.
  final bool consultaProcessual;

  /// Indica que a tarefa encerra a presença do processo na unidade.
  ///
  /// É a combinação usada pelas conclusões: fecha o que estava aberto e não
  /// abre nada no lugar.
  bool get encerraPresencaNaUnidade =>
      fechaAndamentosAbertos && lancaAndamentoFechado;

  /// Indica que a tarefa deixa o processo aberto na unidade após o lançamento.
  bool get mantemProcessoAbertoNaUnidade => !lancaAndamentoFechado;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idTarefaCol: idTarefa,
      idTarefaModuloCol: idTarefaModulo,
      nomeCol: nome,
      historicoResumidoCol: SeiCoreUtils.boolParaSimNao(historicoResumido),
      historicoCompletoCol: SeiCoreUtils.boolParaSimNao(historicoCompleto),
      fecharAndamentosAbertosCol:
          SeiCoreUtils.boolParaSimNao(fechaAndamentosAbertos),
      lancarAndamentoFechadoCol:
          SeiCoreUtils.boolParaSimNao(lancaAndamentoFechado),
      permiteProcessoFechadoCol:
          SeiCoreUtils.boolParaSimNao(permiteProcessoFechado),
      consultaProcessualCol: SeiCoreUtils.boolParaSimNao(consultaProcessual),
    };
  }
}
