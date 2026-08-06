import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';

void main() {
  group('contexto desenvolvimento repository', () {
    late EscopoRepositorioTeste escopo;
    late ContextoDesenvolvimentoRepository contextoRepository;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSei();
      contextoRepository = escopo.make<ContextoDesenvolvimentoRepository>();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    test('le usuario e unidades da referencia sem simular sessao', () async {
      final ContextoDesenvolvimento contexto =
          await contextoRepository.obterPorSiglaUsuario(
        SeiAppConfig.carregar().desenvolvimentoUsuarioSigla,
      );

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
