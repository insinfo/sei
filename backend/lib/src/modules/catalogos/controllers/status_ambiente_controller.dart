import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_backend/src/modules/catalogos/repositories/catalogo_repository.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_core/sei_core.dart';

/// Informa se a API alcança o banco restaurado, sem expor credenciais.
class StatusAmbienteController {
  Future<void> obter(RequestContext request, ResponseContext response) async {
    final SeiAppConfig config = request.make<SeiAppConfig>();
    final CatalogoRepository repositorio = request.make<CatalogoRepository>();
    final CatalogoResumo catalogos = await repositorio.obterResumo();
    final StatusAmbiente status = StatusAmbiente(
      status: 'disponivel',
      modo: 'desenvolvimento_somente_leitura',
      bancoDados: config.dbName,
      catalogos: catalogos,
    );

    await response.json(status.toMap());
  }
}
