import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sei_core/sei_core.dart';

/// Falha de comunicação ou de contrato no contexto de desenvolvimento.
class ContextoDesenvolvimentoApiException implements Exception {
  ContextoDesenvolvimentoApiException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Cliente HTTP do contexto explícito usado durante o desenvolvimento.
///
/// O contexto retornado pela API apenas identifica dados de referência para a
/// sessão local. Ele não substitui a autenticação e a autorização do SIP.
class ContextoDesenvolvimentoService {
  ContextoDesenvolvimentoService({http.Client? cliente, Uri? baseUri})
      : _cliente = cliente ?? http.Client(),
        _baseUri = baseUri ?? Uri.parse('http://localhost:3350/api/v1');

  static const String _contextoPath = 'contexto/desenvolvimento';

  final http.Client _cliente;
  final Uri _baseUri;

  /// Busca o usuário de referência e as unidades disponíveis localmente.
  Future<ContextoDesenvolvimento> buscar() async {
    final Uri uri = _criarUri(_contextoPath);
    try {
      final http.Response resposta = await _cliente.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      );
      if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
        throw ContextoDesenvolvimentoApiException(
          'A API respondeu ${resposta.statusCode} ao carregar o contexto de desenvolvimento.',
        );
      }

      final Object? corpo = _decodificarJson(resposta);
      if (corpo is! Map<String, dynamic>) {
        throw ContextoDesenvolvimentoApiException(
          'A API retornou um contexto de desenvolvimento inválido.',
        );
      }
      return ContextoDesenvolvimento.fromMap(corpo);
    } on ContextoDesenvolvimentoApiException {
      rethrow;
    } catch (_) {
      throw ContextoDesenvolvimentoApiException(
        'Não foi possível conectar à API de contexto de desenvolvimento em $uri.',
      );
    }
  }

  Uri _criarUri(String caminho) {
    final String caminhoBase = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;
    return _baseUri.replace(path: '$caminhoBase/$caminho');
  }

  Object? _decodificarJson(http.Response resposta) {
    try {
      return jsonDecode(utf8.decode(resposta.bodyBytes));
    } on FormatException {
      throw ContextoDesenvolvimentoApiException(
        'A API retornou JSON inválido para o contexto de desenvolvimento.',
      );
    }
  }
}
