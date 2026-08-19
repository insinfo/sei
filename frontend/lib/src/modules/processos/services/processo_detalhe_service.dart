import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sei_core/sei_core.dart';

/// Falha de comunicação ou de contrato na consulta de detalhe de processo.
class ProcessoDetalheApiException implements Exception {
  ProcessoDetalheApiException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Cliente HTTP somente leitura para as projeções do detalhe de processo.
///
/// Os identificadores permanecem como texto para evitar perda de precisão no
/// navegador. A conversão do JSON ocorre nesta borda, antes de os dados
/// chegarem aos componentes.
class ProcessoDetalheService {
  ProcessoDetalheService({http.Client? cliente, Uri? baseUri})
      : _cliente = cliente ?? http.Client(),
        _baseUri = baseUri ?? Uri.parse('http://localhost:3350/api/v1');

  static const String _processosPath = 'processos';
  static const String _cabecalhoPath = 'cabecalho';
  static const String _documentosPath = 'documentos';
  static const String _andamentosPath = 'andamentos';
  static const String _unidadesAbertasPath = 'unidades-abertas';
  static const String _relacionadosPath = 'relacionados';
  static const String _participantesPath = 'participantes';
  static const String _anotacoesPath = 'anotacoes';
  static const String _marcadoresPath = 'marcadores';
  static const String _acompanhamentosPath = 'acompanhamentos';
  static const String _controlesPrazoPath = 'controles-prazo';
  static const String _retornosProgramadosPath = 'retornos-programados';
  static const String _blocosPath = 'blocos';
  static const String _basesConhecimentoPath = 'bases-conhecimento';
  static const String _conteudoPath = 'conteudo';
  static const String _idUnidadeParametro = 'idUnidade';

  final http.Client _cliente;
  final Uri _baseUri;

  /// Busca os dados resumidos que formam o cabeçalho de um processo.
  Future<ProcessoCabecalho> obterCabecalho(String idProcesso) {
    return _buscarObjeto(
      idProcesso: idProcesso,
      recurso: _cabecalhoPath,
      converter: ProcessoCabecalho.fromMap,
    );
  }

  /// Busca uma página da árvore de documentos do processo.
  Future<PaginaProcessoArvoreDocumentos> listarDocumentos(
    String idProcesso, {
    String? cursor,
    int limite = ProcessoDetalhePaginacao.limitePadrao,
  }) {
    return _buscarObjeto(
      idProcesso: idProcesso,
      recurso: _documentosPath,
      parametros: _parametrosPaginacao(cursor: cursor, limite: limite),
      converter: PaginaProcessoArvoreDocumentos.fromMap,
    );
  }

  /// Busca uma página cronológica de andamentos do processo.
  Future<PaginaProcessoAndamentos> listarAndamentos(
    String idProcesso, {
    String? cursor,
    int limite = ProcessoDetalhePaginacao.limitePadrao,
  }) {
    return _buscarObjeto(
      idProcesso: idProcesso,
      recurso: _andamentosPath,
      parametros: _parametrosPaginacao(cursor: cursor, limite: limite),
      converter: PaginaProcessoAndamentos.fromMap,
    );
  }

  /// Lista as unidades em que o processo está aberto no momento.
  ///
  /// O estado aberto/concluído do SEI é por par processo-unidade, não do
  /// processo inteiro: por isso o retorno é uma lista, não um booleano único.
  Future<List<ProcessoUnidadeAberta>> listarUnidadesAbertas(
    String idProcesso,
  ) {
    return _buscarLista(
      idProcesso: idProcesso,
      recurso: _unidadesAbertasPath,
      converter: ProcessoUnidadeAberta.fromMap,
    );
  }

  /// Lista os processos relacionados ao processo consultado, nos dois
  /// sentidos do vínculo.
  Future<List<ProcessoRelacionado>> listarRelacionados(String idProcesso) {
    return _buscarLista(
      idProcesso: idProcesso,
      recurso: _relacionadosPath,
      converter: ProcessoRelacionado.fromMap,
    );
  }

