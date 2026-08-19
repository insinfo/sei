import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Órgão do SEI, persistido em `sei_5_0_0.orgao`.
///
/// O identificador é atribuído pela aplicação, e não por sequência do banco:
/// `id_orgao` não possui `DEFAULT` na Base de Referência. Por isso ele
/// participa de [toInsertMap] e é obrigatório na construção.
///
/// **`idUnidade` (unidade raiz) começa nulo.** A coluna é nula na Base de
/// Referência local (o único órgão real, "ABC", tem `id_unidade` nulo), o
/// que resolve o problema de ordem de criação: o cadastro deste projeto
/// sempre cria o órgão primeiro com `id_unidade = null` e as unidades depois
/// (cada uma referenciando o órgão por `id_orgao`); vincular uma unidade como
/// raiz do órgão é uma operação futura, fora do escopo desta rodada.
///
/// **`staCorretorOrtografico` é opaco.** Só um valor (`'B'`) existe na Base
/// de Referência local, insuficiente para provar um domínio fechado; o valor
/// é preservado cru e usado como padrão de [Orgao.nova], sem virar enum (ver
/// `backend/docs/evidencias_processo_detalhe.md`).
class Orgao extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'orgao';
  static const String fqtn = '$schemaName.$tableName';

  static const String idOrgaoCol = 'id_orgao';
  static const String idOrgaoFqCol = '$fqtn.$idOrgaoCol';
  static const String idContatoCol = 'id_contato';
  static const String idContatoFqCol = '$fqtn.$idContatoCol';
  static const String siglaCol = 'sigla';
  static const String siglaFqCol = '$fqtn.$siglaCol';
  static const String descricaoCol = 'descricao';
  static const String descricaoFqCol = '$fqtn.$descricaoCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';
  static const String timbreCol = 'timbre';
  static const String timbreFqCol = '$fqtn.$timbreCol';
  static const String envioProcessoCol = 'sin_envio_processo';
  static const String envioProcessoFqCol = '$fqtn.$envioProcessoCol';
  static const String numeracaoCol = 'numeracao';
  static const String numeracaoFqCol = '$fqtn.$numeracaoCol';
  static const String servidorCorretorOrtograficoCol =
      'servidor_corretor_ortografico';
  static const String servidorCorretorOrtograficoFqCol =
      '$fqtn.$servidorCorretorOrtograficoCol';
  static const String staCorretorOrtograficoCol = 'sta_corretor_ortografico';
  static const String staCorretorOrtograficoFqCol =
      '$fqtn.$staCorretorOrtograficoCol';
  static const String publicacaoCol = 'sin_publicacao';
  static const String publicacaoFqCol = '$fqtn.$publicacaoCol';
  static const String codigoSeiCol = 'codigo_sei';
  static const String codigoSeiFqCol = '$fqtn.$codigoSeiCol';
  static const String idxOrgaoCol = 'idx_orgao';
  static const String idxOrgaoFqCol = '$fqtn.$idxOrgaoCol';
  static const String federacaoEnvioCol = 'sin_federacao_envio';
  static const String federacaoEnvioFqCol = '$fqtn.$federacaoEnvioCol';
  static const String federacaoRecebimentoCol = 'sin_federacao_recebimento';
  static const String federacaoRecebimentoFqCol =
      '$fqtn.$federacaoRecebimentoCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idOrgaoFederacaoCol = 'id_orgao_federacao';
  static const String idOrgaoFederacaoFqCol = '$fqtn.$idOrgaoFederacaoCol';
  static const String consultaProcessualCol = 'sin_consulta_processual';
  static const String consultaProcessualFqCol = '$fqtn.$consultaProcessualCol';

  /// Único valor observado em `sta_corretor_ortografico` na Base de
  /// Referência local; significado não comprovado (ver Dartdoc da classe).
  static const String staCorretorOrtograficoPadrao = 'B';

  Orgao({
    required this.idOrgao,
    required this.idContato,
    required this.sigla,
    required this.descricao,
    this.ativo = true,
    this.timbre,
    this.envioProcesso = true,
    this.numeracao,
    this.servidorCorretorOrtografico,
    this.staCorretorOrtografico = staCorretorOrtograficoPadrao,
    this.publicacao = true,
    this.codigoSei,
    this.idxOrgao,
    this.federacaoEnvio = false,
    this.federacaoRecebimento = false,
    this.idUnidade,
    this.idOrgaoFederacao,
    this.consultaProcessual = false,
  });

  factory Orgao.fromMap(Map<String, dynamic> map) {
    return Orgao(
      idOrgao: SeiCoreUtils.inteiro(map[idOrgaoCol], nomeCampo: idOrgaoCol),
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
      timbre: map[timbreCol] as String?,
      envioProcesso: SeiCoreUtils.simNaoParaBool(
        map[envioProcessoCol] as String,
        nomeCampo: envioProcessoCol,
      ),
      numeracao: map[numeracaoCol] as String?,
      servidorCorretorOrtografico:
          map[servidorCorretorOrtograficoCol] as String?,
      staCorretorOrtografico: (map[staCorretorOrtograficoCol] as String).trim(),
      publicacao: SeiCoreUtils.simNaoParaBool(
        map[publicacaoCol] as String,
        nomeCampo: publicacaoCol,
      ),
      codigoSei: map[codigoSeiCol] as String?,
      idxOrgao: map[idxOrgaoCol] as String?,
      federacaoEnvio: SeiCoreUtils.simNaoParaBool(
        map[federacaoEnvioCol] as String,
        nomeCampo: federacaoEnvioCol,
      ),
      federacaoRecebimento: SeiCoreUtils.simNaoParaBool(
        map[federacaoRecebimentoCol] as String,
        nomeCampo: federacaoRecebimentoCol,
      ),
      idUnidade: map[idUnidadeCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUnidadeCol],
              nomeCampo: idUnidadeCol,
            ),
      idOrgaoFederacao: map[idOrgaoFederacaoCol] as String?,
      consultaProcessual: SeiCoreUtils.simNaoParaBool(
        map[consultaProcessualCol] as String,
        nomeCampo: consultaProcessualCol,
      ),
    );
  }

  /// Identificador do órgão, atribuído pela aplicação.
  int idOrgao;
  int idContato;
  String sigla;
  String descricao;
  bool ativo;
  String? timbre;
  bool envioProcesso;
  String? numeracao;
  String? servidorCorretorOrtografico;

  /// Código opaco (ver Dartdoc da classe); não é um domínio fechado provado.
  String staCorretorOrtografico;
  bool publicacao;
  String? codigoSei;
  String? idxOrgao;
  bool federacaoEnvio;
  bool federacaoRecebimento;

  /// Unidade raiz do órgão; nula até que uma unidade seja vinculada como raiz
  /// (ver Dartdoc da classe).
  int? idUnidade;
  String? idOrgaoFederacao;
  bool consultaProcessual;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idOrgaoCol: idOrgao,
      idContatoCol: idContato,
      siglaCol: sigla,
      descricaoCol: descricao,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
      timbreCol: timbre,
      envioProcessoCol: SeiCoreUtils.boolParaSimNao(envioProcesso),
      numeracaoCol: numeracao,
      servidorCorretorOrtograficoCol: servidorCorretorOrtografico,
      staCorretorOrtograficoCol: staCorretorOrtografico,
      publicacaoCol: SeiCoreUtils.boolParaSimNao(publicacao),
      codigoSeiCol: codigoSei,
      idxOrgaoCol: idxOrgao,
      federacaoEnvioCol: SeiCoreUtils.boolParaSimNao(federacaoEnvio),
      federacaoRecebimentoCol:
          SeiCoreUtils.boolParaSimNao(federacaoRecebimento),
      idUnidadeCol: idUnidade,
      idOrgaoFederacaoCol: idOrgaoFederacao,
      consultaProcessualCol: SeiCoreUtils.boolParaSimNao(consultaProcessual),
    };
  }

  /// Mapa de inserção com todas as colunas, inclusive a chave.
  ///
  /// A chave permanece porque o SEI atribui o identificador na aplicação; a
  /// coluna não tem `DEFAULT` no banco.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização cadastral, sem a chave, o contato e a unidade raiz.
  @override
  Map<String, dynamic> toUpdateMap() {
    return <String, dynamic>{
      siglaCol: sigla,
      descricaoCol: descricao,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
      envioProcessoCol: SeiCoreUtils.boolParaSimNao(envioProcesso),
      numeracaoCol: numeracao,
      servidorCorretorOrtograficoCol: servidorCorretorOrtografico,
      staCorretorOrtograficoCol: staCorretorOrtografico,
      publicacaoCol: SeiCoreUtils.boolParaSimNao(publicacao),
      codigoSeiCol: codigoSei,
      federacaoEnvioCol: SeiCoreUtils.boolParaSimNao(federacaoEnvio),
      federacaoRecebimentoCol:
          SeiCoreUtils.boolParaSimNao(federacaoRecebimento),
      consultaProcessualCol: SeiCoreUtils.boolParaSimNao(consultaProcessual),
    };
  }
}
