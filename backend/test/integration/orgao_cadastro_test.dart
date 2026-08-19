import 'package:angel3_container/angel3_container.dart';
import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';

void main() {
  group('cadastro de orgao', () {
    late EscopoRepositorioTeste escopo;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSei();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    test('cria orgao com contato autorreferenciado e sem unidade raiz',
        () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final OrgaoService orgaoService = container.make<OrgaoService>();

        final Orgao criado = await orgaoService.criar(
          sigla: 'NOVOORG${DateTime.now().microsecondsSinceEpoch}',
          descricao: 'Novo Órgão de Teste',
          connection: conexao,
        );

        expect(criado.idOrgao, greaterThan(0));
        expect(criado.idContato, greaterThan(0));
        expect(
          criado.idUnidade,
          isNull,
          reason: 'Órgão novo não tem unidade raiz ainda.',
        );

        final OrgaoRepository orgaoRepository =
            container.make<OrgaoRepository>();
        final Orgao? lido = await orgaoRepository.buscarPorId(
          criado.idOrgao,
          connection: conexao,
        );

        expect(lido, isNotNull);
        expect(lido!.descricao, 'Novo Órgão de Teste');
        expect(lido.idUnidade, isNull);

        final Map<String, dynamic>? linhaContato = await conexao
            .table(Contato.fqtn)
            .where(Contato.idContatoCol, '=', criado.idContato)
            .first();
        expect(linhaContato, isNotNull);
        final Contato contatoDoOrgao = Contato.fromMap(linhaContato!);
        expect(
          contatoDoOrgao.idContatoAssociado,
          criado.idContato,
          reason: 'O contato do próprio órgão referencia a si mesmo.',
        );
        expect(contatoDoOrgao.tipoContato, TipoContato.orgaos);
      });
    });

    test('atualiza dados cadastrais do orgao', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final OrgaoService orgaoService = container.make<OrgaoService>();
        final OrgaoRepository orgaoRepository =
            container.make<OrgaoRepository>();

        final Orgao criado = await orgaoService.criar(
          sigla: 'ANTIGO${DateTime.now().microsecondsSinceEpoch}',
          descricao: 'Descrição Antiga',
          connection: conexao,
        );

        await orgaoService.atualizarDadosCadastrais(
          idOrgao: criado.idOrgao,
          sigla: 'NOVOSIGLA',
          descricao: 'Descrição Nova',
          ativo: false,
          connection: conexao,
        );

        final Orgao? depois = await orgaoRepository.buscarPorId(
          criado.idOrgao,
          connection: conexao,
        );

        expect(depois, isNotNull);
        expect(depois!.sigla, 'NOVOSIGLA');
        expect(depois.descricao, 'Descrição Nova');
        expect(depois.ativo, isFalse);
      });
    });

    test('busca orgao por sigla', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final OrgaoService orgaoService = container.make<OrgaoService>();
        final OrgaoRepository orgaoRepository =
            container.make<OrgaoRepository>();
        final String sigla = 'BUSCA${DateTime.now().microsecondsSinceEpoch}';

        final Orgao criado = await orgaoService.criar(
          sigla: sigla,
          descricao: 'Órgão buscado por sigla',
          connection: conexao,
        );

        final Orgao? encontrado = await orgaoRepository.buscarPorSigla(
          sigla,
          connection: conexao,
        );

        expect(encontrado, isNotNull);
        expect(encontrado!.idOrgao, criado.idOrgao);
      });
    });

    test('lista orgaos paginados filtrando por sigla', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final OrgaoService orgaoService = container.make<OrgaoService>();
        final OrgaoRepository orgaoRepository =
            container.make<OrgaoRepository>();
        final String prefixo = 'FILTRO${DateTime.now().microsecondsSinceEpoch}';

        await orgaoService.criar(
          sigla: '${prefixo}A',
          descricao: 'Filtro A',
          connection: conexao,
        );
        await orgaoService.criar(
          sigla: '${prefixo}B',
          descricao: 'Filtro B',
          connection: conexao,
        );

        final PaginaOrgaos pagina = await orgaoRepository.listar(
          OrgaoFiltro(sigla: prefixo),
          connection: conexao,
        );

        expect(pagina.total, 2);
        expect(pagina.itens, hasLength(2));
      });
    });

    test('a base de referencia volta ao estado anterior', () async {
      late int idOrgaoCriado;

      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final OrgaoService orgaoService = container.make<OrgaoService>();
        final Orgao orgao = await orgaoService.criar(
          sigla: 'REVERT${DateTime.now().microsecondsSinceEpoch}',
          descricao: 'Revertido',
          connection: conexao,
        );
        idOrgaoCriado = orgao.idOrgao;
      });

      final OrgaoRepository orgaoRepository = escopo.make<OrgaoRepository>();
      expect(await orgaoRepository.buscarPorId(idOrgaoCriado), isNull);
    });
  });
}
