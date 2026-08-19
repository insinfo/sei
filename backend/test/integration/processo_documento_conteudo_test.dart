import 'package:angel3_container/angel3_container.dart';
import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';
import '../support/fixture_processo_sei.dart';

void main() {
  group('conteudo de documento do processo', () {
    late EscopoRepositorioTeste escopo;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSei();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    test('documento interno traz o corpo html, sem metadado de anexo',
        () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final ProcessoDocumentoConteudo? conteudo =
            await repositorio.obterConteudoDocumento(
          FixtureProcessoSei.idProcessoPrincipal,
          FixtureProcessoSei.idDocumentoInterno,
        );

        expect(conteudo, isNotNull);
        expect(conteudo!.estado, EstadoDocumento.interno);
        expect(conteudo.possuiVersoes, isTrue);
        expect(conteudo.conteudoHtml, contains('Conteúdo de fixture'));
        expect(
          conteudo.anexoNome,
          isNull,
          reason: 'Documento interno não tem linha em anexo.',
        );
        expect(conteudo.anexoHash, isNull);
      });
    });

    test('documento externo traz o ponteiro do anexo, sem corpo html',
        () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final ProcessoDocumentoConteudo? conteudo =
            await repositorio.obterConteudoDocumento(
          FixtureProcessoSei.idProcessoPrincipal,
          FixtureProcessoSei.idDocumentoExterno,
        );

        expect(conteudo, isNotNull);
        expect(conteudo!.estado, EstadoDocumento.externo);
        expect(
          conteudo.possuiVersoes,
          isFalse,
          reason: 'Nenhum documento externo tem controle de versões.',
        );
        expect(conteudo.anexoNome, 'oficio_fixture.pdf');
        expect(conteudo.anexoTamanho, 12345);
        expect(conteudo.anexoHash, hasLength(32));
        expect(
          conteudo.conteudoHtml,
          isNull,
          reason: 'Documento externo não tem linha em documento_conteudo.',
        );
      });
    });

    test('documento de outro processo nao e retornado', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final ProcessoDocumentoConteudo? conteudo =
            await repositorio.obterConteudoDocumento(
          FixtureProcessoSei.idProcessoRelacionado,
          FixtureProcessoSei.idDocumentoInterno,
        );

        expect(
          conteudo,
          isNull,
          reason: 'O filtro por idProcesso evita consultar um documento de '
              'outro processo por engano.',
        );
      });
    });

    test('documento inexistente retorna nulo', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        await FixtureProcessoSei.inserir(conexao);
        final ProcessoDetalheRepository repositorio =
            container.make<ProcessoDetalheRepository>();

        final ProcessoDocumentoConteudo? conteudo =
            await repositorio.obterConteudoDocumento(
          FixtureProcessoSei.idProcessoPrincipal,
          999999999,
        );

        expect(conteudo, isNull);
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
        await repositorio.obterConteudoDocumento(
          FixtureProcessoSei.idProcessoPrincipal,
          FixtureProcessoSei.idDocumentoInterno,
        ),
        isNull,
      );
      expect(
        await repositorio.obterConteudoDocumento(
          FixtureProcessoSei.idProcessoPrincipal,
          FixtureProcessoSei.idDocumentoExterno,
        ),
        isNull,
      );
    });
  });
}
