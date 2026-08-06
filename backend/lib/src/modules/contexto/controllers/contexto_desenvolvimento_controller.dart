import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_backend/src/modules/contexto/repositories/contexto_desenvolvimento_repository.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe o contexto de desenvolvimento sem tratar a resposta como sessão SIP.
class ContextoDesenvolvimentoController {
  Future<void> obter(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final SeiAppConfig config = request.make<SeiAppConfig>();
      final ContextoDesenvolvimentoRepository repositorio =
          request.make<ContextoDesenvolvimentoRepository>();
      final ContextoDesenvolvimento contexto =
          await repositorio.obterPorSiglaUsuario(
        config.desenvolvimentoUsuarioSigla,
      );

      await response.json(contexto.toMap());
    } on StateError catch (erro) {
      await RespostaApiHttp.responderErro(
        response,
        codigoHttp: 503,
        mensagem: erro.message,
      );
    }
  }
}
