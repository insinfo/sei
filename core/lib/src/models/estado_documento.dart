/// Natureza do documento persistida em `documento.sta_documento`.
///
/// O cruzamento no dump histórico local é exato para os dois códigos
/// principais: `I` corresponde sempre a `protocolo.sta_protocolo = 'G'`
/// (documento gerado no editor, com `sta_editor = '2'` e `sin_versoes = 'S'`
/// nas 535 ocorrências), e `X` corresponde sempre a
/// `protocolo.sta_protocolo = 'R'` (documento externo, com `sta_editor = '0'`
/// e `sin_versoes = 'N'` nas 306 ocorrências).
///
/// Existe um terceiro código, `A`, com uma única ocorrência nos dados reais —
/// um documento do tipo `G` com `sta_editor = '0'`, `sin_versoes = 'N'` e
/// bloqueado. Uma única linha não é evidência suficiente para atribuir
/// significado com segurança, e por isso o código não é declarado aqui; a
/// lacuna está registrada em `backend/docs/evidencias_processo_detalhe.md`.
enum EstadoDocumento {
  /// Documento interno, produzido no editor do SEI.
  interno('I'),

  /// Documento externo, registrado por upload ou digitalização.
  externo('X');

  const EstadoDocumento(this.valor);

  /// Valor persistido em `documento.sta_documento`.
  final String valor;

  /// Converte o código do banco em estado conhecido, quando houver.
  static EstadoDocumento? fromValueOrNull(String valor) {
    final String normalizado = valor.trim();
    for (final EstadoDocumento estado in values) {
      if (estado.valor == normalizado) {
        return estado;
      }
    }
    return null;
  }
}
