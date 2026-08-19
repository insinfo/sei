import 'package:angel3_container/angel3_container.dart';
import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';

void main() {
  group('cadastro de usuario', () {
    late EscopoRepositorioTeste escopo;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSei();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    Future<Orgao> _criarOrgao(Container container, Connection conexao) async {
      final OrgaoService orgaoService = container.make<OrgaoService>();
      return orgaoService.criar(
        sigla: 'ORG${DateTime.now().microsecondsSinceEpoch}',
        descricao: 'Órgão de teste de cadastro de usuário',
        connection: conexao,
      );
    }

    test('cria usuario com contato associado e nunca expoe a senha', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final Orgao orgao = await _criarOrgao(container, conexao);
        final UsuarioService usuarioService = container.make<UsuarioService>();

        final Usuario criado = await usuarioService.criar(
          idOrgao: orgao.idOrgao,
          sigla: 'novousuario',
          nome: 'Novo Usuário de Teste',
          senha: 'senhaSecreta123',
          connection: conexao,
        );

        expect(criado.idUsuario, greaterThan(0));
        expect(criado.idContato, greaterThan(0));
        expect(criado.senhaHash, isNotNull);
        expect(criado.senhaHash, isNot('senhaSecreta123'));

        final Map<String, dynamic> transporte = criado.toMap();
        expect(
          transporte.containsKey(Usuario.senhaCol),
          isFalse,
          reason: 'toMap() nunca deve incluir o hash da senha.',
        );

        final UsuarioRepository usuarioRepository =
            container.make<UsuarioRepository>();

        final Usuario? lido = await usuarioRepository.buscarPorId(
          criado.idUsuario,
          connection: conexao,
        );
        expect(lido, isNotNull);
        expect(lido!.sigla, 'novousuario');
        expect(lido.nome, 'Novo Usuário de Teste');
        expect(lido.idOrgao, orgao.idOrgao);
        expect(lido.idContato, criado.idContato);
        expect(
          lido.toMap().containsKey(Usuario.senhaCol),
          isFalse,
        );

        // O contato criado referencia o contato do órgão dono, não a si
        // mesmo (diferente do contato do próprio órgão).
        final Map<String, dynamic>? linhaContato = await conexao
            .table(Contato.fqtn)
            .where(Contato.idContatoCol, '=', criado.idContato)
            .first();
        expect(linhaContato, isNotNull);
        final Contato contatoDoUsuario = Contato.fromMap(linhaContato!);
        expect(contatoDoUsuario.idContatoAssociado, orgao.idContato);
        expect(contatoDoUsuario.tipoContato, TipoContato.usuarios);
      });
    });

    test('rejeita criacao para orgao inexistente', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final UsuarioService usuarioService = container.make<UsuarioService>();

        await expectLater(
          () => usuarioService.criar(
            idOrgao: 999999999,
            sigla: 'x',
            nome: 'x',
            senha: 'x',
            connection: conexao,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    test('atualiza dados cadastrais sem alterar a senha', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final Orgao orgao = await _criarOrgao(container, conexao);
        final UsuarioService usuarioService = container.make<UsuarioService>();
        final UsuarioRepository usuarioRepository =
            container.make<UsuarioRepository>();

        final Usuario criado = await usuarioService.criar(
          idOrgao: orgao.idOrgao,
          sigla: 'usuarioantigo',
          nome: 'Nome Antigo',
          senha: 'senhaOriginal123',
          connection: conexao,
        );
        final Usuario? antesDaAtualizacao = await usuarioRepository
            .buscarPorId(criado.idUsuario, connection: conexao);

        await usuarioService.atualizarDadosCadastrais(
          idUsuario: criado.idUsuario,
          sigla: 'usuarionovo',
          nome: 'Nome Novo',
          ativo: false,
          connection: conexao,
        );

        final Usuario? depois = await usuarioRepository.buscarPorId(
          criado.idUsuario,
          connection: conexao,
        );

        expect(depois, isNotNull);
        expect(depois!.sigla, 'usuarionovo');
        expect(depois.nome, 'Nome Novo');
        expect(depois.ativo, isFalse);
        expect(
          depois.senhaHash,
          antesDaAtualizacao!.senhaHash,
          reason: 'A atualização cadastral não deve tocar na senha.',
        );
      });
    });

    test('troca de senha grava novo hash sem alterar dados cadastrais',
        () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final Orgao orgao = await _criarOrgao(container, conexao);
        final UsuarioService usuarioService = container.make<UsuarioService>();
        final UsuarioRepository usuarioRepository =
            container.make<UsuarioRepository>();

        final Usuario criado = await usuarioService.criar(
          idOrgao: orgao.idOrgao,
          sigla: 'trocasenha',
          nome: 'Troca de Senha',
          senha: 'senhaAntiga123',
          connection: conexao,
        );

        await usuarioService.trocarSenha(
          idUsuario: criado.idUsuario,
          senhaNova: 'senhaNovaSegura456',
          connection: conexao,
        );

        final Usuario? depois = await usuarioRepository.buscarPorId(
          criado.idUsuario,
          connection: conexao,
        );

        expect(depois, isNotNull);
        expect(depois!.sigla, 'trocasenha');
        expect(depois.senhaHash, isNot(criado.senhaHash));
      });
    });

    test('lista usuarios paginados filtrando por orgao', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final Orgao orgao = await _criarOrgao(container, conexao);
        final UsuarioService usuarioService = container.make<UsuarioService>();
        final UsuarioRepository usuarioRepository =
            container.make<UsuarioRepository>();

        await usuarioService.criar(
          idOrgao: orgao.idOrgao,
          sigla: 'listagemA',
          nome: 'Usuário Listagem A',
          senha: 'senha123456',
          connection: conexao,
        );
        await usuarioService.criar(
          idOrgao: orgao.idOrgao,
          sigla: 'listagemB',
          nome: 'Usuário Listagem B',
          senha: 'senha123456',
          connection: conexao,
        );

        final PaginaUsuarios pagina = await usuarioRepository.listar(
          UsuarioFiltro(idOrgao: orgao.idOrgao),
          connection: conexao,
        );

        expect(pagina.total, 2);
        expect(pagina.itens, hasLength(2));
        expect(
          pagina.itens.every(
            (Usuario u) => u.toMap().containsKey(Usuario.senhaCol) == false,
          ),
          isTrue,
        );
      });
    });

    test('a base de referencia volta ao estado anterior', () async {
      late int idOrgaoCriado;
      late int idUsuarioCriado;

      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final Orgao orgao = await _criarOrgao(container, conexao);
        final UsuarioService usuarioService = container.make<UsuarioService>();
        final Usuario usuario = await usuarioService.criar(
          idOrgao: orgao.idOrgao,
          sigla: 'revertido',
          nome: 'Usuário Revertido',
          senha: 'senha123456',
          connection: conexao,
        );
        idOrgaoCriado = orgao.idOrgao;
        idUsuarioCriado = usuario.idUsuario;
      });

      final UsuarioRepository usuarioRepository =
          escopo.make<UsuarioRepository>();
      final OrgaoRepository orgaoRepository = escopo.make<OrgaoRepository>();

      expect(await usuarioRepository.buscarPorId(idUsuarioCriado), isNull);
      expect(await orgaoRepository.buscarPorId(idOrgaoCriado), isNull);
    });
  });
}
