import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sei_frontend/src/modules/administracao/models/pagina_resultado.dart';
import 'package:sei_frontend/src/modules/administracao/models/unidade_detalhe.dart';
import 'package:sei_frontend/src/modules/administracao/models/unidade_list_item.dart';

/// Falha de comunicação ou de contrato na administração de unidades.
class UnidadesApiException implements Exception {
  UnidadesApiException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Cliente HTTP somente leitura da administração de unidades
/// (`GET /unidades` e `GET /unidades/:idUnidade`).
class UnidadesService {
  UnidadesService({http.Client? cliente, Uri? baseUri})
      : _cliente = cliente ?? http.Client(),
        _baseUri = baseUri ?? Uri.parse('http://localhost:3350/api/v1');

  static const String _caminho = 'unidades';

  final http.Client _cliente;
  final Uri _baseUri;

  /// Lista unidades com filtros opcionais e paginação.
  Future<PaginaResultado<UnidadeListItem>> listar({
    int? idOrgao,
    String? sigla,
    bool? ativo,
    int limite = 50,
    int deslocamento = 0,
  }) async {
    final Map<String, String> parametros = <String, String>{
      'limite': limite.toString(),
      if (deslocamento > 0) 'deslocamento': deslocamento.toString(),
      if (idOrgao != null) 'id_orgao': idOrgao.toString(),
      if (sigla != null && sigla.isNotEmpty) 'sigla': sigla,
      if (ativo != null) 'sin_ativo': ativo ? 'S' : 'N',
    };
    final Uri uri = _criarUri(_caminho, parametros);

    try {
      final http.Response resposta = await _cliente.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      );
      if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
        throw UnidadesApiException(
          'A API respondeu ${resposta.statusCode} ao listar unidades.',
        );
      }

      final Object? corpo = _decodificarJson(resposta);
      if (corpo is! Map<String, dynamic>) {
        throw UnidadesApiException(
            'A API retornou uma página inválida de unidades.');
      }
      return PaginaResultado<UnidadeListItem>.fromMap(
        corpo,
        UnidadeListItem.fromMap,
      );
    } on UnidadesApiException {
      rethrow;
    } catch (_) {
      throw UnidadesApiException(
        'Não foi possível conectar à API de unidades em $uri.',
      );
    }
  }

  /// Busca o detalhe de uma unidade pelo identificador.
  Future<UnidadeDetalhe> buscar(int idUnidade) async {
    final Uri uri = _criarUri('$_caminho/$idUnidade', const <String, String>{});
    try {
      final http.Response resposta = await _cliente.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      );
      if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
        throw UnidadesApiException(
          'A API respondeu ${resposta.statusCode} ao consultar a unidade $idUnidade.',
        );
      }

      final Object? corpo = _decodificarJson(resposta);
      if (corpo is! Map<String, dynamic>) {
        throw UnidadesApiException('A API retornou uma unidade inválida.');
      }
      return UnidadeDetalhe.fromMap(corpo);
    } on UnidadesApiException {
      rethrow;
    } catch (_) {
      throw UnidadesApiException(
        'Não foi possível conectar à API de unidades em $uri.',
      );
    }
  }

  Uri _criarUri(String caminho, Map<String, String> parametros) {
    final String caminhoBase = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;
    return _baseUri.replace(
      path: '$caminhoBase/$caminho',
      queryParameters: parametros.isEmpty ? null : parametros,
    );
  }

  Object? _decodificarJson(http.Response resposta) {
    try {
      return jsonDecode(utf8.decode(resposta.bodyBytes));
    } on FormatException {
      throw UnidadesApiException('A API retornou JSON inválido para unidades.');
    }
  }
}
