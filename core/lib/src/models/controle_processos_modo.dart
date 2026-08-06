/// Aba do Controle de Processos, definida pelo estado inicial da atividade.
enum ControleProcessosModo {
  recebidos('recebidos', 'N'),
  gerados('gerados', 'S');

  const ControleProcessosModo(this.valor, this.valorAtividadeInicial);

  /// Valor estável exposto pela API e usado na rota de consulta.
  final String valor;

  /// Valor persistido pelo SEI em `atividade.sin_inicial`.
  final String valorAtividadeInicial;

  /// Converte o valor de transporte em modo conhecido, com erro controlado.
  static ControleProcessosModo fromValue(String valor) {
    for (final ControleProcessosModo modo in values) {
      if (modo.valor == valor) {
        return modo;
      }
    }
    throw FormatException(
        'O modo de controle de processos é inválido: $valor.');
  }
}
