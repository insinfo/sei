import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/modules/processos/repositories/processo_detalhe_repository.dart';
import 'package:sei_backend/src/shared/utils/extensoes_contexto_requisicao.dart';
import 'package:sei_backend/src/shared/utils/parametros_http.dart';
import 'package:sei_backend/src/shared/utils/resposta_api_http.dart';
import 'package:sei_core/sei_core.dart';

/// Expõe leituras paginadas do detalhe de processo para a interface SEI.
class ProcessoDetalheController {
  static const String idProcessoParam = 'idProcesso';

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

  int _lerIdProcesso(RequestContext request) {
    return ParametrosHttp.identificadorPositivo(
      request.params[idProcessoParam],
      nomeCampo: idProcessoParam,
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
}
