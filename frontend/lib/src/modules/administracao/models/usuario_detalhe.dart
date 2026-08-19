import 'package:sei_frontend/src/modules/administracao/models/administracao_parsing.dart';

/// Detalhe somente leitura de um usuário (`GET /usuarios/:idUsuario`).
///
/// A API nunca inclui a senha nesta resposta. Campos além dos obrigatórios
/// (`nomeRegistroCivil`, `nomeSocial`) são opcionais porque representam
/// colunas de `public.usuario` que podem ainda não estar projetadas pelo
/// backend nesta rodada — a tela mostra o que vier e omite o restante.
class UsuarioDetalhe {
  UsuarioDetalhe({
    required this.idUsuario,
    required this.idOrgao,
    required this.sigla,
    required this.nome,
    required this.ativo,
    this.nomeRegistroCivil,
    this.nomeSocial,
  });

  factory UsuarioDetalhe.fromMap(Map<String, dynamic> map) {
    return UsuarioDetalhe(
      idUsuario: AdministracaoParsing.inteiroOpcional(map['id_usuario']) ?? 0,
      idOrgao: AdministracaoParsing.inteiroOpcional(map['id_orgao']) ?? 0,
      sigla: map['sigla'] as String? ?? '',
      nome: map['nome'] as String? ?? '',
      ativo: AdministracaoParsing.ativo(map['sin_ativo']),
      nomeRegistroCivil:
          AdministracaoParsing.textoOpcional(map['nome_registro_civil']),
      nomeSocial: AdministracaoParsing.textoOpcional(map['nome_social']),
    );
  }

  final int idUsuario;
  final int idOrgao;
  final String sigla;
  final String nome;
  final bool ativo;
  final String? nomeRegistroCivil;
  final String? nomeSocial;
}
