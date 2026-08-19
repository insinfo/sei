import 'dart:convert';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_test/angel3_test.dart';
import 'package:http/http.dart' as http;
import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

void main() {
  group('cors e injecao de dependencias', () {
    late Angel app;
    late TestClient client;

    setUpAll(() async {
      app = criarAplicacao(SeiAppConfig.carregar());
      client = await connectTo(app);
    });

    tearDownAll(() async {
      final hooks = List<AngelConfigurer>.from(app.shutdownHooks);
      for (final AngelConfigurer hook in hooks) {
        await hook(app);
      }
      await client.close();
    });

    test('preflight cors encerra sem abrir conexao', () async {
      final http.Request requisicao = http.Request(
        'OPTIONS',
        Uri.parse('/api/v1/catalogos/series'),
      );
      final http.StreamedResponse respostaTransmitida =
          await client.send(requisicao);
      final http.Response resposta =
          await http.Response.fromStream(respostaTransmitida);

      expect(resposta.statusCode, 204);
      expect(resposta.body, isEmpty);
      expect(resposta.headers['access-control-allow-origin'], '*');
      expect(
        resposta.headers['access-control-allow-methods'],
        contains('OPTIONS'),
      );
    });

    test('catalogos usam repository resolvido pelo request', () async {
      final http.Response resposta =
          await client.get(Uri.parse('/api/v1/catalogos/series'));
      final Object? corpoDecodificado = jsonDecode(resposta.body);
      final List<dynamic> series = corpoDecodificado as List<dynamic>;

      expect(resposta.statusCode, 200);
      expect(resposta.headers['access-control-allow-origin'], '*');
      expect(series, isNotEmpty);
      expect(series.first, isA<Map<String, dynamic>>());
    });

    test('sip usa conexao e repository proprios da requisicao', () async {
      final http.Response resposta =
          await client.get(Uri.parse('/api/v1/sip/referencia/sistemas'));
      final Object? corpoDecodificado = jsonDecode(resposta.body);
      final List<dynamic> sistemas = corpoDecodificado as List<dynamic>;

      expect(resposta.statusCode, 200);
      expect(resposta.headers['access-control-allow-origin'], '*');
      expect(sistemas, hasLength(2));
    });

    test('rota de autorizacao sip resolve perfis e recursos pelo http',
        () async {
      final http.Response resposta = await client.get(
        Uri.parse(
          '/api/v1/sip/usuarios/100000001/autorizacao?idUnidade=110000000',
        ),
      );
      final Map<String, dynamic> corpo =
          jsonDecode(resposta.body) as Map<String, dynamic>;

      expect(resposta.statusCode, 200);
      expect(corpo['id_usuario'], 100000001);
      expect(corpo['id_unidade'], 110000000);
      expect(corpo['perfis'], hasLength(8));
      expect(corpo['recursos'], hasLength(1544));
    });

    test('rota de autorizacao sip exige idUnidade e responde 400 sem ela',
        () async {
      final http.Response resposta = await client.get(
        Uri.parse('/api/v1/sip/usuarios/100000001/autorizacao'),
      );

      expect(resposta.statusCode, 400);
    });
  });
}
