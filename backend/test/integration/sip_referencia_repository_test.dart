import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';

void main() {
  group('sip referencia repository', () {
    late EscopoRepositorioTeste escopo;
    late SipReferenciaRepository sipReferenciaRepository;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSip();
      sipReferenciaRepository = escopo.make<SipReferenciaRepository>();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    test('le sistemas ativos sem expor credenciais ou permissoes', () async {
      final sistemas = await sipReferenciaRepository.listarSistemasAtivos();

      expect(sistemas, hasLength(2));
      expect(
          sistemas.every((SistemaSipResumo sistema) => sistema.ativo), isTrue);
      expect(sistemas.map((SistemaSipResumo sistema) => sistema.sigla), [
        'SIP',
        'SEI',
      ]);
      expect(
        sistemas
            .singleWhere((SistemaSipResumo sistema) => sistema.sigla == 'SEI')
            .descricao,
        'Sistema Eletrônico de Informações',
      );
    });
  });
}
