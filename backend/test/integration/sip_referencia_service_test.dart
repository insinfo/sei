import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

void main() {
  group('sip referencia service', () {
    late SipDatabaseService databaseService;
    late SipReferenciaService sipReferenciaService;

    setUpAll(() {
      final config = SeiAppConfig.carregar();
      databaseService = SipDatabaseService(config);
      sipReferenciaService = SipReferenciaService(databaseService);
    });

    tearDownAll(() async {
      await databaseService.dispose();
    });

    test('le sistemas ativos sem expor credenciais ou permissoes', () async {
      final sistemas = await sipReferenciaService.listarSistemasAtivos();

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
