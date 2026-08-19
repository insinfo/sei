/// Natureza do protocolo persistida em `protocolo.sta_protocolo`.
///
/// O SEI usa a mesma tabela `protocolo` para processos e documentos; é esta
/// coluna que separa os dois. Os três valores estão comprovados no dump
/// histórico local: `P` aparece nas 639 linhas que também existem em
/// `procedimento`, enquanto `G` e `R` aparecem somente nas linhas que existem
/// em `documento`. O levantamento está em
/// `backend/docs/evidencias_processo_detalhe.md`.
enum TipoProtocolo {
  /// Processo administrativo, com linha correspondente em `procedimento`.
  processo('P'),

  /// Documento produzido no editor do SEI.
  documentoGerado('G'),

  /// Documento externo registrado na árvore do processo.
  documentoRecebido('R');

  const TipoProtocolo(this.valor);

  /// Valor persistido em `protocolo.sta_protocolo`.
  final String valor;

  /// Indica que o protocolo é um documento, gerado ou recebido.
  bool get ehDocumento => this != processo;

  /// Converte o código do banco em natureza conhecida, com erro controlado.
  static TipoProtocolo fromValue(String valor) {
    final String normalizado = valor.trim();
    for (final TipoProtocolo tipo in values) {
      if (tipo.valor == normalizado) {
        return tipo;
      }
    }
    throw FormatException('O tipo de protocolo é inválido: $valor.');
  }
}
