import 'package:sei_core/sei_core.dart';
import 'package:test/test.dart';

void main() {
  group('tipo procedimento', () {
    test('converte dominio sim nao', () {
      final tipo = TipoProcedimento.fromMap(<String, dynamic>{
        TipoProcedimento.idCol: 7,
        TipoProcedimento.idHipoteseLegalSugestaoCol: null,
        TipoProcedimento.nomeCol: 'Licenciamento',
        TipoProcedimento.descricaoCol: 'Processo de teste.',
        TipoProcedimento.ativoCol: 'S',
        TipoProcedimento.nivelAcessoSugestaoCol: '0',
        TipoProcedimento.internoCol: 'N',
        TipoProcedimento.ouvidoriaCol: 'N',
        TipoProcedimento.individualCol: 'S',
        TipoProcedimento.grauSigiloSugestaoCol: null,
        TipoProcedimento.idPlanoTrabalhoCol: null,
        TipoProcedimento.ouvidoriaAnonimoCol: 'N',
      });

      expect(tipo.ativo, isTrue);
      expect(tipo.interno, isFalse);
      expect(tipo.individual, isTrue);
      expect(tipo.toMap()[TipoProcedimento.ativoCol], 'S');
    });

    test('recusa valor de dominio invalido', () {
      expect(
        () => SeiCoreUtils.simNaoParaBool('X', nomeCampo: 'sin_ativo'),
        throwsFormatException,
      );
    });

    test('prepara mapas de escrita sem a chave primaria', () {
      final TipoProcedimento tipo = TipoProcedimento.novo();

      expect(tipo.idTipoProcedimento, 0);
      expect(tipo.clone(), tipo);
      expect(tipo.toInsertMap(), isNot(contains(TipoProcedimento.idCol)));
      expect(tipo.toUpdateMap(), isNot(contains(TipoProcedimento.idCol)));
    });
  });
}
