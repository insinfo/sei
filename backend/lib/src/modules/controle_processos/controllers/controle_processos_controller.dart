import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/controle_processos/repositories/controle_processos_repository.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe atividades abertas da unidade para consulta de desenvolvimento.
class ControleProcessosController {
  Future<void> recebidos(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final ControleProcessosFiltro filtro = ControleProcessosFiltro.fromMap(
        request.queryParameters,
        modo: ControleProcessosModo.recebidos,
      );
      final ControleProcessosRepository repositorio =
          request.make<ControleProcessosRepository>();
      final PaginaProcessosRecebidos pagina = await repositorio.listar(filtro);
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
    try {
      final ControleProcessosFiltro filtro = ControleProcessosFiltro.fromMap(
        request.queryParameters,
        modo: ControleProcessosModo.gerados,
      );
      final ControleProcessosRepository repositorio =
          request.make<ControleProcessosRepository>();
      final PaginaProcessosRecebidos pagina = await repositorio.listar(filtro);
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
    await RespostaApiHttp.responderErro(
      response,
      codigoHttp: 400,
      mensagem: mensagem,
    );
  }
}
