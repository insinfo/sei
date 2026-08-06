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
    Map<String, String>? parametros,
  }) async {
    final Uri uri = _criarUri(
      idProcesso: idProcesso,
      recurso: recurso,
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

  Uri _criarUri({
    required String idProcesso,
    required String recurso,
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
