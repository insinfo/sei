import 'package:sei_core/sei_core.dart';
import 'package:test/test.dart';

void main() {
  group('usuario', () {
    Usuario criar({String? senhaHash}) {
      return Usuario(
        idUsuario: 1,
        idContato: 2,
        idOrgao: 3,
        sigla: 'teste',
        nome: 'Usuário de Teste',
        senhaHash: senhaHash,
      );
    }

    test('toMap nunca inclui o hash da senha', () {
      final usuario = criar(senhaHash: r'$2a$12$hashfalsoparaoteste');

      expect(usuario.toMap().containsKey(Usuario.senhaCol), isFalse);
    });

    test('toInsertMap inclui a chave e o hash da senha', () {
      final usuario = criar(senhaHash: r'$2a$12$hashfalsoparaoteste');
      final mapa = usuario.toInsertMap();

      expect(mapa[Usuario.idUsuarioCol], 1);
      expect(mapa[Usuario.senhaCol], r'$2a$12$hashfalsoparaoteste');
    });

    test('toUpdateMap cobre so os campos cadastrais', () {
      final usuario = criar(senhaHash: r'$2a$12$hashfalsoparaoteste')
        ..nome = 'Novo Nome'
        ..sigla = 'novasigla'
        ..ativo = false;
      final mapa = usuario.toUpdateMap();

      expect(mapa, <String, dynamic>{
        Usuario.siglaCol: 'novasigla',
        Usuario.nomeCol: 'Novo Nome',
        Usuario.ativoCol: 'N',
      });
      expect(mapa.containsKey(Usuario.senhaCol), isFalse);
      expect(mapa.containsKey(Usuario.idUsuarioCol), isFalse);
    });

    test('mapaAtualizacaoSenha grava somente o hash', () {
      final mapa = Usuario.mapaAtualizacaoSenha('novohash');

      expect(mapa, <String, dynamic>{Usuario.senhaCol: 'novohash'});
    });

    test('nomeRegistroCivil usa o nome quando nao informado', () {
      final usuario = criar();

      expect(usuario.nomeRegistroCivil, 'Usuário de Teste');
    });

    test('fromMap ignora senha em branco', () {
      final usuario = Usuario.fromMap(<String, dynamic>{
        Usuario.idUsuarioCol: 1,
        Usuario.idContatoCol: 2,
        Usuario.idOrgaoCol: 3,
        Usuario.idOrigemCol: null,
        Usuario.ativoCol: 'S',
        Usuario.siglaCol: 'teste',
        Usuario.nomeCol: 'Usuário de Teste',
        Usuario.idxUsuarioCol: null,
        Usuario.staTipoCol: '0',
        Usuario.senhaCol: '   ',
        Usuario.nomeRegistroCivilCol: 'Usuário de Teste',
        Usuario.nomeSocialCol: null,
        Usuario.idUsuarioFederacaoCol: null,
        Usuario.sinGovBrCol: 'N',
        Usuario.dthTermoUsoCol: null,
        Usuario.dthPoliticaPrivacidadeCol: null,
      });

      expect(usuario.senhaHash, isNull);
    });
  });

  group('contato', () {
    test('TipoContato.fromId resolve os seis valores conhecidos', () {
      expect(TipoContato.fromId(1), TipoContato.usuarios);
      expect(TipoContato.fromId(5), TipoContato.unidades);
      expect(TipoContato.fromId(6), TipoContato.orgaos);
    });

    test('TipoContato.fromId recusa valor desconhecido', () {
      expect(() => TipoContato.fromId(99), throwsFormatException);
    });

    test('NaturezaContato.fromValue resolve F e J', () {
      expect(NaturezaContato.fromValue('F'), NaturezaContato.fisica);
      expect(NaturezaContato.fromValue('J'), NaturezaContato.juridica);
    });

    test('NaturezaContato.fromValue recusa valor desconhecido', () {
      expect(() => NaturezaContato.fromValue('X'), throwsFormatException);
    });

    test('toInsertMap do contato inclui a chave', () {
      final contato = Contato(
        idContato: 10,
        idContatoAssociado: 10,
        tipoContato: TipoContato.orgaos,
        nome: 'Órgão de Teste',
        natureza: NaturezaContato.juridica,
      );

      expect(contato.toInsertMap()[Contato.idContatoCol], 10);
      expect(contato.toUpdateMap().containsKey(Contato.idContatoCol), isFalse);
    });
  });
}
