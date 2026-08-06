import 'package:sei_core/sei_core.dart';
import 'package:test/test.dart';

void main() {
  group('base model', () {
    test('dto imutavel compara pelo conteudo serializado', () {
      final ControleProcessosFiltro primeiro = ControleProcessosFiltro(
        idUnidade: 10,
      );
      final ControleProcessosFiltro segundo = ControleProcessosFiltro(
        idUnidade: 10,
      );

      expect(primeiro, segundo);
      expect(primeiro.hashCode, segundo.hashCode);
    });

    test('dto de leitura recusa mapas de persistencia', () {
      final ControleProcessosFiltro filtro = ControleProcessosFiltro(
        idUnidade: 10,
      );

      expect(filtro.toInsertMap, throwsUnsupportedError);
      expect(filtro.toUpdateMap, throwsUnsupportedError);
    });
  });
}
