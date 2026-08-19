import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Órgão ativo exibido no seletor da tela de login.
///
/// Projeção deliberadamente estreita: a rota `GET /api/v1/auth/orgaos` não
/// exige autenticação (é consultada antes do login para popular o
/// dropdown), então não deve expor colunas internas do cadastro completo de
/// [Orgao] (timbre, numeração, corretor ortográfico etc.). Por não
/// representar uma linha gravável, herda `toInsertMap`/`toUpdateMap` de
/// `BaseModel` com erro explícito.
class OrgaoLoginResumo extends BaseModel {
  static const String idOrgaoCol = 'id_orgao';
  static const String siglaCol = 'sigla';
  static const String descricaoCol = 'descricao';

  OrgaoLoginResumo({
    required this.idOrgao,
    required this.sigla,
    required this.descricao,
  });

  factory OrgaoLoginResumo.fromMap(Map<String, dynamic> map) {
    return OrgaoLoginResumo(
      idOrgao: SeiCoreUtils.inteiro(map[idOrgaoCol], nomeCampo: idOrgaoCol),
      sigla: map[siglaCol] as String,
      descricao: map[descricaoCol] as String,
    );
  }

  final int idOrgao;
  final String sigla;
  final String descricao;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idOrgaoCol: idOrgao,
      siglaCol: sigla,
      descricaoCol: descricao,
    };
  }
}
