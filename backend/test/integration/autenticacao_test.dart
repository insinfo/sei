import 'package:angel3_container/angel3_container.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';

void main() {
  group('autenticacao', () {
    late EscopoRepositorioTeste escopo;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSei();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    /// Cria um órgão e um usuário de teste com senha conhecida, dentro da
    /// transação revertida, e devolve os identificadores usados nos testes
    /// de login.
    Future<
        ({
          int idOrgao,
          String siglaOrgao,
          int idUsuario,
          String siglaUsuario
        })> _criarCenario(
      Container container,
      Connection conexao, {
      bool orgaoAtivo = true,
      bool usuarioAtivo = true,
    }) async {
      final OrgaoService orgaoService = container.make<OrgaoService>();
      final Orgao orgao = await orgaoService.criar(
        sigla: 'ORGTESTE${DateTime.now().microsecondsSinceEpoch}',
        descricao: 'Órgão de teste de login',
        ativo: orgaoAtivo,
        connection: conexao,
      );

      final UsuarioService usuarioService = container.make<UsuarioService>();
      final String hash = BCrypt.hashpw('senhaDeTeste123', BCrypt.gensalt());
      final UsuarioRepository usuarioRepository =
          container.make<UsuarioRepository>();

      // Cria o usuário via service (gera o contato associado) e depois
      // sobrescreve o hash com uma senha conhecida pelo teste, sem depender
      // do hash gerado internamente pelo service.
      final Usuario usuario = await usuarioService.criar(
        idOrgao: orgao.idOrgao,
        sigla: 'usuarioteste',
        nome: 'Usuário de Teste de Login',
        senha: 'senhaTemporaria',
        ativo: usuarioAtivo,
        connection: conexao,
      );
      await usuarioRepository.atualizarSenha(
        usuario.idUsuario,
        hash,
        connection: conexao,
      );

      return (
        idOrgao: orgao.idOrgao,
        siglaOrgao: orgao.sigla,
        idUsuario: usuario.idUsuario,
        siglaUsuario: usuario.sigla,
      );
    }

    test('login bem sucedido emite token com as claims esperadas', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final cenario = await _criarCenario(container, conexao);

        final AutenticacaoService autenticacaoService =
            container.make<AutenticacaoService>();
        final LoginResultado resultado = await autenticacaoService.login(
          usuario: cenario.siglaUsuario,
          senha: 'senhaDeTeste123',
          siglaOrgao: cenario.siglaOrgao,
        );

        expect(resultado.idUsuario, cenario.idUsuario);
        expect(resultado.idOrgao, cenario.idOrgao);
        expect(resultado.siglaUsuario, cenario.siglaUsuario);
        expect(resultado.token, isNotEmpty);

        final AutenticacaoTokenService tokenService =
            container.make<AutenticacaoTokenService>();
        final Map<String, dynamic>? claims =
            await tokenService.verificar(resultado.token);

        expect(claims, isNotNull);
        expect(claims![AutenticacaoService.claimIdUsuario], cenario.idUsuario);
        expect(claims[AutenticacaoService.claimIdOrgao], cenario.idOrgao);
        expect(claims[AutenticacaoService.claimSigla], cenario.siglaUsuario);
      });
    });

    test('senha incorreta cai no erro generico', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final cenario = await _criarCenario(container, conexao);
        final AutenticacaoService autenticacaoService =
            container.make<AutenticacaoService>();

        await expectLater(
          () => autenticacaoService.login(
            usuario: cenario.siglaUsuario,
            senha: 'senhaErrada',
            siglaOrgao: cenario.siglaOrgao,
          ),
          throwsA(isA<AutenticacaoInvalidaException>()),
        );
      });
    });

    test('usuario inexistente cai no erro generico', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final cenario = await _criarCenario(container, conexao);
        final AutenticacaoService autenticacaoService =
            container.make<AutenticacaoService>();

        await expectLater(
          () => autenticacaoService.login(
            usuario:
                'usuario_que_nao_existe_${DateTime.now().microsecondsSinceEpoch}',
            senha: 'senhaDeTeste123',
            siglaOrgao: cenario.siglaOrgao,
          ),
          throwsA(isA<AutenticacaoInvalidaException>()),
        );
      });
    });

    test('orgao inexistente cai no erro generico', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final cenario = await _criarCenario(container, conexao);
        final AutenticacaoService autenticacaoService =
            container.make<AutenticacaoService>();

        await expectLater(
          () => autenticacaoService.login(
            usuario: cenario.siglaUsuario,
            senha: 'senhaDeTeste123',
            siglaOrgao: 'ORGAO_QUE_NAO_EXISTE_XYZ',
          ),
          throwsA(isA<AutenticacaoInvalidaException>()),
        );
      });
    });

    test('usuario inativo cai no erro generico', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final cenario = await _criarCenario(
          container,
          conexao,
          usuarioAtivo: false,
        );
        final AutenticacaoService autenticacaoService =
            container.make<AutenticacaoService>();

        await expectLater(
          () => autenticacaoService.login(
            usuario: cenario.siglaUsuario,
            senha: 'senhaDeTeste123',
            siglaOrgao: cenario.siglaOrgao,
          ),
          throwsA(isA<AutenticacaoInvalidaException>()),
        );
      });
    });

    test('orgao inativo cai no erro generico', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final cenario = await _criarCenario(
          container,
          conexao,
          orgaoAtivo: false,
        );
        final AutenticacaoService autenticacaoService =
            container.make<AutenticacaoService>();

        await expectLater(
          () => autenticacaoService.login(
            usuario: cenario.siglaUsuario,
            senha: 'senhaDeTeste123',
            siglaOrgao: cenario.siglaOrgao,
          ),
          throwsA(isA<AutenticacaoInvalidaException>()),
        );
      });
    });

    test('lista orgaos ativos para o seletor de login', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final cenario = await _criarCenario(container, conexao);
        final AutenticacaoService autenticacaoService =
            container.make<AutenticacaoService>();

        final List<OrgaoLoginResumo> orgaos =
            await autenticacaoService.listarOrgaosAtivos();

        expect(
          orgaos.any((OrgaoLoginResumo o) => o.idOrgao == cenario.idOrgao),
          isTrue,
        );
      });
    });
  });
}
