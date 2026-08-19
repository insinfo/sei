import 'package:sei_frontend/src/modules/administracao/models/administracao_parsing.dart';

/// Item de órgão exibido na listagem de administração (`GET /orgaos`).
///
/// Campos obrigatórios espelham `public.orgao`
/// (`backend/referencias/backup_sei_bd/sei_5_0_0_BD_Ref_Exec.sql`):
/// `id_orgao`, `sigla`, `descricao`.
class OrgaoListItem {
  OrgaoListItem({
    required this.idOrgao,
    required this.sigla,
    required this.descricao,
    required this.ativo,
  });

  factory OrgaoListItem.fromMap(Map<String, dynamic> map) {
    return OrgaoListItem(
      idOrgao: AdministracaoParsing.inteiroOpcional(map['id_orgao']) ?? 0,
      sigla: map['sigla'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      ativo: AdministracaoParsing.ativo(map['sin_ativo']),
    );
  }

  final int idOrgao;
  final String sigla;
  final String descricao;
  final bool ativo;
}
