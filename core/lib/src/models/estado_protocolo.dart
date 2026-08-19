/// Estado do protocolo persistido em `protocolo.sta_estado`.
///
/// Este estado não é o par aberto e concluído, que pertence à atividade de
/// cada unidade. Ele registra situações que travam ou anulam o protocolo
/// inteiro, como o bloqueio durante o trâmite externo e o cancelamento de
/// documento.
///
/// Os valores declarados aqui estão comprovados no corpus local: `0` aparece
/// em todos os 1.472 protocolos normais do dump histórico, `2` aparece apenas
/// em documentos, e `4` e `5` são literais do módulo PEN em
/// `ExpedirProcedimentoRN.php`. O código do processo anexado existe no SEI mas
/// não pôde ser fixado com as fontes locais e por isso não entra aqui.
enum EstadoProtocolo {
  /// Situação corrente, sem bloqueio nem cancelamento.
  normal('0'),

  /// Documento cancelado: permanece na árvore, sem conteúdo acessível.
  documentoCancelado('2'),

  /// Processo bloqueado durante o trâmite externo pelo Tramita.GOV.BR;
  /// somente leitura até o destinatário confirmar o recebimento.
  procedimentoBloqueado('4'),

  /// Envio externo em andamento.
  emProcessamento('5');

  const EstadoProtocolo(this.valor);

  /// Valor persistido em `protocolo.sta_estado`.
  final String valor;

  /// Indica que o protocolo não aceita alteração enquanto estiver neste
  /// estado.
  bool get bloqueiaAlteracao => this != normal;

  /// Converte o código do banco em estado conhecido, quando houver.
  static EstadoProtocolo? fromValueOrNull(String valor) {
    final String normalizado = valor.trim();
    for (final EstadoProtocolo estado in values) {
      if (estado.valor == normalizado) {
        return estado;
      }
    }
    return null;
  }
}
