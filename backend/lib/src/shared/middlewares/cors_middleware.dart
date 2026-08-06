import 'package:angel3_framework/angel3_framework.dart';

/// Aplica CORS a todas as rotas e encerra requisições de preflight OPTIONS.
///
/// Retorna `true` para a cadeia continuar nas requisições normais e `false`
/// para impedir que uma requisição OPTIONS alcance controladores de negócio.
Future<bool> corsMiddleware(
  RequestContext request,
  ResponseContext response,
) async {
  response.headers['access-control-allow-origin'] = '*';
  response.headers['access-control-allow-methods'] =
      'GET, POST, PUT, PATCH, DELETE, OPTIONS';
  response.headers['access-control-allow-headers'] =
      'Accept, Content-Type, Authorization';
  response.headers['access-control-max-age'] = '86400';

  if (request.method == 'OPTIONS') {
    response.statusCode = 204;
    response.contentLength = 0;
    await response.close();
    return false;
  }
  return true;
}
