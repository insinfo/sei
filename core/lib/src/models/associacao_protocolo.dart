/// Tipos de associação registrados em `rel_protocolo_protocolo`.
///
/// O SEI usa a mesma tabela para ligar processo a documento, processo a
/// processo relacionado e processo a processo anexado. O corpus local prova
/// apenas dois códigos, e por isso apenas eles são declarados aqui:
///
/// - `1` liga sempre processo a documento nas 842 associações do dump
///   histórico e é o valor já usado pela árvore de documentos;
/// - `3` liga sempre processo a processo, sem linha recíproca, e os dois
///   protocolos permanecem em `sta_estado` normal, o que caracteriza
///   relacionamento e não anexação, já que o processo anexado perde a
///   independência e muda de estado.
///
/// Documento movido e processo anexado possuem códigos próprios que o corpus
/// local não permite fixar; enquanto não houver prova, eles não entram aqui.
/// O levantamento está em `backend/docs/evidencias_processo_detalhe.md`.
enum AssociacaoProtocolo {
  /// Documento que compõe a árvore do processo.
  documentoNoProcesso('1'),

  /// Processo relacionado por afinidade temática, sem hierarquia nem trâmite
  /// conjunto.
  processoRelacionado('3');

  const AssociacaoProtocolo(this.valor);

  /// Valor persistido em `rel_protocolo_protocolo.sta_associacao`.
  final String valor;

  /// Converte o código do banco em associação conhecida, quando houver.
  static AssociacaoProtocolo? fromValueOrNull(String valor) {
    final String normalizado = valor.trim();
    for (final AssociacaoProtocolo associacao in values) {
      if (associacao.valor == normalizado) {
        return associacao;
      }
    }
    return null;
  }
}
