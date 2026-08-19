import 'package:angel3_framework/angel3_framework.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sei_backend/src/modules/autenticacao/models/login_resultado.dart';
import 'package:sei_backend/src/modules/autenticacao/services/autenticacao_service.dart';
import 'package:sei_backend/src/modules/oidc/controllers/oidc_controller.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_core/sei_core.dart';

/// Página de login do provider OIDC e o processamento da submissão do
/// formulário.
///
/// Reaproveita o login local já existente (`AutenticacaoService`, o mesmo
/// que valida `sei_5_0_0.usuario.senha` com bcrypt para `POST
/// /api/v1/auth/login`) como a verificação de credencial por trás do fluxo
/// OIDC — o mesmo raciocínio do `LoginController.handleLoginAction` do
/// projeto de referência `new_sali`, que chama seu próprio
/// `AuthRepository.authenticate` antes de emitir o código de autorização.
class OidcLoginController {
  static const String _campoUsuario = 'usuario';
  static const String _campoSenha = 'senha';
  static const String _campoSiglaOrgao = 'sigla_orgao';
  static const String _parametroErro = 'erro';

  /// `GET /login`: renderiza um formulário HTML autocontido (sem depender
  /// de engine de views nem de build do frontend) que envia usuário, senha
  /// e sigla do órgão para `POST /login`, preservando os parâmetros da
  /// requisição de autorização original na própria URL de ação do form.
  Future<void> mostrarPaginaLogin(
    RequestContext request,
    ResponseContext response,
  ) async {
    final Map<String, String> query =
        request.uri?.queryParameters ?? const <String, String>{};
    final String? mensagemErro = _mensagemDeErro(query[_parametroErro]);

    final AutenticacaoService servico = request.make<AutenticacaoService>();
    final List<OrgaoLoginResumo> orgaos = await servico.listarOrgaosAtivos();

    final String acao =
        Uri(path: '/login', queryParameters: query.isEmpty ? null : query)
            .toString();

    response.contentType =
        MediaType('text', 'html', <String, String>{'charset': 'utf-8'});
    response.write(
        _paginaHtml(acao: acao, orgaos: orgaos, mensagemErro: mensagemErro));
    await response.close();
  }

  /// `POST /login`: autentica com [AutenticacaoService.login] e, se bem
  /// sucedido, delega a `OidcController.emitirCodigoERedirecionar`. Em
  /// falha, redireciona de volta para a própria página de login com o
  /// mesmo contexto e um parâmetro `erro`.
  Future<void> autenticar(
    RequestContext request,
    ResponseContext response,
  ) async {
    final Map<String, String> query =
        request.uri?.queryParameters ?? const <String, String>{};

    await request.parseBody();
    final Map<String, dynamic> corpo = request.bodyAsMap;
    final String? usuario = _texto(corpo[_campoUsuario]);
    final String? senha = _texto(corpo[_campoSenha]);
    final String? siglaOrgao = _texto(corpo[_campoSiglaOrgao]);

    if (usuario == null || senha == null || siglaOrgao == null) {
      return _voltarComErro(response, query, 'campos_obrigatorios');
    }

    try {
      final AutenticacaoService autenticacaoService =
          request.make<AutenticacaoService>();
      final LoginResultado resultado = await autenticacaoService.login(
        usuario: usuario,
        senha: senha,
        siglaOrgao: siglaOrgao,
      );

      final OidcController oidcController = request.make<OidcController>();
      await oidcController.emitirCodigoERedirecionar(
        request,
        response,
        idUsuario: resultado.idUsuario,
        stateOriginal: query['state'],
      );
    } on AutenticacaoInvalidaException {
      await _voltarComErro(response, query, 'credenciais_invalidas');
    }
  }

  Future<void> _voltarComErro(
    ResponseContext response,
    Map<String, String> queryOriginal,
    String codigoErro,
  ) async {
    final Uri destino = Uri(
      path: '/login',
      queryParameters: <String, String>{
        ...queryOriginal,
        _parametroErro: codigoErro
      },
    );
    await response.redirect(destino, code: 302);
  }

  String? _texto(Object? valor) {
    if (valor is! String) {
      return null;
    }
    final String tratado = valor.trim();
    return tratado.isEmpty ? null : tratado;
  }

  String? _mensagemDeErro(String? codigo) {
    switch (codigo) {
      case null:
        return null;
      case 'credenciais_invalidas':
        return 'Usuário, senha ou órgão inválidos.';
      case 'campos_obrigatorios':
        return 'Preencha usuário, senha e órgão.';
      default:
        return 'Não foi possível efetuar o login.';
    }
  }

  String _paginaHtml({
    required String acao,
    required List<OrgaoLoginResumo> orgaos,
    String? mensagemErro,
  }) {
    final String opcoesOrgao = orgaos
        .map(
          (OrgaoLoginResumo orgao) =>
              '<option value="${_escapar(orgao.sigla)}">${_escapar(orgao.descricao)} (${_escapar(orgao.sigla)})</option>',
        )
        .join();

    final String blocoErro = mensagemErro == null
        ? ''
        : '<p class="erro" role="alert">${_escapar(mensagemErro)}</p>';

    return '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<title>Login — SEI</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body { font-family: sans-serif; background: #f2f2f2; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
  form { background: #fff; padding: 2rem; border-radius: 6px; box-shadow: 0 1px 4px rgba(0,0,0,.2); min-width: 20rem; }
  h1 { font-size: 1.25rem; margin-top: 0; }
  label { display: block; margin-top: 1rem; font-size: .875rem; }
  input, select { width: 100%; box-sizing: border-box; padding: .5rem; margin-top: .25rem; }
  button { margin-top: 1.5rem; width: 100%; padding: .6rem; background: #1a4d8f; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
  .erro { color: #b00020; font-size: .875rem; }
</style>
</head>
<body>
<form method="post" action="${_escapar(acao)}">
  <h1>Entrar no SEI</h1>
  $blocoErro
  <label for="usuario">Usuário</label>
  <input type="text" id="usuario" name="usuario" autocomplete="username" required>
  <label for="senha">Senha</label>
  <input type="password" id="senha" name="senha" autocomplete="current-password" required>
  <label for="sigla_orgao">Órgão</label>
  <select id="sigla_orgao" name="sigla_orgao" required>
    <option value="" disabled selected>Selecione o órgão</option>
    $opcoesOrgao
  </select>
  <button type="submit">Entrar</button>
</form>
</body>
</html>
''';
  }

  String _escapar(String valor) {
    return valor
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }
}
