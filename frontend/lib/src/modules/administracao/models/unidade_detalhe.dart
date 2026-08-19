import 'package:sei_frontend/src/modules/administracao/models/administracao_parsing.dart';

/// Detalhe somente leitura de uma unidade (`GET /unidades/:idUnidade`).
///
/// `codigoSei` e os indicadores de protocolo/arquivamento são opcionais
/// porque podem não estar projetados pelo backend nesta rodada; a tela
/// mostra o que vier.
class UnidadeDetalhe {
  UnidadeDetalhe({
    required this.idUnidade,
    required this.idOrgao,
    required this.sigla,
    required this.descricao,
    required this.ativo,
    this.codigoSei,
    this.protocolo,
    this.arquivamento,
  });

  factory UnidadeDetalhe.fromMap(Map<String, dynamic> map) {
    return UnidadeDetalhe(
      idUnidade: AdministracaoParsing.inteiroOpcional(map['id_unidade']) ?? 0,
      idOrgao: AdministracaoParsing.inteiroOpcional(map['id_orgao']) ?? 0,
      sigla: map['sigla'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      ativo: AdministracaoParsing.ativo(map['sin_ativo']),
      codigoSei: AdministracaoParsing.textoOpcional(map['codigo_sei']),
      protocolo: AdministracaoParsing.ativoOpcional(map['sin_protocolo']),
      arquivamento: AdministracaoParsing.ativoOpcional(map['sin_arquivamento']),
    );
  }

  final int idUnidade;
  final int idOrgao;
  final String sigla;
  final String descricao;
  final bool ativo;
  final String? codigoSei;
  final bool? protocolo;
  final bool? arquivamento;
}
