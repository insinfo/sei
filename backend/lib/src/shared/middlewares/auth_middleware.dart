import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/autenticacao/services/autenticacao_service.dart';
import 'package:sei_backend/src/modules/autenticacao/services/autenticacao_token_service.dart';
import 'package:sei_backend/src/shared/models/usuario_autenticado.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Exige um JWT de sessão válido no header `Authorization: Bearer <token>`.
///
/// Em caso de sucesso, injeta um [UsuarioAutenticado] no contêiner da
/// requisição (mesmo estilo de injeção de `MiddlewareConexaoSei`/
/// `MiddlewareConexaoSip`, mas com identidade em vez de conexão), disponível
/// para controllers via `request.make<UsuarioAutenticado>()`. Em caso de
/// falha, responde 401 e interrompe a cadeia.
///
/// Aplicado só nas rotas novas de cadastro (usuário/unidade/órgão) nesta
/// rodada; aplicar retroativamente nas rotas de leitura existentes é
/// mudança maior, documentada como próximo passo no roteiro mestre.
class AuthMiddleware {
  AuthMiddleware(this._tokenService);

  final AutenticacaoTokenService _tokenService;

  static const String _prefixoBearer = 'Bearer ';

  Future<bool> executar(
    RequestContext request,
    ResponseContext response,
  ) async {
    final String? cabecalho = request.headers?.value('authorization');
    if (cabecalho == null || !cabecalho.startsWith(_prefixoBearer)) {
      return _naoAutorizado(response);
    }

    final String token = cabecalho.substring(_prefixoBearer.length).trim();
    final Map<String, dynamic>? claims = await _tokenService.verificar(token);
    if (claims == null) {
      return _naoAutorizado(response);
    }

    final Object? idUsuario = claims[AutenticacaoService.claimIdUsuario];
    final Object? idOrgao = claims[AutenticacaoService.claimIdOrgao];
    final Object? sigla = claims[AutenticacaoService.claimSigla];
    final Object? nome = claims[AutenticacaoService.claimNome];
    if (idUsuario == null ||
        idOrgao == null ||
        sigla is! String ||
        nome is! String) {
      return _naoAutorizado(response);
    }

    final container = request.container;
    if (container == null) {
      throw StateError('O contêiner da requisição não está disponível.');
    }
    container.registerSingleton<UsuarioAutenticado>(
      UsuarioAutenticado(
        idUsuario: SeiCoreUtils.inteiro(idUsuario, nomeCampo: 'id_usuario'),
        idOrgao: SeiCoreUtils.inteiro(idOrgao, nomeCampo: 'id_orgao'),
        sigla: sigla,
        nome: nome,
      ),
    );
    return true;
  }

  Future<bool> _naoAutorizado(ResponseContext response) async {
    await RespostaApiHttp.responderErro(
      response,
      codigoHttp: 401,
      mensagem: 'Sessão inválida ou expirada.',
    );
    return false;
  }
}
