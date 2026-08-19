import 'package:sei_backend/sei_backend.dart';

/// Cenário mínimo de processo usado nos testes de leitura por unidade.
///
/// A Base de Referência oficial não possui atividades operacionais, e criar
/// dados sintéticos nela é proibido. Esta fixture existe para ser inserida
/// dentro de uma transação sempre revertida, de modo que as consultas sejam
/// exercitadas contra linhas reais sem que nada seja confirmado no banco.
///
/// O cenário reproduz o comportamento central do SEI: o mesmo processo aberto
/// em duas unidades ao mesmo tempo, uma terceira unidade que já concluiu, um
/// processo relacionado e participantes em papéis distintos. Todos os mapas de
/// escrita vêm de `toInsertMap()` das entidades do `core`.
class FixtureProcessoSei {
  const FixtureProcessoSei._();

  /// Processo principal do cenário.
  static const int idProcessoPrincipal = 900000001;

  /// Processo vinculado ao principal por relacionamento.
  static const int idProcessoRelacionado = 900000002;

  /// Unidade que autuou o processo e o mantém aberto.
  static const int idUnidadeGeradora = 110000001;

  /// Unidade que recebeu o processo e também o mantém aberto.
  static const int idUnidadeRecebedora = 110000002;

  /// Unidade que já concluiu o processo e não deve aparecer como aberta.
  static const int idUnidadeConcluida = 110000003;

  /// Usuário de referência presente na base restaurada.
  static const int idUsuario = 100000001;

  /// Tipo de processo presente na Base de Referência.
  static const int idTipoProcedimento = 100000101;

  /// Documento interno, com corpo em `documento_conteudo`.
  static const int idDocumentoInterno = 900000003;

  /// Documento externo, com ponteiro de arquivo em `anexo`.
  static const int idDocumentoExterno = 900000004;

  /// Série presente na Base de Referência ("Resolução"), reaproveitada sem
  /// inserção sintética.
  static const int _idSerie = 1;

  static const int _idAtividadeGeradora = 900000001;
  static const int _idAtividadeRecebedora = 900000002;
  static const int _idAtividadeConcluida = 900000003;
  static const int _idRelacao = 900000001;
  static const int _idParticipanteInteressado = 900000001;
  static const int _idParticipanteDestinatario = 900000002;
  static const int _idAnotacao = 900000001;
  static const int _idMarcador = 900000001;
  static const int _idAndamentoMarcador = 900000001;
  static const int _idGrupoAcompanhamento = 900000001;
  static const int _idAcompanhamento = 900000001;
  static const int _idControlePrazo = 900000001;
  static const int _idRetornoProgramado = 900000001;

  static final DateTime _autuacao = DateTime(2026, 8, 3, 9);
  static final DateTime _recebimento = DateTime(2026, 8, 4, 14, 30);
  static final DateTime _conclusao = DateTime(2026, 8, 5, 11, 15);

  /// Insere o cenário completo na conexão da transação informada.
  static Future<void> inserir(Connection conexao) async {
    final int idContato = await _primeiroContato(conexao);

    await _inserirProcesso(
      conexao,
      idProcesso: idProcessoPrincipal,
      protocoloFormatado: '90000.900001/2026-11',
      descricao: 'Processo de fixture aberto em duas unidades',
    );
    await _inserirProcesso(
      conexao,
      idProcesso: idProcessoRelacionado,
      protocoloFormatado: '90000.900002/2026-12',
      descricao: 'Processo de fixture relacionado ao principal',
    );

    await _inserirAtividades(conexao);
    await _inserirRelacionamento(conexao);
    await _inserirParticipantes(conexao, idContato);
    await _inserirAnotacao(conexao);
    await _inserirMarcador(conexao);
    await _inserirAcompanhamento(conexao);
    await _inserirControlePrazo(conexao);
    await _inserirRetornoProgramado(conexao);
    await _inserirDocumentoInterno(conexao);
    await _inserirDocumentoExterno(conexao);
  }

