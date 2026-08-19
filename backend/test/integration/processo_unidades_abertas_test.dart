import 'package:angel3_container/angel3_container.dart';
import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';
import '../support/fixture_processo_sei.dart';

void main() {
  group('processo aberto em varias unidades', () {
    late EscopoRepositorioTeste escopo;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSei();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    test('lista apenas as unidades com atividade aberta', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final List<ProcessoUnidadeAberta> unidades =
            await repositorio.listarUnidadesAbertas(
          FixtureProcessoSei.idProcessoPrincipal,
        );

        expect(
          unidades.map((ProcessoUnidadeAberta u) => u.idUnidade),
          <int>[
            FixtureProcessoSei.idUnidadeGeradora,
            FixtureProcessoSei.idUnidadeRecebedora,
          ],
          reason: 'A unidade que concluiu não responde mais pelo processo, '
              'mas o processo segue aberto nas outras duas.',
        );
      });
    });

    test('separa unidade geradora de unidade recebedora', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final Map<int, ProcessoUnidadeAberta> porUnidade =
            <int, ProcessoUnidadeAberta>{
          for (final ProcessoUnidadeAberta unidade
              in await repositorio.listarUnidadesAbertas(
            FixtureProcessoSei.idProcessoPrincipal,
          ))
            unidade.idUnidade: unidade,
        };

        final ProcessoUnidadeAberta geradora =
            porUnidade[FixtureProcessoSei.idUnidadeGeradora]!;
        final ProcessoUnidadeAberta recebedora =
            porUnidade[FixtureProcessoSei.idUnidadeRecebedora]!;

        expect(geradora.geradoNaUnidade, isTrue);
        expect(recebedora.geradoNaUnidade, isFalse);
        expect(geradora.atividadesAbertas, 1);
        expect(recebedora.atividadesAbertas, 1);
        expect(
          geradora.dataAbertura.isBefore(recebedora.dataAbertura),
          isTrue,
          reason: 'A autuação precede o recebimento na outra unidade.',
        );
        expect(geradora.unidadeSigla, isNotEmpty);
      });
    });

    test('resolve a atribuicao da atividade aberta mais recente', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final List<ProcessoUnidadeAberta> unidades =
            await repositorio.listarUnidadesAbertas(
          FixtureProcessoSei.idProcessoPrincipal,
        );
        final ProcessoUnidadeAberta geradora = unidades.firstWhere(
          (ProcessoUnidadeAberta unidade) =>
              unidade.idUnidade == FixtureProcessoSei.idUnidadeGeradora,
        );
        final ProcessoUnidadeAberta recebedora = unidades.firstWhere(
          (ProcessoUnidadeAberta unidade) =>
              unidade.idUnidade == FixtureProcessoSei.idUnidadeRecebedora,
        );

        expect(geradora.possuiAtribuicao, isTrue);
        expect(geradora.idUsuarioAtribuicao, FixtureProcessoSei.idUsuario);
        expect(geradora.usuarioAtribuicaoNome, isNotEmpty);
        expect(
          recebedora.possuiAtribuicao,
          isFalse,
          reason: 'A atribuição é por unidade e não acompanha o trâmite.',
        );
      });
    });

    test('a fila da unidade separa recebidos de gerados', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ControleProcessosRepository repositorio =
            container.make<ControleProcessosRepository>();

        final PaginaProcessosRecebidos gerados = await repositorio.listar(
          ControleProcessosFiltro(
            idUnidade: FixtureProcessoSei.idUnidadeGeradora,
            modo: ControleProcessosModo.gerados,
          ),
        );
        final PaginaProcessosRecebidos recebidos = await repositorio.listar(
          ControleProcessosFiltro(
            idUnidade: FixtureProcessoSei.idUnidadeRecebedora,
          ),
        );
        final PaginaProcessosRecebidos naUnidadeConcluida =
            await repositorio.listar(
          ControleProcessosFiltro(
            idUnidade: FixtureProcessoSei.idUnidadeConcluida,
          ),
        );

        expect(gerados.total, 1);
        expect(recebidos.total, 1);
        expect(
          naUnidadeConcluida.total,
          0,
          reason: 'Processo concluído sai do Controle de Processos da '
              'unidade que concluiu.',
        );
      });
    });

    test('relacionamento aparece nos dois processos', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final List<ProcessoRelacionado> doPrincipal =
            await repositorio.listarRelacionados(
          FixtureProcessoSei.idProcessoPrincipal,
        );
        final List<ProcessoRelacionado> doRelacionado =
            await repositorio.listarRelacionados(
          FixtureProcessoSei.idProcessoRelacionado,
        );

        expect(doPrincipal, hasLength(1));
        expect(doRelacionado, hasLength(1));
        expect(
          doPrincipal.single.idProcessoRelacionado,
          FixtureProcessoSei.idProcessoRelacionado.toString(),
        );
        expect(doPrincipal.single.sentido, SentidoRelacionamento.origem);
        expect(
          doRelacionado.single.idProcessoRelacionado,
          FixtureProcessoSei.idProcessoPrincipal.toString(),
        );
        expect(
          doRelacionado.single.sentido,
          SentidoRelacionamento.destino,
          reason: 'O vínculo é gravado uma única vez e é direcionado, mas a '
              'tela o exibe nos dois processos.',
        );
        expect(
          doPrincipal.single.idUnidadeAssociacao,
          FixtureProcessoSei.idUnidadeGeradora,
        );
      });
    });

    test('participantes chegam com papel e ordem definidos', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final List<ProcessoParticipante> participantes =
            await repositorio.listarParticipantes(
          FixtureProcessoSei.idProcessoPrincipal,
        );

        expect(participantes, hasLength(2));
        expect(
          participantes
              .map((ProcessoParticipante p) => p.participacao)
              .toList(growable: false),
          <ProcessoParticipacao>[
            ProcessoParticipacao.destinatario,
            ProcessoParticipacao.interessado,
          ],
          reason: 'A ordenação segue o código do papel e depois a sequência.',
        );
        expect(participantes.first.contatoNome, isNotEmpty);
      });
    });

    test('a base de referencia volta ao estado anterior', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
      });

      final ProcessoDetalheRepository repositorio =
          escopo.make<ProcessoDetalheRepository>();
      final ProcessoCabecalho? cabecalho = await repositorio.obterCabecalho(
        FixtureProcessoSei.idProcessoPrincipal,
      );
      final List<ProcessoUnidadeAberta> unidades =
          await repositorio.listarUnidadesAbertas(
        FixtureProcessoSei.idProcessoPrincipal,
      );

      expect(
        cabecalho,
        isNull,
        reason: 'Nada da fixture pode ser confirmado na Base de Referência.',
      );
      expect(unidades, isEmpty);
    });
  });
}
