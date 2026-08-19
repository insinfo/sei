/// Estado persistido em `bloco.sta_estado`.
///
/// Comprovado no dump histórico local: das 113 linhas de `bloco`, `A`
/// aparece em 48 (30 blocos de Assinatura, 16 Internos e 2 de Reunião), `D`
/// em 64 (só Assinatura) e `C` em 1 (só Assinatura) — cobertura de 100% dos
/// dados observados, sem código residual.
///
/// O manual do usuário lista cinco rótulos na coluna Estado da tela Blocos —
/// "Podendo ser: Gerado, Disponibilizado, Recebido, Retornado e Concluído" —
/// mas o próprio manual mostra que **"Recebido" não é um código à parte**:
/// é o mesmo bloco disponibilizado (`D`), rotulado como "Recebido" quando
/// exibido para a unidade destinatária em vez da geradora ("os Blocos
/// recebidos de outras unidades são identificados pelo estado 'Recebido'").
/// `A` corresponde ao estado "Gerado": o manual descreve o bloco recém-criado
/// como "no estado 'Gerado', ou seja, ele foi criado, mas ainda não foi
/// disponibilizado para outra unidade" — e é exatamente o único código visto
/// nos blocos Interno e Reunião desta amostra, que nunca chegam a `D`/`C`
/// nela.
///
/// **"Retornado" fica de fora.** Nenhuma das 113 linhas do dump histórico
/// grava esse estado em `bloco.sta_estado`, e a única fonte de código
/// literal encontrada — `TramiteEmBlocoRN::$TE_RETORNADO = 'R'`, em
/// `mod-sei-pen/src/rn/TramiteEmBlocoRN.php` — descreve uma tabela distinta
/// (`md_pen_bloco`, usada pelo módulo PEN para trâmite em lote), não
/// `public.bloco`. A hipótese mais provável, registrada como lacuna em
/// `backend/docs/evidencias_processo_detalhe.md`, é que a devolução seja
/// tratada por `rel_bloco_unidade.sin_retornado` (sempre `N` nas 204 linhas
/// observadas), e não por um quarto código de `sta_estado`.
enum EstadoBloco {
  /// Bloco criado, ainda não disponibilizado para outra unidade.
  gerado('A'),

  /// Bloco disponibilizado para outra(s) unidade(s); a mesma linha aparece
  /// como "Recebido" na tela da unidade destinatária.
  disponibilizado('D'),

  /// Bloco concluído; some da listagem até ser reaberto.
  concluido('C');

  const EstadoBloco(this.valor);

  /// Valor persistido em `bloco.sta_estado`.
  final String valor;

  /// Converte o código do banco no estado conhecido, com erro controlado.
  static EstadoBloco fromValue(String valor) {
    final String normalizado = valor.trim();
    for (final EstadoBloco estado in values) {
      if (estado.valor == normalizado) {
        return estado;
      }
    }
    throw FormatException('O estado do bloco é inválido: $valor.');
  }
}
