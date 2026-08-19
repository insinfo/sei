import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/processos/repositories/processo_detalhe_repository.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/parametros_http.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe leituras paginadas do detalhe de processo para a interface SEI.
class ProcessoDetalheController {
  static const String idProcessoParam = 'idProcesso';
  static const String idDocumentoParam = 'idDocumento';
  static const String _idUnidadeParam = 'idUnidade';

  Future<void> cabecalho(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final repositorio = request.make<ProcessoDetalheRepository>();
      final processo = await repositorio.obterCabecalho(idProcesso);
      if (processo == null) {
        await _responderProcessoNaoEncontrado(response);
        return;
      }
      await response.json(processo.toMap());
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> documentos(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final ProcessoDetalhePaginacao paginacao =
          ProcessoDetalhePaginacao.fromMap(
        request.queryParameters,
      );
      final ProcessoDetalheRepository repositorio =
          request.make<ProcessoDetalheRepository>();
      final PaginaProcessoArvoreDocumentos pagina =
          await repositorio.listarDocumentos(idProcesso, paginacao);
      await response.json(pagina.toMap());
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> andamentos(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final ProcessoDetalhePaginacao paginacao =
          ProcessoDetalhePaginacao.fromMap(
        request.queryParameters,
      );
      final ProcessoDetalheRepository repositorio =
          request.make<ProcessoDetalheRepository>();
      final PaginaProcessoAndamentos pagina =
          await repositorio.listarAndamentos(idProcesso, paginacao);
      await response.json(pagina.toMap());
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> unidadesAbertas(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final ProcessoDetalheRepository repositorio =
          request.make<ProcessoDetalheRepository>();
      final List<ProcessoUnidadeAberta> unidades =
          await repositorio.listarUnidadesAbertas(idProcesso);
      await RespostaApiHttp.responderLista(response, unidades);
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> relacionados(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final ProcessoDetalheRepository repositorio =
          request.make<ProcessoDetalheRepository>();
      final List<ProcessoRelacionado> relacionados =
          await repositorio.listarRelacionados(idProcesso);
      await RespostaApiHttp.responderLista(response, relacionados);
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> participantes(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final ProcessoDetalheRepository repositorio =
          request.make<ProcessoDetalheRepository>();
      final List<ProcessoParticipante> participantes =
          await repositorio.listarParticipantes(idProcesso);
      await RespostaApiHttp.responderLista(response, participantes);
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> anotacoes(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final int idUnidade = _lerIdUnidade(request);
      final ProcessoDetalheRepository repositorio =
          request.make<ProcessoDetalheRepository>();
      final List<ProcessoAnotacao> anotacoes =
          await repositorio.listarAnotacoes(idProcesso, idUnidade);
      await RespostaApiHttp.responderLista(response, anotacoes);
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> marcadores(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final ProcessoDetalheRepository repositorio =
          request.make<ProcessoDetalheRepository>();
      final List<ProcessoMarcador> marcadores =
          await repositorio.listarMarcadores(idProcesso);
      await RespostaApiHttp.responderLista(response, marcadores);
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> acompanhamentos(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final ProcessoDetalheRepository repositorio =
          request.make<ProcessoDetalheRepository>();
      final List<ProcessoAcompanhamento> acompanhamentos =
          await repositorio.listarAcompanhamentos(idProcesso);
      await RespostaApiHttp.responderLista(response, acompanhamentos);
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> controlesPrazo(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final int idUnidade = _lerIdUnidade(request);
      final ProcessoDetalheRepository repositorio =
          request.make<ProcessoDetalheRepository>();
      final List<ProcessoControlePrazo> controles =
          await repositorio.listarControlesPrazo(idProcesso, idUnidade);
      await RespostaApiHttp.responderLista(response, controles);
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> retornosProgramados(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final ProcessoDetalheRepository repositorio =
          request.make<ProcessoDetalheRepository>();
      final List<ProcessoRetornoProgramado> retornos =
          await repositorio.listarRetornosProgramados(idProcesso);
      await RespostaApiHttp.responderLista(response, retornos);
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  Future<void> conteudoDocumento(
    RequestContext request,
    ResponseContext response,
  ) async {
    try {
      final int idProcesso = _lerIdProcesso(request);
      final int idDocumento = ParametrosHttp.identificadorPositivo(
        request.params[idDocumentoParam],
        nomeCampo: idDocumentoParam,
      );
      final ProcessoDetalheRepository repositorio =
          request.make<ProcessoDetalheRepository>();
      final ProcessoDocumentoConteudo? conteudo =
          await repositorio.obterConteudoDocumento(idProcesso, idDocumento);
      if (conteudo == null) {
        await _responderDocumentoNaoEncontrado(response);
        return;
      }
      await response.json(conteudo.toMap());
    } on FormatException catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message);
    } on ArgumentError catch (erro) {
      await _responderRequisicaoInvalida(response, erro.message.toString());
    }
  }

  int _lerIdProcesso(RequestContext request) {
    return ParametrosHttp.identificadorPositivo(
      request.params[idProcessoParam],
      nomeCampo: idProcessoParam,
    );
  }

  int _lerIdUnidade(RequestContext request) {
    return ParametrosHttp.identificadorPositivo(
      request.queryParameters[_idUnidadeParam],
      nomeCampo: _idUnidadeParam,
    );
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

  Future<void> _responderProcessoNaoEncontrado(
    ResponseContext response,
  ) async {
    await RespostaApiHttp.responderErro(
      response,
      codigoHttp: 404,
      mensagem: 'Processo não encontrado.',
    );
  }

  Future<void> _responderDocumentoNaoEncontrado(
    ResponseContext response,
  ) async {
    await RespostaApiHttp.responderErro(
      response,
      codigoHttp: 404,
      mensagem: 'Documento não encontrado.',
    );
  }
}
