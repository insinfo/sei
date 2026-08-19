import 'package:angel3_container/angel3_container.dart';
import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';
import '../support/fixture_processo_sei.dart';

void main() {
  group('sinalizacoes da unidade sobre o processo', () {
    late EscopoRepositorioTeste escopo;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSei();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    test('anotacao so aparece para a unidade que a criou', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final List<ProcessoAnotacao> daGeradora =
            await repositorio.listarAnotacoes(
          FixtureProcessoSei.idProcessoPrincipal,
          FixtureProcessoSei.idUnidadeGeradora,
        );
        final List<ProcessoAnotacao> daRecebedora =
            await repositorio.listarAnotacoes(
          FixtureProcessoSei.idProcessoPrincipal,
          FixtureProcessoSei.idUnidadeRecebedora,
        );

        expect(daGeradora, hasLength(1));
        expect(daGeradora.single.descricao, isNotEmpty);
        expect(daGeradora.single.usuarioNome, isNotEmpty);
        expect(
          daRecebedora,
          isEmpty,
          reason: 'A anotação nunca tramita; é exclusiva da unidade que a '
              'criou.',
        );
      });
    });

    test('marcador vigente traz nome e icone do catalogo', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final List<ProcessoMarcador> marcadores =
            await repositorio.listarMarcadores(
          FixtureProcessoSei.idProcessoPrincipal,
        );

        expect(marcadores, hasLength(1));
        expect(marcadores.single.marcadorNome, 'Fixture');
        expect(marcadores.single.marcadorIcone, '4');
        expect(marcadores.single.usuarioNome, isNotEmpty);
      });
    });

    test('marcador removido nao aparece como vigente', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);

        // Uma remoção real do SEI também rebaixa a linha corrente anterior:
        // sem isso, o par processo e marcador teria duas linhas com
        // sin_ultimo='S' ao mesmo tempo, o que os dados reais nunca mostram.
        await conexao
            .table(AndamentoMarcador.fqtn)
            .where(
              AndamentoMarcador.idAndamentoMarcadorCol,
              '=',
              900000001,
            )
            .update(<String, dynamic>{
          AndamentoMarcador.ultimoCol: SeiCoreUtils.boolParaSimNao(false),
        });

        final AndamentoMarcador remocao = AndamentoMarcador(
          idAndamentoMarcador: 900000099,
          idMarcador: 900000001,
          idUnidade: FixtureProcessoSei.idUnidadeGeradora,
          idUsuario: FixtureProcessoSei.idUsuario,
          idProcedimento: FixtureProcessoSei.idProcessoPrincipal,
          dataExecucao: DateTime(2026, 8, 6),
          operacao: OperacaoMarcador.remocao,
          ultimo: false,
          ativo: false,
        );
        await conexao
            .table(AndamentoMarcador.fqtn)
            .insert(remocao.toInsertMap());

        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();
        final List<ProcessoMarcador> marcadores =
            await repositorio.listarMarcadores(
          FixtureProcessoSei.idProcessoPrincipal,
        );

        expect(
          marcadores,
          isEmpty,
          reason: 'Uma remoção grava sin_ultimo=N e sin_ativo=N, sem deixar '
              'linha corrente para o par processo e marcador.',
        );
      });
    });

    test(
      'acompanhamento especial funciona mesmo com o processo ja concluido '
      'naquela unidade',
      () async {
        await escopo.emTransacaoRevertida((
          Container container,
          Connection conexao,
        ) async {
          await FixtureProcessoSei.inserir(conexao);
          final ProcessoDetalheRepository repositorio =
              container.make<ProcessoDetalheRepository>();

          final List<ProcessoAcompanhamento> acompanhamentos =
              await repositorio.listarAcompanhamentos(
            FixtureProcessoSei.idProcessoPrincipal,
          );

          expect(acompanhamentos, hasLength(1));
          expect(
            acompanhamentos.single.idUnidade,
            FixtureProcessoSei.idUnidadeConcluida,
            reason: 'O acompanhamento não exige o processo aberto na '
                'unidade que acompanha.',
          );
          expect(acompanhamentos.single.grupoNome, 'Fixture');
          expect(acompanhamentos.single.observacao, isNotEmpty);
        });
      },
    );

    test('controle de prazo e organizacao interna da unidade', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final List<ProcessoControlePrazo> daGeradora =
            await repositorio.listarControlesPrazo(
          FixtureProcessoSei.idProcessoPrincipal,
          FixtureProcessoSei.idUnidadeGeradora,
        );
        final List<ProcessoControlePrazo> daRecebedora =
            await repositorio.listarControlesPrazo(
          FixtureProcessoSei.idProcessoPrincipal,
          FixtureProcessoSei.idUnidadeRecebedora,
        );

        expect(daGeradora, hasLength(1));
        expect(daGeradora.single.concluido, isFalse);
        expect(
          daRecebedora,
          isEmpty,
          reason: 'Outras unidades não têm acesso ao Controle de Prazos.',
        );
      });
    });

    test('retorno programado nao cumprido aponta as duas unidades', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final List<ProcessoRetornoProgramado> retornos =
            await repositorio.listarRetornosProgramados(
          FixtureProcessoSei.idProcessoPrincipal,
        );

        expect(retornos, hasLength(1));
        expect(retornos.single.cumprido, isFalse);
        expect(
          retornos.single.idUnidadeEnvio,
          FixtureProcessoSei.idUnidadeGeradora,
        );
        expect(
          retornos.single.idUnidadeRetorno,
          FixtureProcessoSei.idUnidadeRecebedora,
        );
        expect(retornos.single.unidadeEnvioSigla, isNotEmpty);
        expect(retornos.single.unidadeRetornoSigla, isNotEmpty);
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

      expect(
        await repositorio.listarAnotacoes(
          FixtureProcessoSei.idProcessoPrincipal,
          FixtureProcessoSei.idUnidadeGeradora,
        ),
        isEmpty,
      );
      expect(
        await repositorio.listarMarcadores(
          FixtureProcessoSei.idProcessoPrincipal,
        ),
        isEmpty,
      );
      expect(
        await repositorio.listarAcompanhamentos(
          FixtureProcessoSei.idProcessoPrincipal,
        ),
        isEmpty,
      );
      expect(
        await repositorio.listarRetornosProgramados(
          FixtureProcessoSei.idProcessoPrincipal,
        ),
        isEmpty,
      );
    });
  });
}