  static Future<void> _inserirProcesso(
    Connection conexao, {
    required int idProcesso,
    required String protocoloFormatado,
    required String descricao,
  }) async {
    final Protocolo protocolo = Protocolo(
      idProtocolo: idProcesso,
      idUnidadeGeradora: idUnidadeGeradora,
      idUsuarioGerador: idUsuario,
      protocoloFormatado: protocoloFormatado,
      tipoProtocolo: TipoProtocolo.processo,
      dataGeracao: _autuacao,
      dataInclusao: _autuacao,
      descricao: descricao,
    );
    final Procedimento procedimento = Procedimento(
      idProcedimento: idProcesso,
      idTipoProcedimento: idTipoProcedimento,
    );

    await conexao.table(Protocolo.fqtn).insert(protocolo.toInsertMap());
    await conexao.table(Procedimento.fqtn).insert(procedimento.toInsertMap());
  }

  static Future<void> _inserirAtividades(Connection conexao) async {
    final List<Atividade> atividades = <Atividade>[
      // Autuação: a unidade geradora fica aberta e com o processo atribuído.
      Atividade(
        idAtividade: _idAtividadeGeradora,
        idProtocolo: idProcessoPrincipal,
        idUnidade: idUnidadeGeradora,
        idUnidadeOrigem: idUnidadeGeradora,
        idUsuarioOrigem: idUsuario,
        idUsuario: idUsuario,
        idUsuarioAtribuicao: idUsuario,
        idTarefa: TarefaSei.processoGerado.id,
        dataAbertura: _autuacao,
        inicial: true,
      ),
      // Envio mantendo aberto na origem: a unidade de destino também abre.
      Atividade(
        idAtividade: _idAtividadeRecebedora,
        idProtocolo: idProcessoPrincipal,
        idUnidade: idUnidadeRecebedora,
        idUnidadeOrigem: idUnidadeGeradora,
        idUsuarioOrigem: idUsuario,
        idUsuario: idUsuario,
        idTarefa: TarefaSei.processoRecebidoNaUnidade.id,
        dataAbertura: _recebimento,
        inicial: false,
      ),
      // Terceira unidade que já concluiu: não pode figurar como aberta.
      Atividade(
        idAtividade: _idAtividadeConcluida,
        idProtocolo: idProcessoPrincipal,
        idUnidade: idUnidadeConcluida,
        idUnidadeOrigem: idUnidadeGeradora,
        idUsuarioOrigem: idUsuario,
        idUsuario: idUsuario,
        idUsuarioConclusao: idUsuario,
        idTarefa: TarefaSei.conclusaoProcessoNaUnidade.id,
        dataAbertura: _recebimento,
        dataConclusao: _conclusao,
        inicial: false,
      ),
    ];

    for (final Atividade atividade in atividades) {
      await conexao.table(Atividade.fqtn).insert(atividade.toInsertMap());
    }
  }

  static Future<void> _inserirRelacionamento(Connection conexao) async {
    final RelacaoProtocolo relacao = RelacaoProtocolo.comAssociacao(
      idRelacao: _idRelacao,
      idProtocolo1: idProcessoPrincipal,
      idProtocolo2: idProcessoRelacionado,
      idUsuario: idUsuario,
      idUnidade: idUnidadeGeradora,
      associacao: AssociacaoProtocolo.processoRelacionado,
      dataAssociacao: _recebimento,
    );

    await conexao.table(RelacaoProtocolo.fqtn).insert(relacao.toInsertMap());
  }

  static Future<void> _inserirParticipantes(
    Connection conexao,
    int idContato,
  ) async {
    final List<Participante> participantes = <Participante>[
      Participante.comPapel(
        idParticipante: _idParticipanteInteressado,
        idProtocolo: idProcessoPrincipal,
        idContato: idContato,
        idUnidade: idUnidadeGeradora,
        participacao: ProcessoParticipacao.interessado,
      ),
      Participante.comPapel(
        idParticipante: _idParticipanteDestinatario,
        idProtocolo: idProcessoPrincipal,
        idContato: idContato,
        idUnidade: idUnidadeGeradora,
        participacao: ProcessoParticipacao.destinatario,
        sequencia: 1,
      ),
    ];

    for (final Participante participante in participantes) {
      await conexao.table(Participante.fqtn).insert(participante.toInsertMap());
    }
  }

