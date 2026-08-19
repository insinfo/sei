import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' show BytesBuilder;

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_framework/http.dart';
import 'package:angel3_mock_request/angel3_mock_request.dart';
import 'package:eloquent/eloquent.dart';

/// Assinatura de um método de controller Angel: `(request, response)`.
typedef HandlerOidc = Future<void> Function(
  RequestContext requisicao,
  ResponseContext resposta,
);

/// Harness que invoca controllers Angel diretamente — sem passar pelo
/// dispatch HTTP real (`AngelHttp`/`angel3_test`'s `TestClient`) — mantendo
/// toda a suíte de um teste na MESMA [Connection] de transação revertida.
///
/// Motivo de existir: `db_poolsize` faz `ServicoConexao.conectar()`
/// devolver conexões físicas diferentes em chamadas concorrentes/sucessivas
/// (comprovado experimentalmente). Uma requisição HTTP de verdade,
/// resolvendo sua própria conexão a partir do pool, não enxergaria os dados
/// da transação revertida usada como fixture pelo teste — e criar
/// usuário/órgão reais e comitados só para o teste violaria a regra do
/// projeto de nunca gravar dado sintético na Base de Referência (ver
/// `EscopoRepositorioTeste`). Este harness injeta a MESMA [Connection] no
/// contêiner de cada requisição simulada — exatamente o que
/// `MiddlewareConexaoSei` faz em produção, só que apontando sempre para a
/// conexão de transação do teste — então `authorize` → `login` → `token`
/// continuam na mesma transação de ponta a ponta.
///
/// Ainda assim exercita código real: os `RequestContext`/`ResponseContext`
/// são as classes de produção do Angel (`HttpRequestContext`/
/// `HttpResponseContext`), a árvore de dependências é resolvida pelo
/// mesmo `Container`, e toda query roda contra o PostgreSQL de verdade.
/// Só o transporte HTTP (socket/roteador) não é exercitado.
class OidcTestHarness {
  OidcTestHarness(this.app, this.conexao);

  final Angel app;
  final Connection conexao;

  /// Sessão simulada, preservada entre chamadas — mesma técnica que
  /// `angel3_test`'s `TestClient` usa para propagar sessão entre
  /// requisições mockadas distintas (copia os pares chave/valor).
  final Map<dynamic, dynamic> _sessao = <dynamic, dynamic>{};

  Future<(HttpRequestContext, MockHttpRequest)> _criarRequisicao(
    String metodo,
    Uri uri, {
    Map<String, String>? headers,
    List<int>? corpo,
    ContentType? contentType,
  }) async {
    final MockHttpRequest mockRequest = MockHttpRequest(metodo, uri);
    mockRequest.session.addAll(_sessao);

    if (contentType != null) {
      mockRequest.headers.contentType = contentType;
    }
    headers?.forEach(mockRequest.headers.set);

    if (corpo != null) {
      mockRequest.add(corpo);
    }
    await mockRequest.close();

    final HttpRequestContext requisicao =
        await HttpRequestContext.from(mockRequest, app, uri.path);
    requisicao.container!.registerSingleton<Connection>(conexao);
    return (requisicao, mockRequest);
  }

  HttpResponseContext _criarResposta(
    HttpRequestContext requisicao,
    MockHttpRequest mockRequest,
  ) {
    final HttpResponseContext resposta = HttpResponseContext(
      mockRequest.response,
      app,
      requisicao,
    );
    resposta.serializer = app.serializer ?? json.encode;
    resposta.encoders.addAll(app.encoders);
    return resposta;
  }

  Future<HttpResponseContext> _executar(
    String metodo,
    Uri uri,
    HandlerOidc handler, {
    Map<String, String>? headers,
    List<int>? corpo,
    ContentType? contentType,
  }) async {
    final (HttpRequestContext requisicao, MockHttpRequest mockRequest) =
        await _criarRequisicao(
      metodo,
      uri,
      headers: headers,
      corpo: corpo,
      contentType: contentType,
    );
    final HttpResponseContext resposta =
        _criarResposta(requisicao, mockRequest);

    await handler(requisicao, resposta);

    _sessao.clear();
    mockRequest.session.forEach((dynamic chave, dynamic valor) {
      _sessao[chave] = valor;
    });

    return resposta;
  }

  /// Chamada GET simulada contra [caminhoComQuery] (path + query string).
  Future<HttpResponseContext> get(
    String caminhoComQuery,
    HandlerOidc handler, {
    Map<String, String>? headers,
  }) {
    return _executar('GET', Uri.parse(caminhoComQuery), handler,
        headers: headers);
  }

  /// Chamada POST simulada com corpo `application/x-www-form-urlencoded`.
  Future<HttpResponseContext> postForm(
    String caminhoComQuery,
    Map<String, String> campos,
    HandlerOidc handler, {
    Map<String, String>? headers,
  }) {
    final List<int> corpo = utf8.encode(Uri(queryParameters: campos).query);
    return _executar(
      'POST',
      Uri.parse(caminhoComQuery),
      handler,
      headers: headers,
      corpo: corpo,
      contentType: ContentType('application', 'x-www-form-urlencoded'),
    );
  }

  /// Chamada POST simulada com corpo `application/json`.
  Future<HttpResponseContext> postJson(
    String caminhoComQuery,
    Map<String, dynamic> corpoJson,
    HandlerOidc handler, {
    Map<String, String>? headers,
  }) {
    final List<int> corpo = utf8.encode(json.encode(corpoJson));
    return _executar(
      'POST',
      Uri.parse(caminhoComQuery),
      handler,
      headers: headers,
      corpo: corpo,
      contentType: ContentType('application', 'json'),
    );
  }

  /// Lê o corpo de [resposta].
  ///
  /// `ResponseContext` só escreve em `.buffer` quando `useBuffer()` foi
  /// chamado explicitamente (nenhum controller deste projeto chama) — o
  /// caminho padrão (`write`/`close`, usado por `response.json`/
  /// `response.redirect`) escreve direto no `rawResponse` (aqui, um
  /// `MockHttpResponse`, que também é um `Stream<List<int>>`). Por isso a
  /// leitura é feita ali, não em `.buffer`.
  static Future<String> corpoTexto(HttpResponseContext resposta) async {
    final MockHttpResponse mockResponse =
        resposta.rawResponse as MockHttpResponse;
    final List<List<int>> partes = await mockResponse.toList();
    final BytesBuilder bytes = BytesBuilder();
    for (final List<int> parte in partes) {
      bytes.add(parte);
    }
    return utf8.decode(bytes.takeBytes());
  }

  static Future<Map<String, dynamic>> corpoJsonDe(
      HttpResponseContext resposta) async {
    return json.decode(await corpoTexto(resposta)) as Map<String, dynamic>;
  }
}
