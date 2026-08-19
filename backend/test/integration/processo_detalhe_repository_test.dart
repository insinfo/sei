import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';

void main() {
  group('processo detalhe repository', () {
    late EscopoRepositorioTeste escopo;
    late ProcessoDetalheRepository processoRepository;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSei();
      processoRepository = escopo.make<ProcessoDetalheRepository>();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    test('consulta processo inexistente sem criar dados ficticios', () async {
      const idProcessoInexistente = 999999999;
      final cabecalho = await processoRepository.obterCabecalho(
        idProcessoInexistente,
      );
      final documentos = await processoRepository.listarDocumentos(
        idProcessoInexistente,
        ProcessoDetalhePaginacao(),
      );
      final andamentos = await processoRepository.listarAndamentos(
        idProcessoInexistente,
        ProcessoDetalhePaginacao(),
      );

      expect(cabecalho, isNull);
      expect(documentos.itens, isEmpty);
      expect(documentos.proximoCursor, isNull);
      expect(andamentos.itens, isEmpty);
      expect(andamentos.proximoCursor, isNull);
    });

    test('projecoes por unidade e vinculos ficam vazias sem dados', () async {
      const idProcessoInexistente = 999999999;

      final unidadesAbertas = await processoRepository.listarUnidadesAbertas(
        idProcessoInexistente,
      );
      final relacionados = await processoRepository.listarRelacionados(
        idProcessoInexistente,
      );
      final participantes = await processoRepository.listarParticipantes(
        idProcessoInexistente,
      );

      expect(unidadesAbertas, isEmpty);
      expect(relacionados, isEmpty);
      expect(participantes, isEmpty);
    });

    test('recusa cursor malformado antes de consultar a pagina', () async {
      await expectLater(
        processoRepository.listarDocumentos(
          999999999,
          ProcessoDetalhePaginacao(cursor: '!'),
        ),
        throwsFormatException,
      );
      await expectLater(
        processoRepository.listarAndamentos(
          999999999,
          ProcessoDetalhePaginacao(cursor: '!'),
        ),
        throwsFormatException,
      );
    });
  });
}
