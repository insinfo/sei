import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/controle_processos/controle_processos_service.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe atividades abertas da unidade para consulta de desenvolvimento.
class ControleProcessosController {
  ControleProcessosController(this._service);

  final ControleProcessosService _service;

  Future<void> recebidos(
    RequestContext request,
    ResponseContext response,
  ) async {
    response.headers['access-control-allow-origin'] = '*';
    try {
      final filtro = ControleProcessosFiltro.fromMap(request.queryParameters);
      final pagina = await _service.listarRecebidos(filtro);
      await response.json(pagina.toMap());
    } on FormatException catch (erro) {
      await _responderFiltroInvalido(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderFiltroInvalido(response, erro.message.toString());
    }
  }

  /// Expõe atividades iniciadas pela unidade, sem alterar a base de referência.
  Future<void> gerados(
    RequestContext request,
    ResponseContext response,
  ) async {
    response.headers['access-control-allow-origin'] = '*';
    try {
      final filtro = ControleProcessosFiltro.fromMap(
        request.queryParameters,
        modo: ControleProcessosModo.gerados,
      );
      final pagina = await _service.listarGerados(filtro);
      await response.json(pagina.toMap());
    } on FormatException catch (erro) {
      await _responderFiltroInvalido(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderFiltroInvalido(response, erro.message.toString());
    }
  }

  Future<void> _responderFiltroInvalido(
    ResponseContext response,
    String mensagem,
  ) async {
    response.statusCode = 400;
    await response.json(<String, dynamic>{
      'erro': true,
      'mensagem': mensagem,
    });
  }
}
