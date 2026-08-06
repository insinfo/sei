import 'package:sei_core/sei_core.dart';
import 'package:test/test.dart';

void main() {
  group('controle processos filtro', () {
    test('mantem o modo gerados no contrato tipado', () {
      final filtro = ControleProcessosFiltro(
        idUnidade: 110000001,
        modo: ControleProcessosModo.gerados,
        limite: 25,
      );

      expect(filtro.toMap()[ControleProcessosFiltro.modoCol], 'gerados');
      expect(filtro.modo.valorAtividadeInicial, 'S');
    });

    test('recusa modo de controle invalido', () {
      expect(
        () => ControleProcessosModo.fromValue('pendentes'),
        throwsFormatException,
      );
    });

    test('aceita modo definido pela rota sem confiar na query', () {
      final filtro = ControleProcessosFiltro.fromMap(
        <String, dynamic>{
          ControleProcessosFiltro.idUnidadeCol: '110000001',
          ControleProcessosFiltro.modoCol: 'recebidos',
        },
        modo: ControleProcessosModo.gerados,
      );

      expect(filtro.modo, ControleProcessosModo.gerados);
    });
  });
}
