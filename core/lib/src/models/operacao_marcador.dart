/// Operação registrada em `andamento_marcador.sta_operacao`.
///
/// O domínio está totalmente comprovado no dump histórico local: das 227
/// linhas observadas, 202 são `I`, 24 são `R` e 1 é `A`, exatamente as três
/// operações descritas no manual do usuário para o Histórico de Marcadores —
/// "Operação (inclusão, alteração ou remoção)".
enum OperacaoMarcador {
  /// Marcador atribuído ao processo.
  inclusao('I'),

  /// Texto complementar do marcador alterado.
  alteracao('A'),

  /// Marcador retirado do processo.
  remocao('R');

  const OperacaoMarcador(this.valor);

  /// Valor persistido em `andamento_marcador.sta_operacao`.
  final String valor;

  /// Converte o código do banco na operação conhecida, com erro controlado.
  static OperacaoMarcador fromValue(String valor) {
    final String normalizado = valor.trim();
    for (final OperacaoMarcador operacao in values) {
      if (operacao.valor == normalizado) {
        return operacao;
      }
    }
    throw FormatException(
      'A operação de marcador é inválida: $valor.',
    );
  }
}
