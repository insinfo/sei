/// Identidade resolvida do JWT de sessão, injetada no contêiner da
/// requisição por `AuthMiddleware`.
///
/// Não pertence ao `core` porque é um dado interno do backend (derivado do
/// token), sem uso como modelo de domínio ou DTO de transporte.
class UsuarioAutenticado {
  const UsuarioAutenticado({
    required this.idUsuario,
    required this.idOrgao,
    required this.sigla,
    required this.nome,
  });

  final int idUsuario;
  final int idOrgao;
  final String sigla;
  final String nome;
}
