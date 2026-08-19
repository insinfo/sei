import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';

void main() {
  group('catalogo repository', () {
    late EscopoRepositorioTeste escopo;
    late CatalogoRepository catalogoRepository;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSei();
      catalogoRepository = escopo.make<CatalogoRepository>();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    test('le catalogos da referencia restaurada', () async {
      final CatalogoResumo resumo = await catalogoRepository.obterResumo();
      final List<TipoProcedimento> tipos =
          await catalogoRepository.listarTiposProcedimento(
        somenteAtivos: false,
      );
      final List<Serie> series = await catalogoRepository.listarSeries(
        somenteAtivas: false,
      );

      expect(resumo.tiposProcedimento, 318);
      expect(resumo.series, 254);
      expect(resumo.assuntos, 684);
      expect(resumo.hipotesesLegais, 23);
      expect(resumo.extensoesArquivo, 41);
      expect(resumo.unidades, 3);
      expect(resumo.usuarios, 5);
      expect(tipos, hasLength(resumo.tiposProcedimento));
      expect(series, hasLength(resumo.series));
      expect(tipos.first.nome, isNotEmpty);
      expect(series.first.nome, isNotEmpty);
      expect(
        tipos
            .where(
              (TipoProcedimento tipo) => tipo.idTipoProcedimento == 100000101,
            )
            .single
            .nome,
        'Pessoal: Abono Permanência - Concessão',
      );
      expect(
        series.where((Serie serie) => serie.idSerie == 1).single.nome,
        'Resolução',
      );
      expect(
        tipos.any(
          (TipoProcedimento tipo) => tipo.nome.contains('\uFFFD'),
        ),
        isFalse,
      );
    });

    test('le o catalogo de tarefas da referencia restaurada', () async {
      final List<TarefaCatalogo> tarefas =
          await catalogoRepository.listarTarefas();

      expect(tarefas, hasLength(119));
      expect(
        tarefas.first.idTarefa,
        lessThan(tarefas.last.idTarefa),
        reason: 'O cat\u00E1logo deve chegar ordenado por identificador.',
      );
      expect(
        tarefas.any((TarefaCatalogo tarefa) => tarefa.nome.contains('\uFFFD')),
        isFalse,
        reason:
            'A base \u00EDntegra em LATIN1 n\u00E3o pode conter caractere de '
            'substitui\u00E7\u00E3o.',
      );
    });

    test('envio nao conclui sozinho e a conclusao automatica conclui',
        () async {
      final Map<int, TarefaCatalogo> porId = <int, TarefaCatalogo>{
        for (final TarefaCatalogo tarefa
            in await catalogoRepository.listarTarefas())
          tarefa.idTarefa: tarefa,
      };

      final TarefaCatalogo remessa =
          porId[TarefaSei.processoRemetidoPelaUnidade.id]!;
      final TarefaCatalogo conclusaoAutomatica =
          porId[TarefaSei.conclusaoAutomaticaNaUnidade.id]!;
      final TarefaCatalogo conclusaoManual =
          porId[TarefaSei.conclusaoProcessoNaUnidade.id]!;
      final TarefaCatalogo reabertura =
          porId[TarefaSei.reaberturaProcessoNaUnidade.id]!;

      expect(
        remessa.fechaAndamentosAbertos,
        isFalse,
        reason: 'A remessa n\u00E3o fecha andamentos abertos; quem conclui na '
            'origem \u00E9 a conclus\u00E3o autom\u00E1tica lan\u00E7ada em seguida.',
      );
      expect(remessa.encerraPresencaNaUnidade, isFalse);
      expect(conclusaoAutomatica.encerraPresencaNaUnidade, isTrue);
      expect(conclusaoManual.encerraPresencaNaUnidade, isTrue);
      expect(
        reabertura.mantemProcessoAbertoNaUnidade,
        isTrue,
        reason: 'Reabrir devolve o processo \u00E0 mesa da unidade.',
      );
    });

    test('assinar documento e permitido com o processo concluido', () async {
      final Map<int, TarefaCatalogo> porId = <int, TarefaCatalogo>{
        for (final TarefaCatalogo tarefa
            in await catalogoRepository.listarTarefas())
          tarefa.idTarefa: tarefa,
      };

      expect(
        porId[TarefaSei.documentoAssinado.id]!.permiteProcessoFechado,
        isTrue,
        reason:
            'Bloco de assinatura funciona com o processo j\u00E1 conclu\u00EDdo na '
            'unidade.',
      );
      expect(
        porId[TarefaSei.processoGerado.id]!.permiteProcessoFechado,
        isFalse,
      );
      expect(
        porId[TarefaSei.processoGerado.id]!.mantemProcessoAbertoNaUnidade,
        isTrue,
        reason:
            'A autua\u00E7\u00E3o deixa o processo aberto na unidade geradora.',
      );
    });
  });
}
