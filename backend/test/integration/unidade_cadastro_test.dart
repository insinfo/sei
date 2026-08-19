import 'package:angel3_container/angel3_container.dart';
import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';

void main() {
  group('cadastro de unidade', () {
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
        descricao: 'Órgão de teste de cadastro de unidade',
        connection: conexao,
      );
    }

    test('cria unidade com contato associado ao orgao', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final Orgao orgao = await _criarOrgao(container, conexao);
        final UnidadeService unidadeService = container.make<UnidadeService>();

        final Unidade criada = await unidadeService.criar(
          idOrgao: orgao.idOrgao,
          sigla: 'NOVAUNID',
          descricao: 'Nova Unidade de Teste',
          connection: conexao,
        );

        expect(criada.idUnidade, greaterThan(0));
        expect(criada.idContato, greaterThan(0));

        final UnidadeRepository unidadeRepository =
            container.make<UnidadeRepository>();
        final Unidade? lida = await unidadeRepository.buscarPorId(
          criada.idUnidade,
          connection: conexao,
        );

        expect(lida, isNotNull);
        expect(lida!.sigla, 'NOVAUNID');
        expect(lida.descricao, 'Nova Unidade de Teste');
        expect(lida.idOrgao, orgao.idOrgao);

        final Map<String, dynamic>? linhaContato = await conexao
            .table(Contato.fqtn)
            .where(Contato.idContatoCol, '=', criada.idContato)
            .first();
        expect(linhaContato, isNotNull);
        final Contato contatoDaUnidade = Contato.fromMap(linhaContato!);
        expect(contatoDaUnidade.idContatoAssociado, orgao.idContato);
        expect(contatoDaUnidade.tipoContato, TipoContato.unidades);
      });
    });

    test('rejeita criacao para orgao inexistente', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final UnidadeService unidadeService = container.make<UnidadeService>();

        await expectLater(
          () => unidadeService.criar(
            idOrgao: 999999999,
            sigla: 'x',
            descricao: 'x',
            connection: conexao,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    test('atualiza dados cadastrais da unidade', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final Orgao orgao = await _criarOrgao(container, conexao);
        final UnidadeService unidadeService = container.make<UnidadeService>();
        final UnidadeRepository unidadeRepository =
            container.make<UnidadeRepository>();

        final Unidade criada = await unidadeService.criar(
          idOrgao: orgao.idOrgao,
          sigla: 'ANTIGA',
          descricao: 'Descrição Antiga',
          connection: conexao,
        );

        await unidadeService.atualizarDadosCadastrais(
          idUnidade: criada.idUnidade,
          sigla: 'NOVA',
          descricao: 'Descrição Nova',
          ativo: false,
          connection: conexao,
        );

        final Unidade? depois = await unidadeRepository.buscarPorId(
          criada.idUnidade,
          connection: conexao,
        );

        expect(depois, isNotNull);
        expect(depois!.sigla, 'NOVA');
        expect(depois.descricao, 'Descrição Nova');
        expect(depois.ativo, isFalse);
      });
    });

    test('lista unidades paginadas filtrando por orgao', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final Orgao orgao = await _criarOrgao(container, conexao);
        final UnidadeService unidadeService = container.make<UnidadeService>();
        final UnidadeRepository unidadeRepository =
            container.make<UnidadeRepository>();

        await unidadeService.criar(
          idOrgao: orgao.idOrgao,
          sigla: 'LISTA1',
          descricao: 'Lista 1',
          connection: conexao,
        );
        await unidadeService.criar(
          idOrgao: orgao.idOrgao,
          sigla: 'LISTA2',
          descricao: 'Lista 2',
          connection: conexao,
        );

        final PaginaUnidades pagina = await unidadeRepository.listar(
          UnidadeFiltro(idOrgao: orgao.idOrgao),
          connection: conexao,
        );

        expect(pagina.total, 2);
        expect(pagina.itens, hasLength(2));
      });
    });

    test('a base de referencia volta ao estado anterior', () async {
      late int idUnidadeCriada;

      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final Orgao orgao = await _criarOrgao(container, conexao);
        final UnidadeService unidadeService = container.make<UnidadeService>();
        final Unidade unidade = await unidadeService.criar(
          idOrgao: orgao.idOrgao,
          sigla: 'REVERT',
          descricao: 'Revertida',
          connection: conexao,
        );
        idUnidadeCriada = unidade.idUnidade;
      });

      final UnidadeRepository unidadeRepository =
          escopo.make<UnidadeRepository>();
      expect(await unidadeRepository.buscarPorId(idUnidadeCriada), isNull);
    });
  });
}
