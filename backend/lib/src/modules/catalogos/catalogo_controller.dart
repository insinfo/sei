import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/catalogos/catalogo_service.dart';

/// Expõe os catálogos iniciais para a interface de desenvolvimento do SEI.
class CatalogoController {
  CatalogoController(this._service);

  final CatalogoService _service;

  Future<void> resumo(RequestContext request, ResponseContext response) async {
    _aplicarCabecalhosCors(response);
    final resumo = await _service.obterResumo();
    await response.json(resumo.toMap());
  }

  Future<void> tiposProcedimento(
    RequestContext request,
    ResponseContext response,
  ) async {
    _aplicarCabecalhosCors(response);
    final tipos = await _service.listarTiposProcedimento();
    await response.json(tipos.map((tipo) => tipo.toMap()).toList());
  }

  Future<void> series(RequestContext request, ResponseContext response) async {
    _aplicarCabecalhosCors(response);
    final series = await _service.listarSeries();
    await response.json(series.map((serie) => serie.toMap()).toList());
  }

  void _aplicarCabecalhosCors(ResponseContext response) {
    response.headers['access-control-allow-origin'] = '*';
  }
}
