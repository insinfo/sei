import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sei_core/sei_core.dart';

/// Falha de comunicação ou de contrato no controle de processos.
class ControleProcessosApiException implements Exception {
  ControleProcessosApiException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Cliente somente leitura das filas de processos da unidade.
class ControleProcessosService {
  ControleProcessosService({http.Client? cliente, Uri? baseUri})
      : _cliente = cliente ?? http.Client(),
        _baseUri = baseUri ?? Uri.parse('http://localhost:3350/api/v1');

  static const String _recebidosPath = 'controle-processos/recebidos';
  static const String _geradosPath = 'controle-processos/gerados';

  final http.Client _cliente;
  final Uri _baseUri;

  /// Busca a página de atividades abertas recebidas pela unidade informada.
  Future<PaginaProcessosRecebidos> listarRecebidos({
    required int idUnidade,
    int limite = 50,
    int deslocamento = 0,
  }) {
    return _listarProcessos(
      caminho: _recebidosPath,
      idUnidade: idUnidade,
      limite: limite,
      deslocamento: deslocamento,
      descricaoConsulta: 'atividades em aberto',
    );
  }

  /// Busca a página de processos gerados pela unidade informada.
  Future<PaginaProcessosRecebidos> listarGerados({
    required int idUnidade,
    int limite = 50,
    int deslocamento = 0,
  }) {
    return _listarProcessos(
      caminho: _geradosPath,
      idUnidade: idUnidade,
      limite: limite,
      deslocamento: deslocamento,
      descricaoConsulta: 'processos gerados',
    );
  }

  Future<PaginaProcessosRecebidos> _listarProcessos({
    required String caminho,
    required int idUnidade,
    required int limite,
    required int deslocamento,
    required String descricaoConsulta,
  }) async {
    final Map<String, String> parametros = <String, String>{
      'id_unidade': idUnidade.toString(),
      'limite': limite.toString(),
      if (deslocamento > 0) 'deslocamento': deslocamento.toString(),
    };
    final Uri uri = _criarUri(caminho, parametros);

    try {
      final http.Response resposta = await _cliente.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      );
      if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
        throw ControleProcessosApiException(
          'A API respondeu ${resposta.statusCode} ao consultar $descricaoConsulta.',
        );
      }

      final Object? corpo = _decodificarJson(resposta);
      if (corpo is! Map<String, dynamic>) {
        throw ControleProcessosApiException(
          'A API retornou uma página inválida de $descricaoConsulta.',
        );
      }
      return PaginaProcessosRecebidos.fromMap(corpo);
    } on ControleProcessosApiException {
      rethrow;
    } catch (_) {
      throw ControleProcessosApiException(
        'Não foi possível conectar à API de controle de processos para consultar $descricaoConsulta em $uri.',
      );
    }
  }

  Uri _criarUri(String caminho, Map<String, String> parametros) {
    final String caminhoBase = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;
    return _baseUri.replace(
      path: '$caminhoBase/$caminho',
      queryParameters: parametros,
    );
  }

  Object? _decodificarJson(http.Response resposta) {
    try {
      return jsonDecode(utf8.decode(resposta.bodyBytes));
    } on FormatException {
      throw ControleProcessosApiException(
        'A API retornou JSON inválido para a consulta de processos.',
      );
    }
  }
}
