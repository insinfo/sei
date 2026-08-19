import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/sip/controllers/sip_referencia_controller.dart';

/// Registra as rotas de consulta à referência pública do SIP.
void registrarRotasSipReferencia(
  Angel app,
  SipReferenciaController controller, {
  required RequestHandler middlewareConexao,
}) {
  app.get(
    '/api/v1/sip/referencia/sistemas',
    controller.sistemas,
    middleware: <RequestHandler>[middlewareConexao],
  );
  app.get(
    '/api/v1/sip/usuarios/:${SipReferenciaController.idUsuarioParam}'
    '/autorizacao',
    controller.autorizacao,
    middleware: <RequestHandler>[middlewareConexao],
  );
}
