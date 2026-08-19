import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/usuarios/repositories/usuario_repository.dart';
import 'package:sei_backend/src/modules/usuarios/services/usuario_service.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/parametros_http.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe o cadastro de usuário: listagem paginada, detalhe, criação,
/// atualização cadastral e troca de senha.
///
/// A senha nunca é serializada de volta: [Usuario.toMap] já a omite (ver
/// Dartdoc do model), então nenhuma rota daqui precisa filtrá-la à mão.
class UsuarioController {
  static const String idUsuarioParam = 'idUsuario';

  Future<void> listar(RequestContext request, ResponseContext response) async {
    try {
      final UsuarioFiltro filtro = UsuarioFiltro.fromMap(
        request.queryParameters,
      );
      final UsuarioRepository repositorio = request.make<UsuarioRepository>();
      final PaginaUsuarios pagina = await repositorio.listar(filtro);
      await response.json(pagina.toMap());
    } on FormatException catch (erro) {
      await _responderInvalido(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderInvalido(response, erro.message.toString());
    }
  }

  Future<void> detalhe(RequestContext request, ResponseContext response) async {
    try {
      final int idUsuario = ParametrosHttp.identificadorPositivo(
        request.params[idUsuarioParam],
        nomeCampo: idUsuarioParam,
      );
      final UsuarioRepository repositorio = request.make<UsuarioRepository>();
      final Usuario? usuario = await repositorio.buscarPorId(idUsuario);
      if (usuario == null) {
        await _responderNaoEncontrado(response);
        return;
      }
      await response.json(usuario.toMap());
    } on FormatException catch (erro) {
      await _responderInvalido(response, erro.message);
    }
  }

  Future<void> criar(RequestContext request, ResponseContext response) async {
    await request.parseBody();
    final Map<String, dynamic> corpo = request.bodyAsMap;

    try {
      final int idOrgao = ParametrosHttp.identificadorPositivo(
        corpo['id_orgao'],
        nomeCampo: 'id_orgao',
      );
      final String sigla = _textoObrigatorio(corpo, 'sigla');
      final String nome = _textoObrigatorio(corpo, 'nome');
      final String senha = _textoObrigatorio(corpo, 'senha');
      final bool ativo = corpo['ativo'] as bool? ?? true;

      final UsuarioService servico = request.make<UsuarioService>();
      final Usuario usuario = await servico.criar(
        idOrgao: idOrgao,
        sigla: sigla,
        nome: nome,
        senha: senha,
        ativo: ativo,
      );

      response.statusCode = 201;
      await response.json(usuario.toMap());
    } on FormatException catch (erro) {
      await _responderInvalido(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderInvalido(response, erro.message.toString());
    }
  }

  Future<void> atualizar(
    RequestContext request,
    ResponseContext response,
  ) async {
    await request.parseBody();
    final Map<String, dynamic> corpo = request.bodyAsMap;

    try {
      final int idUsuario = ParametrosHttp.identificadorPositivo(
        request.params[idUsuarioParam],
        nomeCampo: idUsuarioParam,
      );
      final String sigla = _textoObrigatorio(corpo, 'sigla');
      final String nome = _textoObrigatorio(corpo, 'nome');
      final bool ativo = corpo['ativo'] as bool? ?? true;

      final UsuarioService servico = request.make<UsuarioService>();
      await servico.atualizarDadosCadastrais(
        idUsuario: idUsuario,
        sigla: sigla,
        nome: nome,
        ativo: ativo,
      );

      final UsuarioRepository repositorio = request.make<UsuarioRepository>();
      final Usuario? usuario = await repositorio.buscarPorId(idUsuario);
      if (usuario == null) {
        await _responderNaoEncontrado(response);
        return;
      }
      await response.json(usuario.toMap());
    } on FormatException catch (erro) {
      await _responderInvalido(response, erro.message);
    }
  }

  Future<void> trocarSenha(
    RequestContext request,
    ResponseContext response,
  ) async {
    await request.parseBody();
    final Map<String, dynamic> corpo = request.bodyAsMap;

    try {
      final int idUsuario = ParametrosHttp.identificadorPositivo(
        request.params[idUsuarioParam],
        nomeCampo: idUsuarioParam,
      );
      final String senhaNova = _textoObrigatorio(corpo, 'senha_nova');

      final UsuarioService servico = request.make<UsuarioService>();
      await servico.trocarSenha(idUsuario: idUsuario, senhaNova: senhaNova);

      response.statusCode = 204;
      await response.close();
    } on FormatException catch (erro) {
      await _responderInvalido(response, erro.message);
    }
  }

  String _textoObrigatorio(Map<String, dynamic> corpo, String campo) {
    final Object? valor = corpo[campo];
    if (valor is! String || valor.trim().isEmpty) {
      throw FormatException('O campo $campo é obrigatório.');
    }
    return valor.trim();
  }

  Future<void> _responderInvalido(
    ResponseContext response,
    String mensagem,
  ) async {
    await RespostaApiHttp.responderErro(
      response,
      codigoHttp: 400,
      mensagem: mensagem,
    );
  }

  Future<void> _responderNaoEncontrado(ResponseContext response) async {
    await RespostaApiHttp.responderErro(
      response,
      codigoHttp: 404,
      mensagem: 'Usuário não encontrado.',
    );
  }
}
