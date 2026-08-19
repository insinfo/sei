import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Unidade organizacional do SEI, persistida em `sei_5_0_0.unidade`.
///
/// Diferente de [UnidadeResumo] (projeção de leitura usada pelo contexto de
/// desenvolvimento), este model é a entidade completa e gravável, usada pelo
/// cadastro de unidades.
///
/// O identificador é atribuído pela aplicação, e não por sequência do banco:
/// `id_unidade` não possui `DEFAULT` na Base de Referência. Por isso ele
/// participa de [toInsertMap] e é obrigatório na construção.
///
/// Os padrões `sin_*` usados como valor inicial em [Unidade.nova] espelham a
/// única unidade real disponível localmente (`SELECT sin_mail_pendencia,
/// sin_envio_processo, sin_arquivamento, sin_ouvidoria, sin_protocolo FROM
/// unidade`): envio de processo habilitado, os demais desabilitados.
class Unidade extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'unidade';
  static const String fqtn = '$schemaName.$tableName';

  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idOrgaoCol = 'id_orgao';
  static const String idOrgaoFqCol = '$fqtn.$idOrgaoCol';
  static const String idContatoCol = 'id_contato';
  static const String idContatoFqCol = '$fqtn.$idContatoCol';
  static const String idOrigemCol = 'id_origem';
  static const String idOrigemFqCol = '$fqtn.$idOrigemCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';
  static const String siglaCol = 'sigla';
  static const String siglaFqCol = '$fqtn.$siglaCol';
  static const String descricaoCol = 'descricao';
  static const String descricaoFqCol = '$fqtn.$descricaoCol';
  static const String mailPendenciaCol = 'sin_mail_pendencia';
  static const String mailPendenciaFqCol = '$fqtn.$mailPendenciaCol';
  static const String envioProcessoCol = 'sin_envio_processo';
  static const String envioProcessoFqCol = '$fqtn.$envioProcessoCol';
  static const String arquivamentoCol = 'sin_arquivamento';
  static const String arquivamentoFqCol = '$fqtn.$arquivamentoCol';
  static const String ouvidoriaCol = 'sin_ouvidoria';
  static const String ouvidoriaFqCol = '$fqtn.$ouvidoriaCol';
  static const String protocoloCol = 'sin_protocolo';
  static const String protocoloFqCol = '$fqtn.$protocoloCol';
  static const String codigoSeiCol = 'codigo_sei';
  static const String codigoSeiFqCol = '$fqtn.$codigoSeiCol';
  static const String idxUnidadeCol = 'idx_unidade';
  static const String idxUnidadeFqCol = '$fqtn.$idxUnidadeCol';
  static const String idUnidadeFederacaoCol = 'id_unidade_federacao';
  static const String idUnidadeFederacaoFqCol = '$fqtn.$idUnidadeFederacaoCol';

  Unidade({
    required this.idUnidade,
    required this.idOrgao,
    required this.idContato,
    required this.sigla,
    required this.descricao,
    this.ativo = true,
    this.idOrigem,
    this.mailPendencia = false,
    this.envioProcesso = true,
    this.arquivamento = false,
    this.ouvidoria = false,
    this.protocolo = false,
    this.codigoSei,
    this.idxUnidade,
    this.idUnidadeFederacao,
  });

  factory Unidade.fromMap(Map<String, dynamic> map) {
    return Unidade(
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      idOrgao: SeiCoreUtils.inteiro(
        map[idOrgaoCol],
        nomeCampo: idOrgaoCol,
      ),
      idContato: SeiCoreUtils.inteiro(
        map[idContatoCol],
        nomeCampo: idContatoCol,
      ),
      sigla: map[siglaCol] as String,
      descricao: map[descricaoCol] as String,
      ativo: SeiCoreUtils.simNaoParaBool(
        map[ativoCol] as String,
        nomeCampo: ativoCol,
      ),
      idOrigem: map[idOrigemCol] as String?,
      mailPendencia: SeiCoreUtils.simNaoParaBool(
        map[mailPendenciaCol] as String,
        nomeCampo: mailPendenciaCol,
      ),
      envioProcesso: SeiCoreUtils.simNaoParaBool(
        map[envioProcessoCol] as String,
        nomeCampo: envioProcessoCol,
      ),
      arquivamento: SeiCoreUtils.simNaoParaBool(
        map[arquivamentoCol] as String,
        nomeCampo: arquivamentoCol,
      ),
      ouvidoria: SeiCoreUtils.simNaoParaBool(
        map[ouvidoriaCol] as String,
        nomeCampo: ouvidoriaCol,
      ),
      protocolo: SeiCoreUtils.simNaoParaBool(
        map[protocoloCol] as String,
        nomeCampo: protocoloCol,
      ),
      codigoSei: map[codigoSeiCol] as String?,
      idxUnidade: map[idxUnidadeCol] as String?,
      idUnidadeFederacao: map[idUnidadeFederacaoCol] as String?,
    );
  }

  /// Identificador da unidade, atribuído pela aplicação.
  int idUnidade;
  int idOrgao;
  int idContato;
  String? idOrigem;
  bool ativo;
  String sigla;
  String descricao;
  bool mailPendencia;
  bool envioProcesso;
  bool arquivamento;
  bool ouvidoria;
  bool protocolo;
  String? codigoSei;
  String? idxUnidade;
  String? idUnidadeFederacao;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idUnidadeCol: idUnidade,
      idOrgaoCol: idOrgao,
      idContatoCol: idContato,
      idOrigemCol: idOrigem,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
      siglaCol: sigla,
      descricaoCol: descricao,
      mailPendenciaCol: SeiCoreUtils.boolParaSimNao(mailPendencia),
      envioProcessoCol: SeiCoreUtils.boolParaSimNao(envioProcesso),
      arquivamentoCol: SeiCoreUtils.boolParaSimNao(arquivamento),
      ouvidoriaCol: SeiCoreUtils.boolParaSimNao(ouvidoria),
      protocoloCol: SeiCoreUtils.boolParaSimNao(protocolo),
      codigoSeiCol: codigoSei,
      idxUnidadeCol: idxUnidade,
      idUnidadeFederacaoCol: idUnidadeFederacao,
    };
  }

  /// Mapa de inserção com todas as colunas, inclusive a chave.
  ///
  /// A chave permanece porque o SEI atribui o identificador na aplicação; a
  /// coluna não tem `DEFAULT` no banco.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização cadastral, sem a chave, o órgão e o contato.
  @override
  Map<String, dynamic> toUpdateMap() {
    return <String, dynamic>{
      siglaCol: sigla,
      descricaoCol: descricao,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
      mailPendenciaCol: SeiCoreUtils.boolParaSimNao(mailPendencia),
      envioProcessoCol: SeiCoreUtils.boolParaSimNao(envioProcesso),
      arquivamentoCol: SeiCoreUtils.boolParaSimNao(arquivamento),
      ouvidoriaCol: SeiCoreUtils.boolParaSimNao(ouvidoria),
      protocoloCol: SeiCoreUtils.boolParaSimNao(protocolo),
      codigoSeiCol: codigoSei,
    };
  }
}
