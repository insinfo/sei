import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sei_frontend/src/modules/administracao/models/pagina_resultado.dart';
import 'package:sei_frontend/src/modules/administracao/models/usuario_detalhe.dart';
import 'package:sei_frontend/src/modules/administracao/models/usuario_list_item.dart';

/// Falha de comunicação ou de contrato na administração de usuários.
class UsuariosApiException implements Exception {
  UsuariosApiException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Cliente HTTP somente leitura da administração de usuários
/// (`GET /usuarios` e `GET /usuarios/:idUsuario`).
class UsuariosService {
  UsuariosService({http.Client? cliente, Uri? baseUri})
      : _cliente = cliente ?? http.Client(),
        _baseUri = baseUri ?? Uri.parse('http://localhost:3350/api/v1');

  static const String _caminho = 'usuarios';

  final http.Client _cliente;
  final Uri _baseUri;

  /// Lista usuários com filtros opcionais e paginação.
  Future<PaginaResultado<UsuarioListItem>> listar({
    int? idOrgao,
    String? sigla,
    String? nome,
    bool? ativo,
    int limite = 50,
    int deslocamento = 0,
  }) async {
    final Map<String, String> parametros = <String, String>{
      'limite': limite.toString(),
      if (deslocamento > 0) 'deslocamento': deslocamento.toString(),
      if (idOrgao != null) 'id_orgao': idOrgao.toString(),
      if (sigla != null && sigla.isNotEmpty) 'sigla': sigla,
      if (nome != null && nome.isNotEmpty) 'nome': nome,
      if (ativo != null) 'sin_ativo': ativo ? 'S' : 'N',
    };
    final Uri uri = _criarUri(_caminho, parametros);

    try {
      final http.Response resposta = await _cliente.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      );
      if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
        throw UsuariosApiException(
          'A API respondeu ${resposta.statusCode} ao listar usuários.',
        );
      }

      final Object? corpo = _decodificarJson(resposta);
      if (corpo is! Map<String, dynamic>) {
        throw UsuariosApiException(
            'A API retornou uma página inválida de usuários.');
      }
      return PaginaResultado<UsuarioListItem>.fromMap(
        corpo,
        UsuarioListItem.fromMap,
      );
    } on UsuariosApiException {
      rethrow;
    } catch (_) {
      throw UsuariosApiException(
        'Não foi possível conectar à API de usuários em $uri.',
      );
    }
  }

  /// Busca o detalhe de um usuário pelo identificador.
  Future<UsuarioDetalhe> buscar(int idUsuario) async {
    final Uri uri = _criarUri('$_caminho/$idUsuario', const <String, String>{});
    try {
      final http.Response resposta = await _cliente.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      );
      if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
        throw UsuariosApiException(
          'A API respondeu ${resposta.statusCode} ao consultar o usuário $idUsuario.',
        );
      }

      final Object? corpo = _decodificarJson(resposta);
      if (corpo is! Map<String, dynamic>) {
        throw UsuariosApiException('A API retornou um usuário inválido.');
      }
      return UsuarioDetalhe.fromMap(corpo);
    } on UsuariosApiException {
      rethrow;
    } catch (_) {
      throw UsuariosApiException(
        'Não foi possível conectar à API de usuários em $uri.',
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
      throw UsuariosApiException('A API retornou JSON inválido para usuários.');
    }
  }
}
