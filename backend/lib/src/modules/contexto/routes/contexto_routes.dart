import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/contexto/controllers/contexto_desenvolvimento_controller.dart';

/// Registra a rota que fornece o contexto local de desenvolvimento do SEI.
void registrarRotasContexto(
  Angel app,
  ContextoDesenvolvimentoController contextoDesenvolvimentoController, {
  required RequestHandler middlewareConexao,
}) {
  app.get(
    '/api/v1/contexto/desenvolvimento',
    contextoDesenvolvimentoController.obter,
    middleware: <RequestHandler>[middlewareConexao],
  );
}
