import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/autenticacao/models/login_resultado.dart';
import 'package:sei_backend/src/modules/autenticacao/services/autenticacao_service.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe login local e a lista de órgãos ativos para o seletor de login.
class AutenticacaoController {
  static const String _campoUsuario = 'usuario';
  static const String _campoSenha = 'senha';
  static const String _campoSiglaOrgao = 'sigla_orgao';

  Future<void> login(RequestContext request, ResponseContext response) async {
    await request.parseBody();
    final Map<String, dynamic> corpo = request.bodyAsMap;

    try {
      final String usuario = _campoObrigatorio(corpo, _campoUsuario);
      final String senha = _campoObrigatorio(corpo, _campoSenha);
      final String siglaOrgao = _campoObrigatorio(corpo, _campoSiglaOrgao);

      final AutenticacaoService servico = request.make<AutenticacaoService>();
      final LoginResultado resultado = await servico.login(
        usuario: usuario,
        senha: senha,
        siglaOrgao: siglaOrgao,
      );

      await response.json(resultado.toMap());
    } on AutenticacaoInvalidaException {
      await RespostaApiHttp.responderErro(
        response,
        codigoHttp: 401,
        mensagem: AutenticacaoInvalidaException.mensagemGenerica,
      );
    } on FormatException catch (erro) {
      await RespostaApiHttp.responderErro(
        response,
        codigoHttp: 400,
        mensagem: erro.message,
      );
    }
  }

  Future<void> orgaos(RequestContext request, ResponseContext response) async {
    final AutenticacaoService servico = request.make<AutenticacaoService>();
    final List<OrgaoLoginResumo> orgaos = await servico.listarOrgaosAtivos();

    await response.json(<String, dynamic>{
      'itens': orgaos
          .map((OrgaoLoginResumo orgao) => orgao.toMap())
          .toList(growable: false),
    });
  }

  String _campoObrigatorio(Map<String, dynamic> corpo, String campo) {
    final Object? valor = corpo[campo];
    if (valor is! String || valor.trim().isEmpty) {
      throw FormatException('O campo $campo é obrigatório.');
    }
    return valor.trim();
  }
}