  /// Lista os interessados, remetentes e destinatários vinculados ao
  /// processo.
  Future<List<ProcessoParticipante>> listarParticipantes(String idProcesso) {
    return _buscarLista(
      idProcesso: idProcesso,
      recurso: _participantesPath,
      converter: ProcessoParticipante.fromMap,
    );
  }

  /// Lista as anotações do processo visíveis para a unidade informada.
  ///
  /// A visibilidade da anotação é exclusiva da unidade que a criou, por isso
  /// [idUnidade] é obrigatório.
  Future<List<ProcessoAnotacao>> listarAnotacoes(
    String idProcesso,
    int idUnidade,
  ) {
    return _buscarLista(
      idProcesso: idProcesso,
      recurso: _anotacoesPath,
      parametros: <String, String>{_idUnidadeParametro: idUnidade.toString()},
      converter: ProcessoAnotacao.fromMap,
    );
  }

  /// Lista os marcadores vigentes atribuídos ao processo.
  Future<List<ProcessoMarcador>> listarMarcadores(String idProcesso) {
    return _buscarLista(
      idProcesso: idProcesso,
      recurso: _marcadoresPath,
      converter: ProcessoMarcador.fromMap,
    );
  }

  /// Lista os acompanhamentos especiais registrados para o processo.
  Future<List<ProcessoAcompanhamento>> listarAcompanhamentos(
    String idProcesso,
  ) {
    return _buscarLista(
      idProcesso: idProcesso,
      recurso: _acompanhamentosPath,
      converter: ProcessoAcompanhamento.fromMap,
    );
  }

  /// Lista os prazos internos de controle da unidade informada sobre o
  /// processo.
  ///
  /// É um recurso de organização interna: [idUnidade] é obrigatório porque
  /// outras unidades não têm acesso aos prazos que não criaram.
  Future<List<ProcessoControlePrazo>> listarControlesPrazo(
    String idProcesso,
    int idUnidade,
  ) {
    return _buscarLista(
      idProcesso: idProcesso,
      recurso: _controlesPrazoPath,
      parametros: <String, String>{_idUnidadeParametro: idUnidade.toString()},
      converter: ProcessoControlePrazo.fromMap,
    );
  }

  /// Lista os retornos programados (prazos de devolução) do processo.
  Future<List<ProcessoRetornoProgramado>> listarRetornosProgramados(
    String idProcesso,
  ) {
    return _buscarLista(
      idProcesso: idProcesso,
      recurso: _retornosProgramadosPath,
      converter: ProcessoRetornoProgramado.fromMap,
    );
  }

  /// Lista os blocos (Assinatura, Reunião ou Interno) que contêm este
  /// processo.
  ///
  /// Como `rel_bloco_protocolo.id_protocolo` é genérico, o mesmo recurso
  /// também serve para documento; aqui é usado apenas com [idProcesso].
  Future<List<ProcessoBloco>> listarBlocos(String idProcesso) {
    return _buscarLista(
      idProcesso: idProcesso,
      recurso: _blocosPath,
      converter: ProcessoBloco.fromMap,
    );
  }

  /// Lista as bases de conhecimento associadas ao **tipo** deste processo.
  ///
  /// A associação do SEI é por tipo de processo, não pelo processo em si —
  /// por isso a mesma base pode aparecer para vários processos do mesmo
  /// tipo, reproduzindo o ícone "B" que o SEI mostra nesse caso.
  Future<List<ProcessoBaseConhecimento>> listarBasesConhecimento(
    String idProcesso,
  ) {
    return _buscarLista(
      idProcesso: idProcesso,
      recurso: _basesConhecimentoPath,
      converter: ProcessoBaseConhecimento.fromMap,
    );
  }

  /// Busca o conteúdo de um documento do processo, interno ou externo.
  ///
  /// Para documento externo, o retorno é apenas o ponteiro do anexo (nome,
  /// tamanho e hash) — o byte do arquivo não vem nesta chamada.
  Future<ProcessoDocumentoConteudo> obterConteudoDocumento(
    String idProcesso,
    String idDocumento,
  ) {
    return _buscarObjeto(
      idProcesso: idProcesso,
      recurso: _documentosPath,
      segmentosExtras: <String>[idDocumento, _conteudoPath],
      converter: ProcessoDocumentoConteudo.fromMap,
    );
  }

