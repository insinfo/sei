/// Identificadores de tarefa da Base de Referência do Poder Executivo.
///
/// São os tipos de andamento em que o ciclo de vida do processo se apoia. Os
/// valores vêm da carga oficial de `public.tarefa` na base 5.0.0 e estão
/// registrados em `backend/docs/evidencias_processo_detalhe.md`. Cada
/// constante existe porque alguma regra do SEI depende dela, não para espelhar
/// o catálogo inteiro — o catálogo completo é lido por `TarefaCatalogo`.
enum TarefaSei {
  /// Autuação do processo na unidade geradora.
  processoGerado(1),

  /// Geração de documento interno, inclusive minuta.
  documentoGerado(2),

  /// Assinatura de documento; permitida com o processo já concluído.
  documentoAssinado(5),

  /// Registro de documento externo na árvore.
  documentoExternoRegistrado(13),

  /// Vínculo de processo relacionado, sem hierarquia e sem trâmite conjunto.
  processoRelacionadoAdicionado(18),

  /// Remoção do vínculo de processo relacionado.
  processoRelacionadoRemovido(19),

  /// Sobrestamento do processo na unidade.
  sobrestamento(20),

  /// Remoção do sobrestamento.
  sobrestamentoRemovido(21),

  /// Conclusão do processo na unidade, disparada pelo usuário.
  conclusaoProcessoNaUnidade(28),

  /// Reabertura do processo na unidade em que ele já tramitou.
  reaberturaProcessoNaUnidade(29),

  /// Remessa do processo para outra unidade.
  ///
  /// Esta tarefa não fecha andamentos abertos. Quem conclui na origem é
  /// [conclusaoAutomaticaNaUnidade], lançada apenas quando a opção de manter o
  /// processo aberto não é marcada.
  processoRemetidoPelaUnidade(32),

  /// Conclusão automática lançada pelo envio sem manter o processo aberto.
  conclusaoAutomaticaNaUnidade(41),

  /// Recebimento do processo na unidade de destino.
  processoRecebidoNaUnidade(48),

  /// Cancelamento de documento que já não pode ser excluído.
  documentoCancelado(51),

  /// Atribuição do processo a um usuário da unidade.
  processoAtribuido(57),

  /// Remoção da atribuição do processo.
  atribuicaoRemovida(59),

  /// Reordenação da árvore de documentos.
  arvoreReordenada(60),

  /// Ciência registrada no processo, que não pode ser cancelada.
  cienciaNoProcesso(82),

  /// Ciência registrada em documento do processo.
  cienciaNoDocumento(83),

  /// Anexação de outro processo a este.
  processoAnexado(101),

  /// Anexação deste processo a outro, que passa a ser o principal.
  anexadoAoProcesso(102),

  /// Desanexação executada por administrador do sistema.
  processoDesanexado(103),

  /// Bloqueio do processo durante o trâmite externo pelo Tramita.GOV.BR.
  processoBloqueado(122),

  /// Desbloqueio do processo após a conclusão do trâmite externo.
  processoDesbloqueado(123);

  const TarefaSei(this.id);

  /// Valor persistido em `atividade.id_tarefa` e `tarefa.id_tarefa`.
  final int id;

  /// Converte um identificador do banco na tarefa conhecida correspondente.
  ///
  /// Retorna `null` para tarefas fora deste conjunto, porque o catálogo tem
  /// mais de cem tipos e nem todos participam de regra de domínio.
  static TarefaSei? fromIdOrNull(int id) {
    for (final TarefaSei tarefa in values) {
      if (tarefa.id == id) {
        return tarefa;
      }
    }
    return null;
  }
}
