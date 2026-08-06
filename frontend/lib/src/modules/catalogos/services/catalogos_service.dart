import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sei_core/sei_core.dart';

/// Falha de comunicação ou de contrato retornada pela API de catálogos.
class CatalogosApiException implements Exception {
  CatalogosApiException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Estado tipado carregado para o painel inicial de catálogos do SEI.
class PainelCatalogos {
  const PainelCatalogos({
    required this.status,
    required this.resumo,
    required this.tiposProcedimento,
    required this.series,
  });

  final StatusAmbiente status;
  final CatalogoResumo resumo;
  final List<TipoProcedimento> tiposProcedimento;
  final List<Serie> series;
}

/// Cliente HTTP somente leitura para o primeiro recorte funcional do SEI.
///
/// As conversões de JSON ficam nesta borda; os componentes recebem apenas
/// modelos tipados do pacote compartilhado [sei_core].
class CatalogosService {
  CatalogosService({http.Client? cliente, Uri? baseUri})
      : _cliente = cliente ?? http.Client(),
        _baseUri = baseUri ?? Uri.parse('http://localhost:3350/api/v1');

  static const String _saudePath = 'saude';
  static const String _resumoPath = 'catalogos/resumo';
  static const String _tiposProcedimentoPath = 'catalogos/tipos-procedimento';
  static const String _seriesPath = 'catalogos/series';

  final http.Client _cliente;
  final Uri _baseUri;

  /// Busca todas as informações necessárias para a tela inicial em paralelo.
  Future<PainelCatalogos> carregarPainel() async {
    final Future<StatusAmbiente> statusFuture = buscarStatus();
    final Future<CatalogoResumo> resumoFuture = buscarResumo();
    final Future<List<TipoProcedimento>> tiposFuture =
        listarTiposProcedimento();
    final Future<List<Serie>> seriesFuture = listarSeries();

    return PainelCatalogos(
      status: await statusFuture,
      resumo: await resumoFuture,
      tiposProcedimento: await tiposFuture,
      series: await seriesFuture,
    );
  }

  /// Confere a disponibilidade da API e a identificação do banco carregado.
  Future<StatusAmbiente> buscarStatus() async {
    final Map<String, dynamic> dados = await _buscarMapa(_saudePath);
    return StatusAmbiente.fromMap(dados);
  }

  /// Busca os quantitativos dos catálogos nativos restaurados.
  Future<CatalogoResumo> buscarResumo() async {
    final Map<String, dynamic> dados = await _buscarMapa(_resumoPath);
    return CatalogoResumo.fromMap(dados);
  }

  /// Lista os tipos de processo para consulta, sem alterar o banco.
  Future<List<TipoProcedimento>> listarTiposProcedimento() async {
    final List<Map<String, dynamic>> dados =
        await _buscarLista(_tiposProcedimentoPath);
    return dados.map(TipoProcedimento.fromMap).toList();
  }

  /// Lista as séries documentais para consulta, sem alterar o banco.
  Future<List<Serie>> listarSeries() async {
    final List<Map<String, dynamic>> dados = await _buscarLista(_seriesPath);
    return dados.map(Serie.fromMap).toList();
  }

  Uri _criarUri(String caminho) {
    final String caminhoBase = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;
    return _baseUri.replace(path: '$caminhoBase/$caminho');
  }

  Future<Map<String, dynamic>> _buscarMapa(String caminho) async {
    final http.Response resposta = await _buscar(caminho);
    final Object? corpo = _decodificarJson(resposta, caminho);
    if (corpo is Map<String, dynamic>) {
      return corpo;
    }
    throw CatalogosApiException(
      'A API retornou um objeto inválido para "$caminho".',
    );
  }

  Future<List<Map<String, dynamic>>> _buscarLista(String caminho) async {
    final http.Response resposta = await _buscar(caminho);
    final Object? corpo = _decodificarJson(resposta, caminho);
    if (corpo is! List<Object?>) {
      throw CatalogosApiException(
        'A API retornou uma lista inválida para "$caminho".',
      );
    }

    final List<Map<String, dynamic>> itens = <Map<String, dynamic>>[];
    for (final Object? item in corpo) {
      if (item is! Map<String, dynamic>) {
        throw CatalogosApiException(
          'A API retornou um item inválido para "$caminho".',
        );
      }
      itens.add(item);
    }
    return itens;
  }

  Future<http.Response> _buscar(String caminho) async {
    final Uri uri = _criarUri(caminho);
    try {
      final http.Response resposta = await _cliente.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      );
      if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
        return resposta;
      }
      throw CatalogosApiException(
        'A API respondeu ${resposta.statusCode} ao consultar "$caminho".',
      );
    } on CatalogosApiException {
      rethrow;
    } catch (_) {
      throw CatalogosApiException(
        'Não foi possível conectar à API em $uri.',
      );
    }
  }

  Object? _decodificarJson(http.Response resposta, String caminho) {
    try {
      return jsonDecode(utf8.decode(resposta.bodyBytes));
    } on FormatException {
      throw CatalogosApiException(
        'A API retornou JSON inválido para "$caminho".',
      );
    }
  }
}
