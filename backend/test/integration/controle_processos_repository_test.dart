import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

void main() {
  group('controle processos repository', () {
    late SeiDatabaseService databaseService;
    late ControleProcessosService controleProcessosService;

    setUpAll(() {
      final config = SeiAppConfig.carregar();
      databaseService = SeiDatabaseService(config);
      controleProcessosService = ControleProcessosService(databaseService);
    });

    tearDownAll(() async {
      await databaseService.dispose();
    });

    test('retorna pagina vazia sem criar dados ficticios', () async {
      final pagina = await controleProcessosService.listarRecebidos(
        ControleProcessosFiltro(idUnidade: 110000001),
      );

      expect(pagina.itens, isEmpty);
      expect(pagina.total, 0);
      expect(pagina.limite, ControleProcessosFiltro.limitePadrao);
      expect(pagina.deslocamento, 0);
    });

    test('separa atividades geradas sem criar dados ficticios', () async {
      final pagina = await controleProcessosService.listarGerados(
        ControleProcessosFiltro(
          idUnidade: 110000001,
          modo: ControleProcessosModo.gerados,
        ),
      );

      expect(pagina.itens, isEmpty);
      expect(pagina.total, 0);
      expect(pagina.limite, ControleProcessosFiltro.limitePadrao);
      expect(pagina.deslocamento, 0);
    });
  });
}
