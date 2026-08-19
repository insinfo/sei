import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Item de Base de Conhecimento, gravável em `base_conhecimento`.
///
/// A Base de Conhecimento é vinculada a um ou mais **tipos de processo**, não
/// a um processo específico — o vínculo vive em
/// [BaseConhecimentoTipoProcedimento] (`rel_base_conhec_tipo_proced`). É por
/// isso que o SEI mostra o ícone "B" ao lado de qualquer processo cujo tipo
/// tenha uma base associada, e não apenas de um processo específico.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap].
///
/// **Lacuna registrada em `backend/docs/evidencias_processo_detalhe.md`:**
/// `base_conhecimento` tem zero linhas tanto na Base de Referência quanto no
/// dump histórico local. Sem nenhum dado real para cruzar, [estado] e
/// [documento] permanecem código bruto de `sta_estado` e `sta_documento`,
/// sem enum — ao contrário de `bloco.sta_estado`/`sta_tipo`, que tiveram
/// linhas reais para comprovar o domínio.
class BaseConhecimento extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'base_conhecimento';
  static const String fqtn = '$schemaName.$tableName';

  static const String idBaseConhecimentoCol = 'id_base_conhecimento';
  static const String idBaseConhecimentoFqCol = '$fqtn.$idBaseConhecimentoCol';
  static const String idBaseConhecimentoAgrupadorCol =
      'id_base_conhecimento_agrupador';
  static const String idBaseConhecimentoAgrupadorFqCol =
      '$fqtn.$idBaseConhecimentoAgrupadorCol';
  static const String idBaseConhecimentoOrigemCol =
      'id_base_conhecimento_origem';
  static const String idBaseConhecimentoOrigemFqCol =
      '$fqtn.$idBaseConhecimentoOrigemCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idDocumentoEdocCol = 'id_documento_edoc';
  static const String idDocumentoEdocFqCol = '$fqtn.$idDocumentoEdocCol';
  static const String idUsuarioGeradorCol = 'id_usuario_gerador';
  static const String idUsuarioGeradorFqCol = '$fqtn.$idUsuarioGeradorCol';
  static const String idUsuarioLiberacaoCol = 'id_usuario_liberacao';
  static const String idUsuarioLiberacaoFqCol = '$fqtn.$idUsuarioLiberacaoCol';
  static const String idConjuntoEstilosCol = 'id_conjunto_estilos';
  static const String idConjuntoEstilosFqCol = '$fqtn.$idConjuntoEstilosCol';
  static const String descricaoCol = 'descricao';
  static const String descricaoFqCol = '$fqtn.$descricaoCol';
  static const String conteudoCol = 'conteudo';
  static const String conteudoFqCol = '$fqtn.$conteudoCol';
  static const String estadoCol = 'sta_estado';
  static const String estadoFqCol = '$fqtn.$estadoCol';
  static const String dataGeracaoCol = 'dth_geracao';
  static const String dataGeracaoFqCol = '$fqtn.$dataGeracaoCol';
  static const String dataLiberacaoCol = 'dth_liberacao';
  static const String dataLiberacaoFqCol = '$fqtn.$dataLiberacaoCol';
  static const String documentoCol = 'sta_documento';
  static const String documentoFqCol = '$fqtn.$documentoCol';

  BaseConhecimento({
    required this.idBaseConhecimento,
    required this.idUnidade,
    required this.idUsuarioGerador,
    required this.descricao,
    required this.estado,
    required this.dataGeracao,
    required this.documento,
    this.idBaseConhecimentoAgrupador,
    this.idBaseConhecimentoOrigem,
    this.idDocumentoEdoc,
    this.idUsuarioLiberacao,
    this.idConjuntoEstilos,
    this.conteudo,
    this.dataLiberacao,
  });

  factory BaseConhecimento.fromMap(Map<String, dynamic> map) {
    return BaseConhecimento(
      idBaseConhecimento: SeiCoreUtils.inteiro(
        map[idBaseConhecimentoCol],
        nomeCampo: idBaseConhecimentoCol,
      ),
      idBaseConhecimentoAgrupador: map[idBaseConhecimentoAgrupadorCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idBaseConhecimentoAgrupadorCol],
              nomeCampo: idBaseConhecimentoAgrupadorCol,
            ),
      idBaseConhecimentoOrigem: map[idBaseConhecimentoOrigemCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idBaseConhecimentoOrigemCol],
              nomeCampo: idBaseConhecimentoOrigemCol,
            ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      idDocumentoEdoc: map[idDocumentoEdocCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idDocumentoEdocCol],
              nomeCampo: idDocumentoEdocCol,
            ),
      idUsuarioGerador: SeiCoreUtils.inteiro(
        map[idUsuarioGeradorCol],
        nomeCampo: idUsuarioGeradorCol,
      ),
      idUsuarioLiberacao: map[idUsuarioLiberacaoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUsuarioLiberacaoCol],
              nomeCampo: idUsuarioLiberacaoCol,
            ),
      idConjuntoEstilos: map[idConjuntoEstilosCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idConjuntoEstilosCol],
              nomeCampo: idConjuntoEstilosCol,
            ),
      descricao: map[descricaoCol] as String,
      conteudo: map[conteudoCol] as String?,
      estado: (map[estadoCol] as String).trim(),
      dataGeracao: SeiCoreUtils.dataHoraLocal(
        map[dataGeracaoCol],
        nomeCampo: dataGeracaoCol,
      ),
      dataLiberacao: map[dataLiberacaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataLiberacaoCol],
              nomeCampo: dataLiberacaoCol,
            ),
      documento: (map[documentoCol] as String).trim(),
    );
  }

  /// Identificador da base de conhecimento, atribuído pela aplicação.
  final int idBaseConhecimento;

  /// Base "guarda-chuva" quando esta é uma variação de outra, para o mesmo
  /// assunto.
  final int? idBaseConhecimentoAgrupador;

  /// Base da qual esta foi copiada, quando aplicável.
  final int? idBaseConhecimentoOrigem;

  /// Unidade geradora da base de conhecimento.
  final int idUnidade;

  /// Documento do editor SEI que carrega o conteúdo, quando ele não vive em
  /// [conteudo] diretamente.
  final int? idDocumentoEdoc;

  final int idUsuarioGerador;
  final int? idUsuarioLiberacao;
  final int? idConjuntoEstilos;
  final String descricao;

  /// Corpo HTML da base de conhecimento, quando não delegado a
  /// [idDocumentoEdoc].
  final String? conteudo;

  /// Código bruto de `sta_estado`. Sem linha real para cruzar; ver a lacuna
  /// registrada no Dartdoc da classe.
  final String estado;

  final DateTime dataGeracao;
  final DateTime? dataLiberacao;

  /// Código bruto de `sta_documento`. Sem linha real para cruzar; ver a
  /// lacuna registrada no Dartdoc da classe.
  final String documento;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idBaseConhecimentoCol: idBaseConhecimento,
      idBaseConhecimentoAgrupadorCol: idBaseConhecimentoAgrupador,
      idBaseConhecimentoOrigemCol: idBaseConhecimentoOrigem,
      idUnidadeCol: idUnidade,
      idDocumentoEdocCol: idDocumentoEdoc,
      idUsuarioGeradorCol: idUsuarioGerador,
      idUsuarioLiberacaoCol: idUsuarioLiberacao,
      idConjuntoEstilosCol: idConjuntoEstilos,
      descricaoCol: descricao,
      conteudoCol: conteudo,
      estadoCol: estado,
      dataGeracaoCol: dataGeracao,
      dataLiberacaoCol: dataLiberacao,
      documentoCol: documento,
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idBaseConhecimentoCol);
    return mapa;
  }
}
