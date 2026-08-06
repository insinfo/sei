import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Sistema ativo cadastrado na Base de Referência do SIP.
class SistemaSipResumo extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sistema';
  static const String fqtn = '$schemaName.$tableName';

  static const String idSistemaCol = 'id_sistema';
  static const String idSistemaFqCol = '$fqtn.$idSistemaCol';
  static const String siglaCol = 'sigla';
  static const String siglaFqCol = '$fqtn.$siglaCol';
  static const String descricaoCol = 'descricao';
  static const String descricaoFqCol = '$fqtn.$descricaoCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';

  SistemaSipResumo({
    required this.idSistema,
    required this.sigla,
    required this.descricao,
    required this.ativo,
  });

  factory SistemaSipResumo.fromMap(Map<String, dynamic> map) {
    return SistemaSipResumo(
      idSistema: SeiCoreUtils.inteiro(
        map[idSistemaCol],
        nomeCampo: idSistemaCol,
      ),
      sigla: map[siglaCol] as String,
      descricao: map[descricaoCol] as String,
      ativo: SeiCoreUtils.simNaoParaBool(
        map[ativoCol] as String,
        nomeCampo: ativoCol,
      ),
    );
  }

  final int idSistema;
  final String sigla;
  final String descricao;
  final bool ativo;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idSistemaCol: idSistema,
      siglaCol: sigla,
      descricaoCol: descricao,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
    };
  }
}
