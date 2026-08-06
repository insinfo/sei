import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sei_frontend/src/modules/catalogos/services/catalogos_service.dart';
import 'package:test/test.dart';

void main() {
  test('carrega catalogos do backend', () async {
    final MockClient cliente = MockClient((http.Request requisicao) async {
      switch (requisicao.url.path) {
        case '/api/v1/saude':
          return _resposta(<String, dynamic>{
            'status': 'disponivel',
            'modo': 'somente_leitura',
            'banco_dados': 'sei_5_0_0',
            'catalogos': _resumo(),
          });
        case '/api/v1/catalogos/resumo':
          return _resposta(_resumo());
        case '/api/v1/catalogos/tipos-procedimento':
          return _resposta(<Map<String, dynamic>>[_tipoProcedimento()]);
        case '/api/v1/catalogos/series':
          return _resposta(<Map<String, dynamic>>[_serie()]);
      }
      return http.Response('Não encontrado', 404);
    });
    final CatalogosService servico = CatalogosService(
      cliente: cliente,
      baseUri: Uri.parse('http://localhost:3350/api/v1'),
    );

    final PainelCatalogos painel = await servico.carregarPainel();

    expect(painel.status.bancoDados, 'sei_5_0_0');
    expect(painel.resumo.tiposProcedimento, 318);
    expect(painel.tiposProcedimento.single.nome, 'Processo de teste');
    expect(painel.series.single.nome, 'Documento de teste');
  });

  test('informa falha da API', () async {
    final CatalogosService servico = CatalogosService(
      cliente: MockClient(
        (http.Request _) async => http.Response('Indisponível', 503),
      ),
      baseUri: Uri.parse('http://localhost:3350/api/v1'),
    );

    expect(
      servico.buscarResumo,
      throwsA(isA<CatalogosApiException>()),
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

Map<String, dynamic> _resumo() {
  return <String, dynamic>{
    'tipos_procedimento': 318,
    'series': 254,
    'assuntos': 684,
    'hipoteses_legais': 23,
    'extensoes_arquivo': 41,
    'unidades': 3,
    'usuarios': 5,
  };
}

Map<String, dynamic> _tipoProcedimento() {
  return <String, dynamic>{
    'id_tipo_procedimento': 1,
    'id_hipotese_legal_sugestao': null,
    'nome': 'Processo de teste',
    'descricao': null,
    'sin_ativo': 'S',
    'sta_nivel_acesso_sugestao': '0',
    'sin_interno': 'N',
    'sin_ouvidoria': 'N',
    'sin_individual': 'N',
    'sta_grau_sigilo_sugestao': null,
    'id_plano_trabalho': null,
    'sin_ouvidoria_anonimo': 'N',
  };
}

Map<String, dynamic> _serie() {
  return <String, dynamic>{
    'id_serie': 1,
    'id_modelo_edoc': null,
    'id_grupo_serie': null,
    'id_modelo': null,
    'id_tipo_formulario': null,
    'nome': 'Documento de teste',
    'descricao': null,
    'sin_ativo': 'S',
    'sin_interessado': 'N',
    'sin_destinatario': 'N',
    'sta_numeracao': 'N',
    'sin_assinatura_publicacao': 'N',
    'sta_aplicabilidade': 'A',
    'sin_interno': 'N',
    'sin_usuario_externo': 'N',
    'sin_valor_monetario': 'N',
  };
}
