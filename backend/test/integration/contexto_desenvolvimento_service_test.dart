import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

void main() {
  group('contexto desenvolvimento service', () {
    late SeiDatabaseService databaseService;
    late ContextoDesenvolvimentoService contextoService;

    setUpAll(() {
      final config = SeiAppConfig.carregar();
      databaseService = SeiDatabaseService(config);
      contextoService = ContextoDesenvolvimentoService(databaseService, config);
    });

    tearDownAll(() async {
      await databaseService.dispose();
    });

    test('le usuario e unidades da referencia sem simular sessao', () async {
      final contexto = await contextoService.obter();

      expect(contexto.siglaUsuario, 'teste');
      expect(contexto.nomeUsuario, 'Usuário de Testes');
      expect(contexto.idOrgao, 0);
      expect(contexto.unidades, hasLength(3));
      expect(contexto.idUnidadeInicial, 110000001);
      expect(contexto.unidades.first.sigla, 'TESTE');
      expect(contexto.unidades.first.descricao, 'Unidade de Teste 1');
    });
  });
}