  static Future<void> _inserirAnotacao(Connection conexao) async {
    final Anotacao anotacao = Anotacao(
      idAnotacao: _idAnotacao,
      idUnidade: idUnidadeGeradora,
      idProtocolo: idProcessoPrincipal,
      idUsuario: idUsuario,
      dataAnotacao: _recebimento,
      // Único valor de `sta_anotacao` comprovado no corpus local; ver
      // `backend/docs/evidencias_processo_detalhe.md`.
      situacao: 'U',
      descricao: 'Anotação de fixture, exclusiva da unidade geradora',
    );

    await conexao.table(Anotacao.fqtn).insert(anotacao.toInsertMap());
  }

  static Future<void> _inserirMarcador(Connection conexao) async {
    final Marcador marcador = Marcador(
      idMarcador: _idMarcador,
      idUnidade: idUnidadeGeradora,
      nome: 'Fixture',
      icone: '4',
    );
    final AndamentoMarcador andamento = AndamentoMarcador(
      idAndamentoMarcador: _idAndamentoMarcador,
      idMarcador: _idMarcador,
      idUnidade: idUnidadeGeradora,
      idUsuario: idUsuario,
      idProcedimento: idProcessoPrincipal,
      dataExecucao: _recebimento,
      operacao: OperacaoMarcador.inclusao,
    );

    await conexao.table(Marcador.fqtn).insert(marcador.toInsertMap());
    await conexao.table(AndamentoMarcador.fqtn).insert(andamento.toInsertMap());
  }

  /// Acompanhamento na unidade que já concluiu o processo.
  ///
  /// Prova o comportamento central do recurso: diferente do Bloco Interno, o
  /// Acompanhamento Especial não exige que o processo esteja aberto na
  /// unidade que acompanha.
  static Future<void> _inserirAcompanhamento(Connection conexao) async {
    final GrupoAcompanhamento grupo = GrupoAcompanhamento(
      idGrupoAcompanhamento: _idGrupoAcompanhamento,
      idUnidade: idUnidadeConcluida,
      nome: 'Fixture',
    );
    final Acompanhamento acompanhamento = Acompanhamento(
      idAcompanhamento: _idAcompanhamento,
      idUnidade: idUnidadeConcluida,
      idGrupoAcompanhamento: _idGrupoAcompanhamento,
      idProtocolo: idProcessoPrincipal,
      idUsuario: idUsuario,
      dataAlteracao: _conclusao,
      observacao: 'Acompanhamento de fixture após a conclusão',
    );

    await conexao.table(GrupoAcompanhamento.fqtn).insert(grupo.toInsertMap());
    await conexao
        .table(Acompanhamento.fqtn)
        .insert(acompanhamento.toInsertMap());
  }

  static Future<void> _inserirControlePrazo(Connection conexao) async {
    final ControlePrazo controlePrazo = ControlePrazo(
      idControlePrazo: _idControlePrazo,
      idProtocolo: idProcessoPrincipal,
      idUnidade: idUnidadeGeradora,
      idUsuario: idUsuario,
      dataPrazo: _conclusao,
    );

    await conexao.table(ControlePrazo.fqtn).insert(controlePrazo.toInsertMap());
  }

  /// Retorno programado ainda não cumprido, sem atividade de retorno.
  static Future<void> _inserirRetornoProgramado(Connection conexao) async {
    final RetornoProgramado retorno = RetornoProgramado(
      idRetornoProgramado: _idRetornoProgramado,
      idAtividadeEnvio: _idAtividadeGeradora,
      idUsuario: idUsuario,
      dataProgramada: _conclusao,
      idUnidadeEnvio: idUnidadeGeradora,
      idUnidadeRetorno: idUnidadeRecebedora,
      idProtocolo: idProcessoPrincipal,
    );

    await conexao.table(RetornoProgramado.fqtn).insert(retorno.toInsertMap());
  }

