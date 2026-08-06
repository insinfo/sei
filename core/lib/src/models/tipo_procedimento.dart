import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Tipo de processo configurado no catálogo nativo do SEI.
class TipoProcedimento extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'tipo_procedimento';
  static const String fqtn = '$schemaName.$tableName';

  static const String idCol = 'id_tipo_procedimento';
  static const String idFqCol = '$fqtn.$idCol';
  static const String idHipoteseLegalSugestaoCol = 'id_hipotese_legal_sugestao';
  static const String nomeCol = 'nome';
  static const String descricaoCol = 'descricao';
  static const String ativoCol = 'sin_ativo';
  static const String nivelAcessoSugestaoCol = 'sta_nivel_acesso_sugestao';
  static const String internoCol = 'sin_interno';
  static const String ouvidoriaCol = 'sin_ouvidoria';
  static const String individualCol = 'sin_individual';
  static const String grauSigiloSugestaoCol = 'sta_grau_sigilo_sugestao';
  static const String idPlanoTrabalhoCol = 'id_plano_trabalho';
  static const String ouvidoriaAnonimoCol = 'sin_ouvidoria_anonimo';

  TipoProcedimento({
    required this.idTipoProcedimento,
    required this.nome,
    required this.ativo,
    required this.nivelAcessoSugestao,
    required this.interno,
    required this.ouvidoria,
    required this.individual,
    required this.ouvidoriaAnonimo,
    this.idHipoteseLegalSugestao,
    this.descricao,
    this.grauSigiloSugestao,
    this.idPlanoTrabalho,
  });

  factory TipoProcedimento.fromMap(Map<String, dynamic> map) {
    return TipoProcedimento(
      idTipoProcedimento: map[idCol] as int,
      idHipoteseLegalSugestao: map[idHipoteseLegalSugestaoCol] as int?,
      nome: map[nomeCol] as String,
      descricao: map[descricaoCol] as String?,
      ativo: SeiCoreUtils.simNaoParaBool(
        map[ativoCol] as String,
        nomeCampo: ativoCol,
      ),
      nivelAcessoSugestao: map[nivelAcessoSugestaoCol] as String,
      interno: SeiCoreUtils.simNaoParaBool(
        map[internoCol] as String,
        nomeCampo: internoCol,
      ),
      ouvidoria: SeiCoreUtils.simNaoParaBool(
        map[ouvidoriaCol] as String,
        nomeCampo: ouvidoriaCol,
      ),
      individual: SeiCoreUtils.simNaoParaBool(
        map[individualCol] as String,
        nomeCampo: individualCol,
      ),
      grauSigiloSugestao: map[grauSigiloSugestaoCol] as String?,
      idPlanoTrabalho: map[idPlanoTrabalhoCol] as int?,
      ouvidoriaAnonimo: SeiCoreUtils.simNaoParaBool(
        map[ouvidoriaAnonimoCol] as String,
        nomeCampo: ouvidoriaAnonimoCol,
      ),
    );
  }

  final int idTipoProcedimento;
  final int? idHipoteseLegalSugestao;
  final String nome;
  final String? descricao;
  final bool ativo;
  final String nivelAcessoSugestao;
  final bool interno;
  final bool ouvidoria;
  final bool individual;
  final String? grauSigiloSugestao;
  final int? idPlanoTrabalho;
  final bool ouvidoriaAnonimo;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: idTipoProcedimento,
      idHipoteseLegalSugestaoCol: idHipoteseLegalSugestao,
      nomeCol: nome,
      descricaoCol: descricao,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
      nivelAcessoSugestaoCol: nivelAcessoSugestao,
      internoCol: SeiCoreUtils.boolParaSimNao(interno),
      ouvidoriaCol: SeiCoreUtils.boolParaSimNao(ouvidoria),
      individualCol: SeiCoreUtils.boolParaSimNao(individual),
      grauSigiloSugestaoCol: grauSigiloSugestao,
      idPlanoTrabalhoCol: idPlanoTrabalho,
      ouvidoriaAnonimoCol: SeiCoreUtils.boolParaSimNao(ouvidoriaAnonimo),
    };
  }
}
