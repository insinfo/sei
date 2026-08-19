import 'package:sei_frontend/src/modules/administracao/models/administracao_parsing.dart';

/// Item de unidade exibido na listagem de administração (`GET /unidades`).
///
/// Campos obrigatórios espelham `public.unidade`
/// (`backend/referencias/backup_sei_bd/sei_5_0_0_BD_Ref_Exec.sql`):
/// `id_unidade`, `id_orgao`, `sigla`, `descricao`.
class UnidadeListItem {
  UnidadeListItem({
    required this.idUnidade,
    required this.idOrgao,
    required this.sigla,
    required this.descricao,
    required this.ativo,
  });

  factory UnidadeListItem.fromMap(Map<String, dynamic> map) {
    return UnidadeListItem(
      idUnidade: AdministracaoParsing.inteiroOpcional(map['id_unidade']) ?? 0,
      idOrgao: AdministracaoParsing.inteiroOpcional(map['id_orgao']) ?? 0,
      sigla: map['sigla'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      ativo: AdministracaoParsing.ativo(map['sin_ativo']),
    );
  }

  final int idUnidade;
  final int idOrgao;
  final String sigla;
  final String descricao;
  final bool ativo;
}
