import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';
import 'package:test/test.dart';

void main() {
  test('carrega cabecalho com identificador codificado', () async {
    const String idProcesso = '123/ 456?';
    final MockClient cliente = MockClient((http.Request requisicao) async {
      expect(
        requisicao.url.toString(),
        contains('processos/123%2F%20456%3F/cabecalho'),
      );
      return _resposta(_cabecalho('123456'));
    });
    final ProcessoDetalheService servico = _criarServico(cliente);

    final ProcessoCabecalho cabecalho = await servico.obterCabecalho(
      idProcesso,
    );

    expect(cabecalho.idProcesso, '123456');
    expect(cabecalho.protocoloFormatado, '00001.000001/2026-00');
  });

  test('carrega paginas de documentos e andamentos', () async {
    const String idProcesso = '100000001';
    final MockClient cliente = MockClient((http.Request requisicao) async {
      switch (requisicao.url.path) {
        case '/api/v1/processos/$idProcesso/documentos':
          expect(requisicao.url.queryParameters['limite'], '20');
          expect(requisicao.url.queryParameters['cursor'], 'proxima pagina');
          return _resposta(_documentos());
        case '/api/v1/processos/$idProcesso/andamentos':
          expect(requisicao.url.queryParameters['limite'], '50');
          expect(requisicao.url.queryParameters['cursor'], isNull);
          return _resposta(_andamentos(idProcesso));
      }
      return http.Response('Não encontrado', 404);
    });
    final ProcessoDetalheService servico = _criarServico(cliente);

    final PaginaProcessoArvoreDocumentos documentos =
        await servico.listarDocumentos(
      idProcesso,
      cursor: 'proxima pagina',
      limite: 20,
    );
    final PaginaProcessoAndamentos andamentos =
        await servico.listarAndamentos(idProcesso);

    expect(documentos.itens.single.nomeArvore, 'Despacho de teste');
    expect(documentos.proximoCursor, '20:1001');
    expect(andamentos.itens.single.atributos.single.nome, 'Motivo');
    expect(andamentos.itens.single.idProcesso, idProcesso);
  });

  test('informa resposta 404', () async {
    final ProcessoDetalheService servico = _criarServico(
      MockClient(
          (http.Request _) async => http.Response('Não encontrado', 404)),
    );

    expect(
      () => servico.obterCabecalho('100000001'),
      throwsA(
        isA<ProcessoDetalheApiException>().having(
          (ProcessoDetalheApiException erro) => erro.mensagem,
          'mensagem',
          contains('404'),
        ),
      ),
    );
  });

  test('informa contrato invalido', () async {
    final ProcessoDetalheService servico = _criarServico(
      MockClient(
        (http.Request _) async => _resposta(<String, dynamic>{
          PaginaProcessoArvoreDocumentos.itensCol: 'não é uma lista',
        }),
      ),
    );

    expect(
      () => servico.listarDocumentos('100000001'),
      throwsA(
        isA<ProcessoDetalheApiException>().having(
          (ProcessoDetalheApiException erro) => erro.mensagem,
          'mensagem',
          contains('contrato inválido'),
        ),
      ),
    );
  });
}

ProcessoDetalheService _criarServico(http.Client cliente) {
  return ProcessoDetalheService(
    cliente: cliente,
    baseUri: Uri.parse('http://localhost:3350/api/v1'),
  );
}

http.Response _resposta(Object corpo) {
  return http.Response(
    jsonEncode(corpo),
    200,
    headers: const <String, String>{'content-type': 'application/json'},
  );
}

Map<String, dynamic> _cabecalho(String idProcesso) {
  return ProcessoCabecalho(
    idProcesso: idProcesso,
    protocoloFormatado: '00001.000001/2026-00',
    descricao: 'Processo de teste',
    estadoProtocolo: 'A',
    dataGeracao: DateTime(2026, 8, 5, 10),
    nivelAcessoLocal: '0',
    nivelAcessoGlobal: '0',
    eliminado: false,
    dataConclusao: null,
    idTipoProcedimento: 1,
    tipoProcedimentoNome: 'Processo de teste',
    idUnidadeGeradora: 110000001,
    unidadeGeradoraSigla: 'TESTE',
    unidadeGeradoraDescricao: 'Unidade de Teste',
    idUsuarioGerador: 1,
    usuarioGeradorSigla: 'teste',
    usuarioGeradorNome: 'Usuário de Teste',
  ).toMap();
}

Map<String, dynamic> _documentos() {
  return PaginaProcessoArvoreDocumentos(
    itens: <ProcessoArvoreDocumentoItem>[
      ProcessoArvoreDocumentoItem(
        idRelacao: '1001',
        idDocumento: '2001',
        protocoloFormatado: '00001.000001/2026-00',
        nomeArvore: 'Despacho de teste',
        numero: '1',
        serieNome: 'Despacho',
        idUnidadeResponsavel: 110000001,
        unidadeResponsavelSigla: 'TESTE',
        estadoDocumento: 'A',
        nivelAcesso: '0',
        bloqueado: false,
        arquivamento: false,
        possuiVersoes: false,
        sequencia: 20,
        estadoAssociacao: '1',
        dataAssociacao: DateTime(2026, 8, 5, 10),
        ciencia: false,
        dataGeracao: DateTime(2026, 8, 5, 10),
      ),
    ],
    limite: 20,
    proximoCursor: '20:1001',
  ).toMap();
}

Map<String, dynamic> _andamentos(String idProcesso) {
  return PaginaProcessoAndamentos(
    itens: <ProcessoAndamentoItem>[
      ProcessoAndamentoItem(
        idAtividade: 1,
        idProcesso: idProcesso,
        idTarefa: 3,
        tarefaNome: 'Analisar processo',
        idUnidade: 110000001,
        unidadeSigla: 'TESTE',
        unidadeDescricao: 'Unidade de Teste',
        idUnidadeOrigem: 110000002,
        unidadeOrigemSigla: 'ORIGEM',
        unidadeOrigemDescricao: 'Unidade de Origem',
        idUsuario: 1,
        usuarioNome: 'Usuário Responsável',
        idUsuarioOrigem: 2,
        usuarioOrigemNome: 'Usuário de Origem',
        idUsuarioConclusao: null,
        usuarioConclusaoNome: null,
        dataAbertura: DateTime(2026, 8, 5, 10),
        dataConclusao: null,
        dataPrazo: null,
        atividadeInicial: true,
        tipoVisualizacao: 0,
        atributos: <ProcessoAndamentoAtributo>[
          ProcessoAndamentoAtributo(
            idAtributoAndamento: 1,
            idOrigem: null,
            nome: 'Motivo',
            valor: 'Teste',
          ),
        ],
      ),
    ],
    limite: 50,
    proximoCursor: null,
  ).toMap();
}
