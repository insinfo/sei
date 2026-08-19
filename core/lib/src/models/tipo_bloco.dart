/// Tipo de bloco persistido em `bloco.sta_tipo`.
///
/// O domínio está totalmente comprovado no dump histórico local: das 113
/// linhas de `bloco`, 95 são `A`, 16 são `I` e 2 são `R` — cobertura de 100%,
/// sem código residual. O cruzamento com o conteúdo confirma o papel de cada
/// letra: nas 83 linhas de `rel_bloco_protocolo`, blocos `A` contêm
/// exclusivamente protocolos `G` (documento gerado no editor, 77
/// ocorrências), enquanto blocos `I` e `R` contêm exclusivamente protocolos
/// `P` (processo, 5 e 1 ocorrências, sem nenhum documento). Isso bate com as
/// três seções do manual do usuário — "Bloco de Assinatura", "Bloco de
/// reunião" e "Blocos Internos" —, cujas iniciais coincidem com os códigos e
/// cuja descrição funcional confirma o conteúdo observado: o Bloco de
/// Assinatura reúne documentos para assinatura, e os blocos de Reunião e
/// Interno reúnem processos. O levantamento completo está em
/// `backend/docs/evidencias_processo_detalhe.md`.
enum TipoBloco {
  /// Reúne documentos, sempre gerados no editor do SEI, para visualização e
  /// assinatura por usuários de outra unidade.
  assinatura('A'),

  /// Reúne processos para conhecimento de outra unidade, sem que eles
  /// tramitem para lá.
  reuniao('R'),

  /// Organiza processos dentro da própria unidade, sem disponibilização.
  interno('I');

  const TipoBloco(this.valor);

  /// Valor persistido em `bloco.sta_tipo`.
  final String valor;

  /// Converte o código do banco no tipo conhecido, com erro controlado.
  static TipoBloco fromValue(String valor) {
    final String normalizado = valor.trim();
    for (final TipoBloco tipo in values) {
      if (tipo.valor == normalizado) {
        return tipo;
      }
    }
    throw FormatException('O tipo de bloco é inválido: $valor.');
  }
}
