import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Unidade organizacional disponível no contexto local de desenvolvimento.
class UnidadeResumo extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'unidade';
  static const String fqtn = '$schemaName.$tableName';

  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idOrgaoCol = 'id_orgao';
  static const String idOrgaoFqCol = '$fqtn.$idOrgaoCol';
  static const String siglaCol = 'sigla';
  static const String siglaFqCol = '$fqtn.$siglaCol';
  static const String descricaoCol = 'descricao';
  static const String descricaoFqCol = '$fqtn.$descricaoCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';

  UnidadeResumo({
    required this.idUnidade,
    required this.idOrgao,
    required this.sigla,
    required this.descricao,
    required this.ativo,
  });

  factory UnidadeResumo.fromMap(Map<String, dynamic> map) {
    return UnidadeResumo(
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      idOrgao: SeiCoreUtils.inteiro(
        map[idOrgaoCol],
        nomeCampo: idOrgaoCol,
      ),
      sigla: map[siglaCol] as String,
      descricao: map[descricaoCol] as String,
      ativo: SeiCoreUtils.simNaoParaBool(
        map[ativoCol] as String,
        nomeCampo: ativoCol,
      ),
    );
  }

  final int idUnidade;
  final int idOrgao;
  final String sigla;
  final String descricao;
  final bool ativo;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idUnidadeCol: idUnidade,
      idOrgaoCol: idOrgao,
      siglaCol: sigla,
      descricaoCol: descricao,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
    };
  }
}