  static Future<void> _inserirDocumentoInterno(Connection conexao) async {
    final Protocolo protocolo = Protocolo(
      idProtocolo: idDocumentoInterno,
      idUnidadeGeradora: idUnidadeGeradora,
      idUsuarioGerador: idUsuario,
      protocoloFormatado: '90000.900003/2026-13',
      tipoProtocolo: TipoProtocolo.documentoGerado,
      dataGeracao: _recebimento,
      dataInclusao: _recebimento,
      descricao: 'Despacho de fixture',
    );
    final Documento documento = Documento(
      idDocumento: idDocumentoInterno,
      idUnidadeResponsavel: idUnidadeGeradora,
      idSerie: _idSerie,
      idProcedimento: idProcessoPrincipal,
      estado: EstadoDocumento.interno,
      // Comprovado no dump histórico: todo documento interno traz este
      // código de editor.
      editor: '2',
      nomeArvore: 'Despacho de fixture',
      // Comprovado no dump histórico: todo documento interno tem versões.
      versoes: true,
    );
    final DocumentoConteudo conteudo = DocumentoConteudo(
      idDocumento: idDocumentoInterno,
      conteudo: '<p>Conteúdo de fixture, exclusivo do teste.</p>',
    );

    await conexao.table(Protocolo.fqtn).insert(protocolo.toInsertMap());
    await conexao.table(Documento.fqtn).insert(documento.toInsertMap());
    await conexao.table(DocumentoConteudo.fqtn).insert(conteudo.toInsertMap());
  }

  static Future<void> _inserirDocumentoExterno(Connection conexao) async {
    final Protocolo protocolo = Protocolo(
      idProtocolo: idDocumentoExterno,
      idUnidadeGeradora: idUnidadeGeradora,
      idUsuarioGerador: idUsuario,
      protocoloFormatado: '90000.900004/2026-14',
      tipoProtocolo: TipoProtocolo.documentoRecebido,
      dataGeracao: _recebimento,
      dataInclusao: _recebimento,
      descricao: 'Ofício externo de fixture',
    );
    final Documento documento = Documento(
      idDocumento: idDocumentoExterno,
      idUnidadeResponsavel: idUnidadeGeradora,
      idSerie: _idSerie,
      idProcedimento: idProcessoPrincipal,
      estado: EstadoDocumento.externo,
      // Comprovado no dump histórico: todo documento externo traz este
      // código de editor.
      editor: '0',
      nomeArvore: 'Ofício externo de fixture',
      // Comprovado no dump histórico: nenhum documento externo tem versões.
      versoes: false,
    );
    final Anexo anexo = Anexo(
      idAnexo: 900000001,
      idProtocolo: idDocumentoExterno,
      idUnidade: idUnidadeGeradora,
      idUsuario: idUsuario,
      nome: 'oficio_fixture.pdf',
      tamanho: 12345,
      dataInclusao: _recebimento,
      // Placeholder de 32 caracteres; o algoritmo real não está comprovado
      // pelas fontes locais (ver evidencias_processo_detalhe.md).
      hash: 'a' * 32,
    );

    await conexao.table(Protocolo.fqtn).insert(protocolo.toInsertMap());
    await conexao.table(Documento.fqtn).insert(documento.toInsertMap());
    await conexao.table(Anexo.fqtn).insert(anexo.toInsertMap());
  }

  /// Reaproveita um contato já existente na Base de Referência.
  ///
  /// Evita inserir contato sintético e mantém a fixture presa a dados reais.
  static Future<int> _primeiroContato(Connection conexao) async {
    final Map<String, dynamic>? linha = await conexao
        .table(ProcessoParticipante.contatoFqtn)
        .select(const <String>[ProcessoParticipante.contatoIdSourceCol])
        .orderBy(ProcessoParticipante.contatoIdSourceCol, 'asc')
        .first();
    if (linha == null) {
      throw StateError(
        'A Base de Referência restaurada não possui contato para a fixture.',
      );
    }
    return SeiCoreUtils.inteiro(
      linha[ProcessoParticipante.contatoIdSourceCol],
      nomeCampo: ProcessoParticipante.contatoIdSourceCol,
    );
  }
}
