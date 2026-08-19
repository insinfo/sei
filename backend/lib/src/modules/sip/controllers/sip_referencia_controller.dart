import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/sip/repositories/sip_referencia_repository.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/parametros_http.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe o catálogo público do SIP e a resolução de autorização por recurso.
///
/// **Não expõe autenticação.** Não há aqui nem rota de login, nem sessão,
/// nem verificação de senha: a Base de Referência delega isso a um LDAP/AD
/// externo por órgão, fora do escopo deste controller. Ver
/// `SipReferenciaRepository` e `backend/docs/evidencias_processo_detalhe.md`.
class SipReferenciaController {
  static const String idUsuarioParam = 'idUsuario';
  static const String _idUnidadeParam = 'idUnidade';
  static const String _idSistemaParam = 'idSistema';

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

  Future<void> autorizacao(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idUsuario = ParametrosHttp.identificadorPositivo(
        request.params[idUsuarioParam],
        nomeCampo: idUsuarioParam,
      );
      final int idUnidade = ParametrosHttp.identificadorPositivo(
        request.queryParameters[_idUnidadeParam],
        nomeCampo: _idUnidadeParam,
      );
      final String? idSistemaBruto = request.queryParameters[_idSistemaParam];
      final int? idSistema = idSistemaBruto == null
          ? null
          : ParametrosHttp.identificadorPositivo(
              idSistemaBruto,
              nomeCampo: _idSistemaParam,
            );

      final SipReferenciaRepository repositorio =
          request.make<SipReferenciaRepository>();
      final AutorizacaoUsuario autorizacao =
          await repositorio.resolverAutorizacao(
        idUsuario,
        idUnidade,
        idSistema: idSistema,
      );

      await response.json(autorizacao.toMap());
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> _responderRequisicaoInvalida(
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
