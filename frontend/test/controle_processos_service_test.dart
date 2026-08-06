import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sei_frontend/src/modules/controle_processos/services/controle_processos_service.dart';
import 'package:test/test.dart';

const int _idUnidadeReferencia = 110000001;

void main() {
  test('carrega pagina de atividades recebidas', () async {
    final MockClient cliente = MockClient((http.Request requisicao) async {
      expect(requisicao.url.path, '/api/v1/controle-processos/recebidos');
      expect(
        requisicao.url.queryParameters['id_unidade'],
        _idUnidadeReferencia.toString(),
      );
      expect(requisicao.url.queryParameters['limite'], '50');
      return _resposta(<String, dynamic>{
        'itens': <Map<String, dynamic>>[_item()],
        'total': 1,
        'limite': 50,
        'deslocamento': 0,
      });
    });
    final ControleProcessosService servico = ControleProcessosService(
      cliente: cliente,
      baseUri: Uri.parse('http://localhost:3350/api/v1'),
    );

    final pagina = await servico.listarRecebidos(
      idUnidade: _idUnidadeReferencia,
      limite: 50,
    );

    expect(pagina.total, 1);
    expect(pagina.itens.single.protocoloFormatado, '00001.000001/2026-00');
  });

  test('carrega pagina de processos gerados', () async {
    final MockClient cliente = MockClient((http.Request requisicao) async {
      expect(requisicao.url.path, '/api/v1/controle-processos/gerados');
      expect(
        requisicao.url.queryParameters['id_unidade'],
        _idUnidadeReferencia.toString(),
      );
      expect(requisicao.url.queryParameters['limite'], '50');
      return _resposta(<String, dynamic>{
        'itens': <Map<String, dynamic>>[
          _item(atividadeInicial: 'S'),
        ],
        'total': 1,
        'limite': 50,
        'deslocamento': 0,
      });
    });
    final ControleProcessosService servico = ControleProcessosService(
      cliente: cliente,
      baseUri: Uri.parse('http://localhost:3350/api/v1'),
    );

    final pagina = await servico.listarGerados(
      idUnidade: _idUnidadeReferencia,
      limite: 50,
    );

    expect(pagina.total, 1);
    expect(pagina.itens.single.atividadeInicial, isTrue);
  });

  test('envia o deslocamento da pagina solicitada', () async {
    final MockClient cliente = MockClient((http.Request requisicao) async {
      expect(requisicao.url.path, '/api/v1/controle-processos/recebidos');
      expect(requisicao.url.queryParameters['deslocamento'], '50');
      return _resposta(<String, dynamic>{
        'itens': <Map<String, dynamic>>[],
        'total': 75,
        'limite': 50,
        'deslocamento': 50,
      });
    });
    final ControleProcessosService servico = ControleProcessosService(
      cliente: cliente,
      baseUri: Uri.parse('http://localhost:3350/api/v1'),
    );

    final pagina = await servico.listarRecebidos(
      idUnidade: _idUnidadeReferencia,
      deslocamento: 50,
    );

    expect(pagina.deslocamento, 50);
    expect(pagina.total, 75);
  });

  test('informa resposta indisponivel', () async {
    final ControleProcessosService servico = ControleProcessosService(
      cliente: MockClient(
        (http.Request _) async => http.Response('Indisponível', 503),
      ),
      baseUri: Uri.parse('http://localhost:3350/api/v1'),
    );

    expect(
      () => servico.listarRecebidos(idUnidade: _idUnidadeReferencia),
      throwsA(isA<ControleProcessosApiException>()),
    );
  });

  test('preserva pagina vazia da unidade', () async {
    final ControleProcessosService servico = ControleProcessosService(
      cliente: MockClient(
        (http.Request _) async => _resposta(<String, dynamic>{
          'itens': <Map<String, dynamic>>[],
          'total': 0,
          'limite': 50,
          'deslocamento': 0,
        }),
      ),
      baseUri: Uri.parse('http://localhost:3350/api/v1'),
    );

    final pagina = await servico.listarRecebidos(
      idUnidade: _idUnidadeReferencia,
    );

    expect(pagina.itens, isEmpty);
    expect(pagina.total, 0);
  });
}

http.Response _resposta(Object corpo) {
  return http.Response(
    jsonEncode(corpo),
    200,
    headers: const <String, String>{'content-type': 'application/json'},
  );
}

Map<String, dynamic> _item({String atividadeInicial = 'N'}) {
  return <String, dynamic>{
    'id_atividade': 1,
    'id_processo': '1',
    'protocolo_formatado': '00001.000001/2026-00',
    'descricao': 'Processo de demonstração',
    'estado_protocolo': 'A',
    'id_tipo_procedimento': 1,
    'tipo_procedimento_nome': 'Processo de teste',
    'id_unidade': _idUnidadeReferencia,
    'unidade_sigla': 'TESTE',
    'unidade_descricao': 'Unidade de Teste 1',
    'id_unidade_origem': 110000002,
    'unidade_origem_sigla': 'TESTE_1_1',
    'unidade_origem_descricao': 'Unidade de Testes 1.1',
    'id_tarefa': 99,
    'tarefa_nome': 'Tarefa de teste',
    'id_usuario_atribuicao': 1,
    'usuario_atribuicao_nome': 'Usuário de teste',
    'id_usuario_atividade': 2,
    'usuario_atividade_nome': 'Usuário de origem',
    'data_abertura': '2026-08-05T10:00:00',
    'data_prazo': null,
    'atividade_inicial': atividadeInicial,
    'tipo_visualizacao': 0,
  };
}
