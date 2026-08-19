import 'package:sei_frontend/src/modules/administracao/models/administracao_parsing.dart';

/// Detalhe somente leitura de um órgão (`GET /orgaos/:idOrgao`).
///
/// `codigoSei` e `sinPublicacao` são opcionais porque podem não estar
/// projetados pelo backend nesta rodada; a tela mostra o que vier.
class OrgaoDetalhe {
  OrgaoDetalhe({
    required this.idOrgao,
    required this.sigla,
    required this.descricao,
    required this.ativo,
    this.codigoSei,
    this.publicacao,
  });

  factory OrgaoDetalhe.fromMap(Map<String, dynamic> map) {
    return OrgaoDetalhe(
      idOrgao: AdministracaoParsing.inteiroOpcional(map['id_orgao']) ?? 0,
      sigla: map['sigla'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      ativo: AdministracaoParsing.ativo(map['sin_ativo']),
      codigoSei: AdministracaoParsing.textoOpcional(map['codigo_sei']),
      publicacao: AdministracaoParsing.ativoOpcional(map['sin_publicacao']),
    );
  }

  final int idOrgao;
  final String sigla;
  final String descricao;
  final bool ativo;
  final String? codigoSei;
  final bool? publicacao;
}
