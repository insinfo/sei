import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/unidades/repositories/unidade_repository.dart';
import 'package:sei_backend/src/modules/unidades/services/unidade_service.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/parametros_http.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe o cadastro de unidade: listagem paginada, detalhe, criação e
/// atualização cadastral.
class UnidadeController {
  static const String idUnidadeParam = 'idUnidade';

  Future<void> listar(RequestContext request, ResponseContext response) async {
    try {
      final UnidadeFiltro filtro = UnidadeFiltro.fromMap(
        request.queryParameters,
      );
      final UnidadeRepository repositorio = request.make<UnidadeRepository>();
      final PaginaUnidades pagina = await repositorio.listar(filtro);
      await response.json(pagina.toMap());
    } on FormatException catch (erro) {
      await _responderInvalido(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderInvalido(response, erro.message.toString());
    }
  }

  Future<void> detalhe(RequestContext request, ResponseContext response) async {
    try {
      final int idUnidade = ParametrosHttp.identificadorPositivo(
        request.params[idUnidadeParam],
        nomeCampo: idUnidadeParam,
      );
      final UnidadeRepository repositorio = request.make<UnidadeRepository>();
      final Unidade? unidade = await repositorio.buscarPorId(idUnidade);
      if (unidade == null) {
        await _responderNaoEncontrado(response);
        return;
      }
      await response.json(unidade.toMap());
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
      final String descricao = _textoObrigatorio(corpo, 'descricao');
      final bool ativo = corpo['ativo'] as bool? ?? true;

      final UnidadeService servico = request.make<UnidadeService>();
      final Unidade unidade = await servico.criar(
        idOrgao: idOrgao,
        sigla: sigla,
        descricao: descricao,
        ativo: ativo,
      );

      response.statusCode = 201;
      await response.json(unidade.toMap());
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
      final int idUnidade = ParametrosHttp.identificadorPositivo(
        request.params[idUnidadeParam],
        nomeCampo: idUnidadeParam,
      );
      final String sigla = _textoObrigatorio(corpo, 'sigla');
      final String descricao = _textoObrigatorio(corpo, 'descricao');
      final bool ativo = corpo['ativo'] as bool? ?? true;

      final UnidadeService servico = request.make<UnidadeService>();
      await servico.atualizarDadosCadastrais(
        idUnidade: idUnidade,
        sigla: sigla,
        descricao: descricao,
        ativo: ativo,
      );

      final UnidadeRepository repositorio = request.make<UnidadeRepository>();
      final Unidade? unidade = await repositorio.buscarPorId(idUnidade);
      if (unidade == null) {
        await _responderNaoEncontrado(response);
        return;
      }
      await response.json(unidade.toMap());
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
      mensagem: 'Unidade não encontrada.',
    );
  }
}