  Map<String, String> _parametrosPaginacao({
    required String? cursor,
    required int limite,
  }) {
    return <String, String>{
      ProcessoDetalhePaginacao.limiteCol: limite.toString(),
      if (cursor != null) ProcessoDetalhePaginacao.cursorCol: cursor,
    };
  }

  Future<T> _buscarObjeto<T>({
    required String idProcesso,
    required String recurso,
    required T Function(Map<String, dynamic> map) converter,
    List<String> segmentosExtras = const <String>[],
    Map<String, String>? parametros,
  }) async {
    final Uri uri = _criarUri(
      idProcesso: idProcesso,
      recurso: recurso,
      segmentosExtras: segmentosExtras,
      parametros: parametros,
    );
    final http.Response resposta = await _buscar(uri);
    final Object? corpo = _decodificarJson(resposta, recurso);
    if (corpo is! Map<String, dynamic>) {
      throw ProcessoDetalheApiException(
        'A API retornou um objeto inválido para "$recurso".',
      );
    }

    try {
      return converter(corpo);
    } on ProcessoDetalheApiException {
      rethrow;
    } catch (_) {
      throw ProcessoDetalheApiException(
        'A API retornou um contrato inválido para "$recurso".',
      );
    }
  }

  Future<List<T>> _buscarLista<T>({
    required String idProcesso,
    required String recurso,
    required T Function(Map<String, dynamic> map) converter,
    Map<String, String>? parametros,
  }) async {
    final Uri uri = _criarUri(
      idProcesso: idProcesso,
      recurso: recurso,
      parametros: parametros,
    );
    final http.Response resposta = await _buscar(uri);
    final Object? corpo = _decodificarJson(resposta, recurso);
    if (corpo is! List<Object?>) {
      throw ProcessoDetalheApiException(
        'A API retornou uma lista inválida para "$recurso".',
      );
    }

    final List<T> itens = <T>[];
    for (final Object? item in corpo) {
      if (item is! Map<String, dynamic>) {
        throw ProcessoDetalheApiException(
          'A API retornou um item inválido para "$recurso".',
        );
      }
      try {
        itens.add(converter(item));
      } on ProcessoDetalheApiException {
        rethrow;
      } catch (_) {
        throw ProcessoDetalheApiException(
          'A API retornou um contrato inválido para "$recurso".',
        );
      }
    }
    return itens;
  }

  Uri _criarUri({
    required String idProcesso,
    required String recurso,
    List<String> segmentosExtras = const <String>[],
    Map<String, String>? parametros,
  }) {
    final List<String> segmentosBase = _baseUri.pathSegments
        .where((String segmento) => segmento.isNotEmpty)
        .toList(growable: false);
    return _baseUri.replace(
      pathSegments: <String>[
        ...segmentosBase,
        _processosPath,
        idProcesso,
        recurso,
        ...segmentosExtras,
      ],
      queryParameters: parametros,
    );
  }

  Future<http.Response> _buscar(Uri uri) async {
    try {
      final http.Response resposta = await _cliente.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      );
      if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
        return resposta;
      }
      throw ProcessoDetalheApiException(
        'A API respondeu ${resposta.statusCode} ao consultar "$uri".',
      );
    } on ProcessoDetalheApiException {
      rethrow;
    } catch (_) {
      throw ProcessoDetalheApiException(
        'Não foi possível conectar à API de detalhe de processo em $uri.',
      );
    }
  }

  Object? _decodificarJson(http.Response resposta, String recurso) {
    try {
      return jsonDecode(utf8.decode(resposta.bodyBytes));
    } on FormatException {
      throw ProcessoDetalheApiException(
        'A API retornou JSON inválido para "$recurso".',
      );
    }
  }
}
