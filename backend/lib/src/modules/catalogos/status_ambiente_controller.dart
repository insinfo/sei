import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_backend/src/modules/catalogos/catalogo_service.dart';
import 'package:sei_core/sei_core.dart';

/// Informa se a API alcança o banco restaurado, sem expor credenciais.
class StatusAmbienteController {
  StatusAmbienteController(this._config, this._catalogoService);

  final SeiAppConfig _config;
  final CatalogoService _catalogoService;

  Future<void> obter(RequestContext request, ResponseContext response) async {
    response.headers['access-control-allow-origin'] = '*';
    final catalogos = await _catalogoService.obterResumo();
    final status = StatusAmbiente(
      status: 'disponivel',
      modo: 'desenvolvimento_somente_leitura',
      bancoDados: _config.dbName,
      catalogos: catalogos,
    );
    await response.json(status.toMap());
  }
}
