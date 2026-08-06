import 'package:angel3_container/mirrors.dart';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_test/angel3_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

class _ConnectionMock extends Mock implements Connection {}

class _ServicoConexaoTeste implements ServicoConexao {
  _ServicoConexaoTeste(this.connection, {required this.usaPool});

  final Connection connection;

  @override
  final bool usaPool;

  int chamadasConectar = 0;

  @override
  Future<Connection> conectar() async {
    chamadasConectar++;
    return connection;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  group('MiddlewareConexaoBanco', () {
    test('encerra conexao sem pool ao finalizar requisicao', () async {
      final _ConnectionMock connection = _ConnectionMock();
      when(() => connection.disconnect()).thenAnswer((_) async {});
      final _ServicoConexaoTeste servico = _ServicoConexaoTeste(
        connection,
        usaPool: false,
      );

      final Angel app = _criarAplicacaoTeste(servico);
      final TestClient client = await connectTo(app, useZone: false);
      addTearDown(client.close);

      final http.Response resposta =
          await client.get(Uri.parse('/recurso-protegido'));

      expect(resposta.statusCode, 200);
      expect(servico.chamadasConectar, 1);
      verify(() => connection.disconnect()).called(1);
    });

    test('mantem conexao do pool aberta ao finalizar requisicao', () async {
      final _ConnectionMock connection = _ConnectionMock();
      final _ServicoConexaoTeste servico = _ServicoConexaoTeste(
        connection,
        usaPool: true,
      );

      final Angel app = _criarAplicacaoTeste(servico);
      final TestClient client = await connectTo(app, useZone: false);
      addTearDown(client.close);

      final http.Response resposta =
          await client.get(Uri.parse('/recurso-protegido'));

      expect(resposta.statusCode, 200);
      expect(servico.chamadasConectar, 1);
      verifyNever(() => connection.disconnect());
    });
  });
}

Angel _criarAplicacaoTeste(ServicoConexao servicoConexao) {
  final MiddlewareConexaoBanco middleware =
      MiddlewareConexaoBanco(servicoConexao);
  final Angel app = Angel(reflector: const MirrorsReflector());

  app.get(
    '/recurso-protegido',
    (RequestContext request, ResponseContext response) async {
      await response.json(<String, String>{'resultado': 'ok'});
    },
    middleware: [middleware.executar],
  );
  return app;
}
