import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Anotação de uma unidade sobre um processo, com o nome do autor resolvido.
///
/// Projeção somente leitura de `anotacao`; a escrita usa a entidade
/// [Anotacao]. A visibilidade é exclusiva da unidade que criou a anotação —
/// esta projeção não filtra por unidade, e cabe ao repositório aplicar o
/// filtro conforme a unidade do usuário que consulta.
class ProcessoAnotacao extends BaseModel {
  static const String schemaName = 'public';

  static const String anotacaoFqtn = '$schemaName.anotacao';
  static const String usuarioFqtn = '$schemaName.usuario';

  static const String anotacaoIdSourceCol = 'id_anotacao';
  static const String anotacaoIdFqCol = '$anotacaoFqtn.$anotacaoIdSourceCol';
  static const String anotacaoIdProtocoloSourceCol = 'id_protocolo';
  static const String anotacaoIdProtocoloFqCol =
      '$anotacaoFqtn.$anotacaoIdProtocoloSourceCol';
  static const String anotacaoIdUnidadeSourceCol = 'id_unidade';
  static const String anotacaoIdUnidadeFqCol =
      '$anotacaoFqtn.$anotacaoIdUnidadeSourceCol';
  static const String anotacaoIdUsuarioSourceCol = 'id_usuario';
  static const String anotacaoIdUsuarioFqCol =
      '$anotacaoFqtn.$anotacaoIdUsuarioSourceCol';
  static const String anotacaoDescricaoSourceCol = 'descricao';
  static const String anotacaoDescricaoFqCol =
      '$anotacaoFqtn.$anotacaoDescricaoSourceCol';
  static const String anotacaoDataSourceCol = 'dth_anotacao';
  static const String anotacaoDataFqCol =
      '$anotacaoFqtn.$anotacaoDataSourceCol';
  static const String anotacaoPrioridadeSourceCol = 'sin_prioridade';
  static const String anotacaoPrioridadeFqCol =
      '$anotacaoFqtn.$anotacaoPrioridadeSourceCol';
  static const String anotacaoSituacaoSourceCol = 'sta_anotacao';
  static const String anotacaoSituacaoFqCol =
      '$anotacaoFqtn.$anotacaoSituacaoSourceCol';

  static const String usuarioIdSourceCol = 'id_usuario';
  static const String usuarioIdFqCol = '$usuarioFqtn.$usuarioIdSourceCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioNomeFqCol = '$usuarioFqtn.$usuarioNomeSourceCol';

  static const String idAnotacaoCol = 'id_anotacao';
  static const String descricaoCol = 'descricao';
  static const String dataAnotacaoCol = 'data_anotacao';
  static const String prioridadeCol = 'prioridade';
  static const String situacaoCol = 'situacao';
  static const String idUsuarioCol = 'id_usuario';
  static const String usuarioNomeCol = 'usuario_nome';

  ProcessoAnotacao({
    required this.idAnotacao,
    required this.dataAnotacao,
    required this.prioridade,
    required this.situacao,
    required this.idUsuario,
    required this.usuarioNome,
    this.descricao,
  });

  factory ProcessoAnotacao.fromMap(Map<String, dynamic> map) {
    return ProcessoAnotacao(
      idAnotacao: SeiCoreUtils.inteiro(
        map[idAnotacaoCol],
        nomeCampo: idAnotacaoCol,
      ),
      descricao: map[descricaoCol] as String?,
      dataAnotacao: SeiCoreUtils.dataHoraLocal(
        map[dataAnotacaoCol],
        nomeCampo: dataAnotacaoCol,
      ),
      prioridade: SeiCoreUtils.simNaoParaBool(
        (map[prioridadeCol] as String).trim(),
        nomeCampo: prioridadeCol,
      ),
      situacao: (map[situacaoCol] as String).trim(),
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      usuarioNome: map[usuarioNomeCol] as String,
    );
  }

  final int idAnotacao;
  final String? descricao;
  final DateTime dataAnotacao;
  final bool prioridade;
  final String situacao;
  final int idUsuario;
  final String usuarioNome;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idAnotacaoCol: idAnotacao,
      descricaoCol: descricao,
      dataAnotacaoCol: dataAnotacao.toIso8601String(),
      prioridadeCol: SeiCoreUtils.boolParaSimNao(prioridade),
      situacaoCol: situacao,
      idUsuarioCol: idUsuario,
      usuarioNomeCol: usuarioNome,
    };
  }
}
