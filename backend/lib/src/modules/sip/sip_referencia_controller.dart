import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/sip/sip_referencia_service.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe somente o catálogo público de sistemas do SIP para desenvolvimento.
class SipReferenciaController {
  SipReferenciaController(this._service);

  final SipReferenciaService _service;

  Future<void> sistemas(
    RequestContext request,
    ResponseContext response,
  ) async {
    response.headers['access-control-allow-origin'] = '*';
    final sistemas = await _service.listarSistemasAtivos();
    await response.json(
      sistemas
          .map((SistemaSipResumo sistema) => sistema.toMap())
          .toList(growable: false),
    );
  }
}
