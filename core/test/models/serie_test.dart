import 'package:sei_core/sei_core.dart';
import 'package:test/test.dart';

void main() {
  group('serie', () {
    test('cria estado inicial e copia sem chave primaria nos mapas de escrita',
        () {
      final Serie serie = Serie.nova();

      expect(serie.idSerie, 0);
      expect(serie.clone(), serie);
      expect(serie.toInsertMap(), isNot(contains(Serie.idCol)));
      expect(serie.toUpdateMap(), isNot(contains(Serie.idCol)));
    });
  });
}
