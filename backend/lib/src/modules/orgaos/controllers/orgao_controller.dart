import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/orgaos/repositories/orgao_repository.dart';
import 'package:sei_backend/src/modules/orgaos/services/orgao_service.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/parametros_http.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe o cadastro de órgão: listagem paginada, detalhe, criação e
/// atualização cadastral.
///
/// O órgão é sempre criado sem unidade raiz (ver Dartdoc de
/// `OrgaoService`); vincular uma unidade raiz é operação futura.
class OrgaoController {
  static const String idOrgaoParam = 'idOrgao';

  Future<void> listar(RequestContext request, ResponseContext response) async {
    try {
      final OrgaoFiltro filtro = OrgaoFiltro.fromMap(request.queryParameters);
      final OrgaoRepository repositorio = request.make<OrgaoRepository>();
      final PaginaOrgaos pagina = await repositorio.listar(filtro);
      await response.json(pagina.toMap());
    } on FormatException catch (erro) {
      await _responderInvalido(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderInvalido(response, erro.message.toString());
    }
  }

  Future<void> detalhe(RequestContext request, ResponseContext response) async {
    try {
      final int idOrgao = ParametrosHttp.identificadorPositivo(
        request.params[idOrgaoParam],
        nomeCampo: idOrgaoParam,
      );
      final OrgaoRepository repositorio = request.make<OrgaoRepository>();
      final Orgao? orgao = await repositorio.buscarPorId(idOrgao);
      if (orgao == null) {
        await _responderNaoEncontrado(response);
        return;
      }
      await response.json(orgao.toMap());
    } on FormatException catch (erro) {
      await _responderInvalido(response, erro.message);
    }
  }

  Future<void> criar(RequestContext request, ResponseContext response) async {
    await request.parseBody();
    final Map<String, dynamic> corpo = request.bodyAsMap;

    try {
      final String sigla = _textoObrigatorio(corpo, 'sigla');
      final String descricao = _textoObrigatorio(corpo, 'descricao');
      final bool ativo = corpo['ativo'] as bool? ?? true;
      final String? codigoSei = (corpo['codigo_sei'] as String?)?.trim();

      final OrgaoService servico = request.make<OrgaoService>();
      final Orgao orgao = await servico.criar(
        sigla: sigla,
        descricao: descricao,
        ativo: ativo,
        codigoSei: codigoSei == null || codigoSei.isEmpty ? null : codigoSei,
      );

      response.statusCode = 201;
      await response.json(orgao.toMap());
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
      final int idOrgao = ParametrosHttp.identificadorPositivo(
        request.params[idOrgaoParam],
        nomeCampo: idOrgaoParam,
      );
      final String sigla = _textoObrigatorio(corpo, 'sigla');
      final String descricao = _textoObrigatorio(corpo, 'descricao');
      final bool ativo = corpo['ativo'] as bool? ?? true;

      final OrgaoService servico = request.make<OrgaoService>();
      await servico.atualizarDadosCadastrais(
        idOrgao: idOrgao,
        sigla: sigla,
        descricao: descricao,
        ativo: ativo,
      );

      final OrgaoRepository repositorio = request.make<OrgaoRepository>();
      final Orgao? orgao = await repositorio.buscarPorId(idOrgao);
      if (orgao == null) {
        await _responderNaoEncontrado(response);
        return;
      }
      await response.json(orgao.toMap());
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
      mensagem: 'Órgão não encontrado.',
    );
  }
}
