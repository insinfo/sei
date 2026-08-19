import 'package:sei_core/sei_core.dart';
import 'package:test/test.dart';

void main() {
  group('usuario filtro', () {
    test('aceita filtro vazio com limite padrao', () {
      final filtro = UsuarioFiltro.fromMap(const <String, dynamic>{});

      expect(filtro.idOrgao, isNull);
      expect(filtro.limite, UsuarioFiltro.limitePadrao);
      expect(filtro.deslocamento, 0);
    });

    test('converte sin_ativo S/N em booleano', () {
      final filtro = UsuarioFiltro.fromMap(const <String, dynamic>{
        UsuarioFiltro.ativoCol: 'S',
      });

      expect(filtro.ativo, isTrue);
    });

    test('recusa limite acima do maximo', () {
      expect(
        () => UsuarioFiltro(limite: UsuarioFiltro.limiteMaximo + 1),
        throwsArgumentError,
      );
    });

    test('recusa deslocamento negativo', () {
      expect(
        () => UsuarioFiltro(deslocamento: -1),
        throwsArgumentError,
      );
    });

    test('recusa id_orgao nao positivo', () {
      expect(() => UsuarioFiltro(idOrgao: 0), throwsArgumentError);
    });
  });

  group('unidade filtro', () {
    test('aceita filtro vazio com limite padrao', () {
      final filtro = UnidadeFiltro.fromMap(const <String, dynamic>{});

      expect(filtro.limite, UnidadeFiltro.limitePadrao);
    });

    test('recusa limite acima do maximo', () {
      expect(
        () => UnidadeFiltro(limite: UnidadeFiltro.limiteMaximo + 1),
        throwsArgumentError,
      );
    });
  });

  group('orgao filtro', () {
    test('aceita filtro vazio com limite padrao', () {
      final filtro = OrgaoFiltro.fromMap(const <String, dynamic>{});

      expect(filtro.limite, OrgaoFiltro.limitePadrao);
      expect(filtro.sigla, isNull);
    });

    test('recusa deslocamento negativo', () {
      expect(
        () => OrgaoFiltro(deslocamento: -1),
        throwsArgumentError,
      );
    });
  });
}
