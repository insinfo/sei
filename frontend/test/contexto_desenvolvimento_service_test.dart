import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sei_frontend/src/modules/contexto_desenvolvimento/services/contexto_desenvolvimento_service.dart';
import 'package:test/test.dart';

void main() {
  test('carrega contexto de desenvolvimento', () async {
    final MockClient cliente = MockClient((http.Request requisicao) async {
      expect(requisicao.url.path, '/api/v1/contexto/desenvolvimento');
      return _resposta(_contexto());
    });
    final ContextoDesenvolvimentoService servico =
        ContextoDesenvolvimentoService(
      cliente: cliente,
      baseUri: Uri.parse('http://localhost:3350/api/v1'),
    );

    final contexto = await servico.buscar();

    expect(contexto.idUsuario, 1);
    expect(contexto.nomeUsuario, 'Usuário de desenvolvimento');
    expect(contexto.idUnidadeInicial, 10);
    expect(contexto.unidades, hasLength(2));
    expect(contexto.unidades.last.sigla, 'ARQ');
  });

  test('informa resposta indisponivel do contexto', () async {
    final ContextoDesenvolvimentoService servico =
        ContextoDesenvolvimentoService(
      cliente: MockClient(
        (http.Request _) async => http.Response('Indisponível', 503),
      ),
      baseUri: Uri.parse('http://localhost:3350/api/v1'),
    );

    expect(
      servico.buscar,
      throwsA(isA<ContextoDesenvolvimentoApiException>()),
    );
  });
}

http.Response _resposta(Object corpo) {
  return http.Response(
    jsonEncode(corpo),
    200,
    headers: const <String, String>{'content-type': 'application/json'},
  );
}

Map<String, dynamic> _contexto() {
  return <String, dynamic>{
    'id_usuario': 1,
    'id_orgao': 1,
    'sigla_usuario': 'desenvolvedor',
    'nome_usuario': 'Usuário de desenvolvimento',
    'id_unidade_inicial': 10,
    'unidades': <Map<String, dynamic>>[
      <String, dynamic>{
        'id_unidade': 10,
        'id_orgao': 1,
        'sigla': 'DGD',
        'descricao': 'Diretoria de Gestão Documental',
        'sin_ativo': 'S',
      },
      <String, dynamic>{
        'id_unidade': 11,
        'id_orgao': 1,
        'sigla': 'ARQ',
        'descricao': 'Arquivo Geral',
        'sin_ativo': 'N',
      },
    ],
  };
}
