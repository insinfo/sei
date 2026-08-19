import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Especialização de `protocolo` que representa o processo administrativo.
///
/// A linha compartilha a chave com `protocolo`: `id_procedimento` é a mesma
/// identidade e é atribuída pela aplicação, sem `DEFAULT` no banco. Por isso a
/// chave participa de [toInsertMap].
class Procedimento extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'procedimento';
  static const String fqtn = '$schemaName.$tableName';

  static const String idProcedimentoCol = 'id_procedimento';
  static const String idProcedimentoFqCol = '$fqtn.$idProcedimentoCol';
  static const String idTipoProcedimentoCol = 'id_tipo_procedimento';
  static const String idTipoProcedimentoFqCol = '$fqtn.$idTipoProcedimentoCol';
  static const String cienciaCol = 'sin_ciencia';
  static const String cienciaFqCol = '$fqtn.$cienciaCol';
  static const String idPlanoTrabalhoCol = 'id_plano_trabalho';
  static const String idPlanoTrabalhoFqCol = '$fqtn.$idPlanoTrabalhoCol';
  static const String dataConclusaoCol = 'dta_conclusao';
  static const String dataConclusaoFqCol = '$fqtn.$dataConclusaoCol';
  static const String dataEliminacaoCol = 'dta_eliminacao';
  static const String dataEliminacaoFqCol = '$fqtn.$dataEliminacaoCol';
  static const String idTipoPrioridadeCol = 'id_tipo_prioridade';
  static const String idTipoPrioridadeFqCol = '$fqtn.$idTipoPrioridadeCol';

  Procedimento({
    required this.idProcedimento,
    required this.idTipoProcedimento,
    this.ciencia = false,
    this.idPlanoTrabalho,
    this.dataConclusao,
    this.dataEliminacao,
    this.idTipoPrioridade,
  });

  factory Procedimento.fromMap(Map<String, dynamic> map) {
    return Procedimento(
      idProcedimento: SeiCoreUtils.inteiro(
        map[idProcedimentoCol],
        nomeCampo: idProcedimentoCol,
      ),
      idTipoProcedimento: SeiCoreUtils.inteiro(
        map[idTipoProcedimentoCol],
        nomeCampo: idTipoProcedimentoCol,
      ),
      ciencia: SeiCoreUtils.simNaoParaBool(
        (map[cienciaCol] as String).trim(),
        nomeCampo: cienciaCol,
      ),
      idPlanoTrabalho: map[idPlanoTrabalhoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idPlanoTrabalhoCol],
              nomeCampo: idPlanoTrabalhoCol,
            ),
      dataConclusao: map[dataConclusaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataConclusaoCol],
              nomeCampo: dataConclusaoCol,
            ),
      dataEliminacao: map[dataEliminacaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataEliminacaoCol],
              nomeCampo: dataEliminacaoCol,
            ),
      idTipoPrioridade: map[idTipoPrioridadeCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idTipoPrioridadeCol],
              nomeCampo: idTipoPrioridadeCol,
            ),
    );
  }

  /// Identidade compartilhada com `protocolo.id_protocolo`.
  final int idProcedimento;
  final int idTipoProcedimento;

  /// Marcação de ciência registrada no processo.
  final bool ciencia;

  final int? idPlanoTrabalho;

  /// Data de conclusão no nível do procedimento.
  ///
  /// É distinta das conclusões por unidade, que vivem em
  /// `atividade.dth_conclusao`. O momento exato em que o SEI a preenche não
  /// está comprovado pelas fontes locais e está registrado como lacuna em
  /// `backend/docs/evidencias_processo_detalhe.md`.
  final DateTime? dataConclusao;

  /// Data de eliminação do processo pelo fluxo de destinação arquivística.
  final DateTime? dataEliminacao;

  final int? idTipoPrioridade;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idProcedimentoCol: idProcedimento,
      idTipoProcedimentoCol: idTipoProcedimento,
      cienciaCol: SeiCoreUtils.boolParaSimNao(ciencia),
      idPlanoTrabalhoCol: idPlanoTrabalho,
      dataConclusaoCol: dataConclusao,
      dataEliminacaoCol: dataEliminacao,
      idTipoPrioridadeCol: idTipoPrioridade,
    };
  }

  /// Mapa de inserção com a chave, que é a mesma identidade do protocolo.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idProcedimentoCol);
    return mapa;
  }
}
