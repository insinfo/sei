import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';

void main() {
  group('sip referencia repository', () {
    late EscopoRepositorioTeste escopo;
    late SipReferenciaRepository sipReferenciaRepository;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSip();
      sipReferenciaRepository = escopo.make<SipReferenciaRepository>();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    test('le sistemas ativos sem expor credenciais ou permissoes', () async {
      final sistemas = await sipReferenciaRepository.listarSistemasAtivos();

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

    test('resolve perfis vigentes e recursos liberados na unidade raiz',
        () async {
      final autorizacao = await sipReferenciaRepository.resolverAutorizacao(
        100000001,
        110000000,
      );

      expect(autorizacao.idUsuario, 100000001);
      expect(autorizacao.idUnidade, 110000000);
      expect(autorizacao.perfis, hasLength(8));
      expect(
        autorizacao.perfis.every((PerfilAtivo perfil) => perfil.perfil.ativo),
        isTrue,
      );
      expect(
        autorizacao.perfis.every((PerfilAtivo perfil) =>
            perfil.tipoPermissao == TipoPermissao.naoDelegavel),
        isTrue,
      );
      expect(
        autorizacao.perfis.every((PerfilAtivo perfil) => !perfil.subunidades),
        isTrue,
      );
      expect(
        autorizacao.perfis
            .every((PerfilAtivo perfil) => perfil.dataFim == null),
        isTrue,
      );
      expect(autorizacao.recursos, hasLength(1544));
      final idsRecursos = autorizacao.recursos
          .map((RecursoSip recurso) =>
              '${recurso.idSistema}-${recurso.idRecurso}')
          .toList();
      expect(
        idsRecursos.length,
        idsRecursos.toSet().length,
        reason:
            'os recursos devem vir deduplicados mesmo vindo de perfis diferentes',
      );
    });

    test(
        'restringe a autorizacao a um unico sistema quando idSistema e informado',
        () async {
      final autorizacao = await sipReferenciaRepository.resolverAutorizacao(
        100000001,
        110000000,
        idSistema: 100000100,
      );

      expect(autorizacao.perfis, hasLength(5));
      expect(
        autorizacao.perfis.every(
            (PerfilAtivo perfil) => perfil.perfil.idSistema == 100000100),
        isTrue,
      );
      expect(autorizacao.recursos, hasLength(1314));
      expect(
        autorizacao.recursos
            .every((RecursoSip recurso) => recurso.idSistema == 100000100),
        isTrue,
      );
    });

    test('nao encontra autorizacao para unidade sem permissao concedida',
        () async {
      final autorizacao = await sipReferenciaRepository.resolverAutorizacao(
        100000001,
        110000001,
      );

      expect(autorizacao.perfis, isEmpty);
      expect(autorizacao.recursos, isEmpty);
    });
  });
}
