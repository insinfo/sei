import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';

void main() {
  group('controle processos repository', () {
    late EscopoRepositorioTeste escopo;
    late ControleProcessosRepository controleProcessosRepository;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSei();
      controleProcessosRepository = escopo.make<ControleProcessosRepository>();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    test('retorna pagina vazia sem criar dados ficticios', () async {
      final pagina = await controleProcessosRepository.listar(
        ControleProcessosFiltro(idUnidade: 110000001),
      );

      expect(pagina.itens, isEmpty);
      expect(pagina.total, 0);
      expect(pagina.limite, ControleProcessosFiltro.limitePadrao);
      expect(pagina.deslocamento, 0);
    });

    test('separa atividades geradas sem criar dados ficticios', () async {
      final pagina = await controleProcessosRepository.listar(
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
