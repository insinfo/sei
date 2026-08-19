import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Grupo usado para organizar blocos da unidade, gravável em `grupo_bloco`.
///
/// O manual do usuário descreve o grupo como reutilizável entre os três
/// tipos de bloco: "um Grupo pode ter sido criado ao se utilizar um Bloco de
/// Assinatura e, posteriormente, um Bloco Interno poderá ser incluído neste
/// Grupo". O vínculo entre um grupo e um bloco vive em
/// `rel_bloco_unidade.id_grupo_bloco`, não nesta tabela.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap].
class GrupoBloco extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'grupo_bloco';
  static const String fqtn = '$schemaName.$tableName';

  static const String idGrupoBlocoCol = 'id_grupo_bloco';
  static const String idGrupoBlocoFqCol = '$fqtn.$idGrupoBlocoCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String nomeCol = 'nome';
  static const String nomeFqCol = '$fqtn.$nomeCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';

  GrupoBloco({
    required this.idGrupoBloco,
    required this.idUnidade,
    required this.nome,
    this.ativo = true,
  });

  factory GrupoBloco.fromMap(Map<String, dynamic> map) {
    return GrupoBloco(
      idGrupoBloco: SeiCoreUtils.inteiro(
        map[idGrupoBlocoCol],
        nomeCampo: idGrupoBlocoCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      nome: map[nomeCol] as String,
      ativo: SeiCoreUtils.simNaoParaBool(
        (map[ativoCol] as String).trim(),
        nomeCampo: ativoCol,
      ),
    );
  }

  /// Identificador do grupo, atribuído pela aplicação.
  final int idGrupoBloco;
  final int idUnidade;
  final String nome;

  /// Grupo desativado não aceita novo bloco, mas os já vinculados permanecem.
  final bool ativo;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idGrupoBlocoCol: idGrupoBloco,
      idUnidadeCol: idUnidade,
      nomeCol: nome,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idGrupoBlocoCol);
    return mapa;
  }
}
