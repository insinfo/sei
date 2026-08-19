import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Acompanhamento especial do processo, com o grupo e o autor resolvidos.
///
/// Projeção somente leitura de `acompanhamento`; a escrita usa a entidade
/// [Acompanhamento]. Diferente do Bloco Interno, o Acompanhamento Especial não
/// exige que o processo esteja aberto na unidade que acompanha.
class ProcessoAcompanhamento extends BaseModel {
  static const String schemaName = 'public';

  static const String acompanhamentoFqtn = '$schemaName.acompanhamento';
  static const String grupoFqtn = '$schemaName.grupo_acompanhamento';
  static const String unidadeFqtn = '$schemaName.unidade';
  static const String usuarioFqtn = '$schemaName.usuario';

  static const String acompanhamentoIdSourceCol = 'id_acompanhamento';
  static const String acompanhamentoIdFqCol =
      '$acompanhamentoFqtn.$acompanhamentoIdSourceCol';
  static const String acompanhamentoIdProtocoloSourceCol = 'id_protocolo';
  static const String acompanhamentoIdProtocoloFqCol =
      '$acompanhamentoFqtn.$acompanhamentoIdProtocoloSourceCol';
  static const String acompanhamentoIdUnidadeSourceCol = 'id_unidade';
  static const String acompanhamentoIdUnidadeFqCol =
      '$acompanhamentoFqtn.$acompanhamentoIdUnidadeSourceCol';
  static const String acompanhamentoIdGrupoSourceCol =
      'id_grupo_acompanhamento';
  static const String acompanhamentoIdGrupoFqCol =
      '$acompanhamentoFqtn.$acompanhamentoIdGrupoSourceCol';
  static const String acompanhamentoObservacaoSourceCol = 'observacao';
  static const String acompanhamentoObservacaoFqCol =
      '$acompanhamentoFqtn.$acompanhamentoObservacaoSourceCol';
  static const String acompanhamentoDataSourceCol = 'dth_alteracao';
  static const String acompanhamentoDataFqCol =
      '$acompanhamentoFqtn.$acompanhamentoDataSourceCol';
  static const String acompanhamentoIdUsuarioSourceCol = 'id_usuario';
  static const String acompanhamentoIdUsuarioFqCol =
      '$acompanhamentoFqtn.$acompanhamentoIdUsuarioSourceCol';

  static const String grupoIdSourceCol = 'id_grupo_acompanhamento';
  static const String grupoIdFqCol = '$grupoFqtn.$grupoIdSourceCol';
  static const String grupoNomeSourceCol = 'nome';
  static const String grupoNomeFqCol = '$grupoFqtn.$grupoNomeSourceCol';

  static const String unidadeIdSourceCol = 'id_unidade';
  static const String unidadeIdFqCol = '$unidadeFqtn.$unidadeIdSourceCol';
  static const String unidadeSiglaSourceCol = 'sigla';
  static const String unidadeSiglaFqCol = '$unidadeFqtn.$unidadeSiglaSourceCol';

  static const String usuarioIdSourceCol = 'id_usuario';
  static const String usuarioIdFqCol = '$usuarioFqtn.$usuarioIdSourceCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioNomeFqCol = '$usuarioFqtn.$usuarioNomeSourceCol';

  static const String idAcompanhamentoCol = 'id_acompanhamento';
  static const String idUnidadeCol = 'id_unidade';
  static const String unidadeSiglaCol = 'unidade_sigla';
  static const String idGrupoAcompanhamentoCol = 'id_grupo_acompanhamento';
  static const String grupoNomeCol = 'grupo_nome';
  static const String observacaoCol = 'observacao';
  static const String dataAlteracaoCol = 'data_alteracao';
  static const String idUsuarioCol = 'id_usuario';
  static const String usuarioNomeCol = 'usuario_nome';

  ProcessoAcompanhamento({
    required this.idAcompanhamento,
    required this.idUnidade,
    required this.unidadeSigla,
    required this.dataAlteracao,
    required this.idUsuario,
    required this.usuarioNome,
    this.idGrupoAcompanhamento,
    this.grupoNome,
    this.observacao,
  });

  factory ProcessoAcompanhamento.fromMap(Map<String, dynamic> map) {
    return ProcessoAcompanhamento(
      idAcompanhamento: SeiCoreUtils.inteiro(
        map[idAcompanhamentoCol],
        nomeCampo: idAcompanhamentoCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      unidadeSigla: map[unidadeSiglaCol] as String,
      idGrupoAcompanhamento: map[idGrupoAcompanhamentoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idGrupoAcompanhamentoCol],
              nomeCampo: idGrupoAcompanhamentoCol,
            ),
      grupoNome: map[grupoNomeCol] as String?,
      observacao: map[observacaoCol] as String?,
      dataAlteracao: SeiCoreUtils.dataHoraLocal(
        map[dataAlteracaoCol],
        nomeCampo: dataAlteracaoCol,
      ),
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      usuarioNome: map[usuarioNomeCol] as String,
    );
  }

  final int idAcompanhamento;

  /// Unidade que acompanha o processo; não é necessariamente a unidade onde
  /// ele está aberto.
  final int idUnidade;
  final String unidadeSigla;
  final int? idGrupoAcompanhamento;
  final String? grupoNome;
  final String? observacao;
  final DateTime dataAlteracao;
  final int idUsuario;
  final String usuarioNome;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idAcompanhamentoCol: idAcompanhamento,
      idUnidadeCol: idUnidade,
      unidadeSiglaCol: unidadeSigla,
      idGrupoAcompanhamentoCol: idGrupoAcompanhamento,
      grupoNomeCol: grupoNome,
      observacaoCol: observacao,
      dataAlteracaoCol: dataAlteracao.toIso8601String(),
      idUsuarioCol: idUsuario,
      usuarioNomeCol: usuarioNome,
    };
  }
}
