import 'package:sei_frontend/src/modules/administracao/models/administracao_parsing.dart';

/// Item de usuário exibido na listagem de administração.
///
/// Reflete o contrato combinado com o backend para `GET /usuarios`: os
/// campos obrigatórios (`id_usuario`, `id_orgao`, `sigla`, `nome`) vêm
/// diretamente das colunas de `public.usuario`
/// (`backend/referencias/backup_sei_bd/sei_5_0_0_BD_Ref_Exec.sql`); os
/// demais são lidos de forma tolerante para não quebrar a listagem caso a
/// API ainda não os inclua nesta rodada.
class UsuarioListItem {
  UsuarioListItem({
    required this.idUsuario,
    required this.idOrgao,
    required this.sigla,
    required this.nome,
    required this.ativo,
  });

  factory UsuarioListItem.fromMap(Map<String, dynamic> map) {
    return UsuarioListItem(
      idUsuario: AdministracaoParsing.inteiroOpcional(map['id_usuario']) ?? 0,
      idOrgao: AdministracaoParsing.inteiroOpcional(map['id_orgao']) ?? 0,
      sigla: map['sigla'] as String? ?? '',
      nome: map['nome'] as String? ?? '',
      ativo: AdministracaoParsing.ativo(map['sin_ativo']),
    );
  }

  final int idUsuario;
  final int idOrgao;
  final String sigla;
  final String nome;
  final bool ativo;
}
