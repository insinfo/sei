import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Grupo usado para organizar acompanhamentos especiais da unidade.
///
/// Gravável em `grupo_acompanhamento`. O identificador é atribuído pela
/// aplicação, sem `DEFAULT` no banco, e por isso participa de [toInsertMap].
class GrupoAcompanhamento extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'grupo_acompanhamento';
  static const String fqtn = '$schemaName.$tableName';

  static const String idGrupoAcompanhamentoCol = 'id_grupo_acompanhamento';
  static const String idGrupoAcompanhamentoFqCol =
      '$fqtn.$idGrupoAcompanhamentoCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String nomeCol = 'nome';
  static const String nomeFqCol = '$fqtn.$nomeCol';

  GrupoAcompanhamento({
    required this.idGrupoAcompanhamento,
    required this.idUnidade,
    required this.nome,
  });

  factory GrupoAcompanhamento.fromMap(Map<String, dynamic> map) {
    return GrupoAcompanhamento(
      idGrupoAcompanhamento: SeiCoreUtils.inteiro(
        map[idGrupoAcompanhamentoCol],
        nomeCampo: idGrupoAcompanhamentoCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      nome: map[nomeCol] as String,
    );
  }

  /// Identificador do grupo, atribuído pela aplicação.
  final int idGrupoAcompanhamento;
  final int idUnidade;
  final String nome;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idGrupoAcompanhamentoCol: idGrupoAcompanhamento,
      idUnidadeCol: idUnidade,
      nomeCol: nome,
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idGrupoAcompanhamentoCol);
    return mapa;
  }
}
