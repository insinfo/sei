import 'package:sei_core/sei_core.dart';
import 'package:test/test.dart';

void main() {
  group('processo detalhe paginacao', () {
    test('usa limite padrao e preserva cursor opaco', () {
      final paginacao = ProcessoDetalhePaginacao.fromMap(
        <String, dynamic>{
          ProcessoDetalhePaginacao.cursorCol: 'Y3Vyc29yLXRlc3Rl',
        },
      );

      expect(paginacao.limite, ProcessoDetalhePaginacao.limitePadrao);
      expect(paginacao.cursor, 'Y3Vyc29yLXRlc3Rl');
      expect(
        paginacao.toMap()[ProcessoDetalhePaginacao.cursorCol],
        'Y3Vyc29yLXRlc3Rl',
      );
    });

    test('recusa limite acima do maximo', () {
      expect(
        () => ProcessoDetalhePaginacao(
          limite: ProcessoDetalhePaginacao.limiteMaximo + 1,
        ),
        throwsArgumentError,
      );
    });
  });
}
