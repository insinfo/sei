import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

void main() {
  group('catalogo repository', () {
    late SeiDatabaseService databaseService;
    late CatalogoService catalogoService;

    setUpAll(() {
      final config = SeiAppConfig.carregar();
      databaseService = SeiDatabaseService(config);
      catalogoService = CatalogoService(databaseService);
    });

    tearDownAll(() async {
      await databaseService.dispose();
    });

    test('le catalogos da referencia restaurada', () async {
      final resumo = await catalogoService.obterResumo();
      final tipos = await catalogoService.listarTiposProcedimento(
        somenteAtivos: false,
      );
      final series = await catalogoService.listarSeries(somenteAtivas: false);

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
  });
}
