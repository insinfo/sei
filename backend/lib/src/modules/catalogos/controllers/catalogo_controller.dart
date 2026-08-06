import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/catalogos/repositories/catalogo_repository.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe os catálogos iniciais para a interface de desenvolvimento do SEI.
class CatalogoController {
  Future<void> resumo(RequestContext request, ResponseContext response) async {
    final CatalogoRepository repositorio = request.make<CatalogoRepository>();
    final CatalogoResumo resumo = await repositorio.obterResumo();

    await response.json(resumo.toMap());
  }

  Future<void> tiposProcedimento(
    RequestContext request,
    ResponseContext response,
  ) async {
    final CatalogoRepository repositorio = request.make<CatalogoRepository>();
    final List<TipoProcedimento> tipos =
        await repositorio.listarTiposProcedimento();

    await RespostaApiHttp.responderLista(response, tipos);
  }

  Future<void> series(RequestContext request, ResponseContext response) async {
    final CatalogoRepository repositorio = request.make<CatalogoRepository>();
    final List<Serie> series = await repositorio.listarSeries();

    await RespostaApiHttp.responderLista(response, series);
  }
}
