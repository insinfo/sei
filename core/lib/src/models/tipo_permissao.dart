/// Regra de repasse de uma concessão do SIP, persistida em
/// `permissao.id_tipo_permissao` e catalogada em `tipo_permissao`.
///
/// Catálogo pequeno, fechado e totalmente comprovado: `tipo_permissao` tem
/// exatamente 3 linhas na Base de Referência (`SELECT * FROM tipo_permissao`
/// devolve só os identificadores 1, 2 e 3, cada um com a própria
/// `descricao` no banco), sem código residual. Diferente dos códigos de uma
/// letra registrados em `backend/docs/evidencias_processo_detalhe.md`, aqui
/// o próprio banco documenta o significado de cada valor, o que permite
/// declarar o enum com segurança total.
enum TipoPermissao {
  /// A concessão não pode ser repassada pelo usuário a outro perfil.
  naoDelegavel(1),

  /// A concessão pode ser repassada livremente.
  delegavel(2),

  /// A concessão pode ser repassada uma única vez.
  delegavelUmaVez(3);

  const TipoPermissao(this.id);

  /// Valor persistido em `permissao.id_tipo_permissao` e
  /// `tipo_permissao.id_tipo_permissao`.
  final int id;

  /// Converte o identificador do banco no tipo conhecido, com erro controlado.
  static TipoPermissao fromId(int id) {
    for (final TipoPermissao tipo in values) {
      if (tipo.id == id) {
        return tipo;
      }
    }
    throw FormatException('O tipo de permissão é inválido: $id.');
  }
}
