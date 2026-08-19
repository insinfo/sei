import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sei_frontend/src/modules/administracao/models/orgao_detalhe.dart';
import 'package:sei_frontend/src/modules/administracao/models/orgao_list_item.dart';
import 'package:sei_frontend/src/modules/administracao/models/pagina_resultado.dart';

/// Falha de comunicação ou de contrato na administração de órgãos.
class OrgaosApiException implements Exception {
  OrgaosApiException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Cliente HTTP somente leitura da administração de órgãos
/// (`GET /orgaos` e `GET /orgaos/:idOrgao`).
class OrgaosService {
  OrgaosService({http.Client? cliente, Uri? baseUri})
      : _cliente = cliente ?? http.Client(),
        _baseUri = baseUri ?? Uri.parse('http://localhost:3350/api/v1');

  static const String _caminho = 'orgaos';

  final http.Client _cliente;
  final Uri _baseUri;

  /// Lista órgãos com filtros opcionais e paginação.
  Future<PaginaResultado<OrgaoListItem>> listar({
    String? sigla,
    bool? ativo,
    int limite = 50,
    int deslocamento = 0,
  }) async {
    final Map<String, String> parametros = <String, String>{
      'limite': limite.toString(),
      if (deslocamento > 0) 'deslocamento': deslocamento.toString(),
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
        throw OrgaosApiException(
          'A API respondeu ${resposta.statusCode} ao listar órgãos.',
        );
      }

      final Object? corpo = _decodificarJson(resposta);
      if (corpo is! Map<String, dynamic>) {
        throw OrgaosApiException(
            'A API retornou uma página inválida de órgãos.');
      }
      return PaginaResultado<OrgaoListItem>.fromMap(
          corpo, OrgaoListItem.fromMap);
    } on OrgaosApiException {
      rethrow;
    } catch (_) {
      throw OrgaosApiException(
        'Não foi possível conectar à API de órgãos em $uri.',
      );
    }
  }

  /// Busca o detalhe de um órgão pelo identificador.
  Future<OrgaoDetalhe> buscar(int idOrgao) async {
    final Uri uri = _criarUri('$_caminho/$idOrgao', const <String, String>{});
    try {
      final http.Response resposta = await _cliente.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      );
      if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
        throw OrgaosApiException(
          'A API respondeu ${resposta.statusCode} ao consultar o órgão $idOrgao.',
        );
      }

      final Object? corpo = _decodificarJson(resposta);
      if (corpo is! Map<String, dynamic>) {
        throw OrgaosApiException('A API retornou um órgão inválido.');
      }
      return OrgaoDetalhe.fromMap(corpo);
    } on OrgaosApiException {
      rethrow;
    } catch (_) {
      throw OrgaosApiException(
        'Não foi possível conectar à API de órgãos em $uri.',
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
      throw OrgaosApiException('A API retornou JSON inválido para órgãos.');
    }
  }
}
