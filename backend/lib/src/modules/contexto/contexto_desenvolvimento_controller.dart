import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/contexto/contexto_desenvolvimento_service.dart';

/// Expõe o contexto de desenvolvimento sem tratar a resposta como sessão SIP.
class ContextoDesenvolvimentoController {
  ContextoDesenvolvimentoController(this._service);

  final ContextoDesenvolvimentoService _service;

  Future<void> obter(
    RequestContext request,
    ResponseContext response,
  ) async {
    response.headers['access-control-allow-origin'] = '*';
    try {
      final contexto = await _service.obter();
      await response.json(contexto.toMap());
    } on StateError catch (erro) {
      response.statusCode = 503;
      await response.json(<String, dynamic>{
        'erro': true,
        'mensagem': erro.message,
      });
    }
  }
}
