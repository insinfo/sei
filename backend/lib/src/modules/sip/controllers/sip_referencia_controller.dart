import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/sip/repositories/sip_referencia_repository.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe somente o catálogo público de sistemas do SIP para desenvolvimento.
class SipReferenciaController {
  Future<void> sistemas(
    RequestContext request,
    ResponseContext response,
  ) async {
    final SipReferenciaRepository repositorio =
        request.make<SipReferenciaRepository>();
    final List<SistemaSipResumo> sistemas =
        await repositorio.listarSistemasAtivos();

    await RespostaApiHttp.responderLista(response, sistemas);
  }
}
