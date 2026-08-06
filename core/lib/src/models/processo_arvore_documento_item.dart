import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Documento exibido na árvore de um processo, preservando a ordem da relação.
///
/// A associação é lida de `rel_protocolo_protocolo`; o item não presume o
/// significado de códigos de estado que pertencem às regras de negócio do SEI.
class ProcessoArvoreDocumentoItem extends BaseModel {
  static const String schemaName = 'public';

  static const String relacaoFqtn = '$schemaName.rel_protocolo_protocolo';
  static const String documentoFqtn = '$schemaName.documento';
  static const String protocoloFqtn = '$schemaName.protocolo';
  static const String serieFqtn = '$schemaName.serie';
  static const String unidadeFqtn = '$schemaName.unidade';

  static const String relacaoIdSourceCol = 'id_rel_protocolo_protocolo';
  static const String relacaoIdFqCol = '$relacaoFqtn.$relacaoIdSourceCol';
  static const String relacaoIdProtocoloPaiSourceCol = 'id_protocolo_1';
  static const String relacaoIdProtocoloPaiFqCol =
      '$relacaoFqtn.$relacaoIdProtocoloPaiSourceCol';
  static const String relacaoIdProtocoloFilhoSourceCol = 'id_protocolo_2';
  static const String relacaoIdProtocoloFilhoFqCol =
      '$relacaoFqtn.$relacaoIdProtocoloFilhoSourceCol';
  static const String relacaoEstadoAssociacaoSourceCol = 'sta_associacao';
  static const String relacaoEstadoAssociacaoFqCol =
      '$relacaoFqtn.$relacaoEstadoAssociacaoSourceCol';
  static const String relacaoDataAssociacaoSourceCol = 'dth_associacao';
  static const String relacaoDataAssociacaoFqCol =
      '$relacaoFqtn.$relacaoDataAssociacaoSourceCol';
  static const String relacaoSequenciaSourceCol = 'sequencia';
  static const String relacaoSequenciaFqCol =
      '$relacaoFqtn.$relacaoSequenciaSourceCol';
  static const String relacaoCienciaSourceCol = 'sin_ciencia';
  static const String relacaoCienciaFqCol =
      '$relacaoFqtn.$relacaoCienciaSourceCol';

  static const String documentoIdSourceCol = 'id_documento';
  static const String documentoIdFqCol = '$documentoFqtn.$documentoIdSourceCol';
  static const String documentoIdSerieSourceCol = 'id_serie';
  static const String documentoIdSerieFqCol =
      '$documentoFqtn.$documentoIdSerieSourceCol';
  static const String documentoIdUnidadeResponsavelSourceCol =
      'id_unidade_responsavel';
  static const String documentoIdUnidadeResponsavelFqCol =
      '$documentoFqtn.$documentoIdUnidadeResponsavelSourceCol';
  static const String documentoNumeroSourceCol = 'numero';
  static const String documentoNumeroFqCol =
      '$documentoFqtn.$documentoNumeroSourceCol';
  static const String documentoNomeArvoreSourceCol = 'nome_arvore';
  static const String documentoNomeArvoreFqCol =
      '$documentoFqtn.$documentoNomeArvoreSourceCol';
  static const String documentoEstadoSourceCol = 'sta_documento';
  static const String documentoEstadoFqCol =
      '$documentoFqtn.$documentoEstadoSourceCol';
  static const String documentoBloqueadoSourceCol = 'sin_bloqueado';
  static const String documentoBloqueadoFqCol =
      '$documentoFqtn.$documentoBloqueadoSourceCol';
  static const String documentoArquivamentoSourceCol = 'sin_arquivamento';
  static const String documentoArquivamentoFqCol =
      '$documentoFqtn.$documentoArquivamentoSourceCol';
  static const String documentoVersoesSourceCol = 'sin_versoes';
  static const String documentoVersoesFqCol =
      '$documentoFqtn.$documentoVersoesSourceCol';

  static const String protocoloIdSourceCol = 'id_protocolo';
  static const String protocoloIdFqCol = '$protocoloFqtn.$protocoloIdSourceCol';
  static const String protocoloFormatadoSourceCol = 'protocolo_formatado';
  static const String protocoloFormatadoFqCol =
      '$protocoloFqtn.$protocoloFormatadoSourceCol';
  static const String protocoloGeracaoSourceCol = 'dta_geracao';
  static const String protocoloGeracaoFqCol =
      '$protocoloFqtn.$protocoloGeracaoSourceCol';
  static const String protocoloNivelAcessoSourceCol = 'sta_nivel_acesso_local';
  static const String protocoloNivelAcessoFqCol =
      '$protocoloFqtn.$protocoloNivelAcessoSourceCol';

  static const String serieIdSourceCol = 'id_serie';
  static const String serieIdFqCol = '$serieFqtn.$serieIdSourceCol';
  static const String serieNomeSourceCol = 'nome';
  static const String serieNomeFqCol = '$serieFqtn.$serieNomeSourceCol';

  static const String unidadeIdSourceCol = 'id_unidade';
  static const String unidadeIdFqCol = '$unidadeFqtn.$unidadeIdSourceCol';
  static const String unidadeSiglaSourceCol = 'sigla';
  static const String unidadeSiglaFqCol = '$unidadeFqtn.$unidadeSiglaSourceCol';

  static const String idRelacaoCol = 'id_relacao';
  static const String idDocumentoCol = 'id_documento';
  static const String protocoloFormatadoCol = 'protocolo_formatado';
  static const String nomeArvoreCol = 'nome_arvore';
  static const String numeroCol = 'numero';
  static const String serieNomeCol = 'serie_nome';
  static const String idUnidadeResponsavelCol = 'id_unidade_responsavel';
  static const String unidadeResponsavelSiglaCol = 'unidade_responsavel_sigla';
  static const String estadoDocumentoCol = 'estado_documento';
  static const String nivelAcessoCol = 'nivel_acesso';
  static const String bloqueadoCol = 'bloqueado';
  static const String arquivamentoCol = 'arquivamento';
  static const String possuiVersoesCol = 'possui_versoes';
  static const String sequenciaCol = 'sequencia';
  static const String estadoAssociacaoCol = 'estado_associacao';
  static const String dataAssociacaoCol = 'data_associacao';
  static const String cienciaCol = 'ciencia';
  static const String dataGeracaoCol = 'data_geracao';

  ProcessoArvoreDocumentoItem({
    required this.idRelacao,
    required this.idDocumento,
    required this.protocoloFormatado,
    required this.serieNome,
    required this.idUnidadeResponsavel,
    required this.unidadeResponsavelSigla,
    required this.estadoDocumento,
    required this.nivelAcesso,
    required this.bloqueado,
    required this.arquivamento,
    required this.possuiVersoes,
    required this.sequencia,
    required this.estadoAssociacao,
    required this.dataAssociacao,
    required this.ciencia,
    required this.dataGeracao,
    this.nomeArvore,
    this.numero,
  });

  factory ProcessoArvoreDocumentoItem.fromMap(Map<String, dynamic> map) {
    return ProcessoArvoreDocumentoItem(
      idRelacao: SeiCoreUtils.identificadorParaString(
        map[idRelacaoCol],
        nomeCampo: idRelacaoCol,
      ),
      idDocumento: SeiCoreUtils.identificadorParaString(
        map[idDocumentoCol],
        nomeCampo: idDocumentoCol,
      ),
      protocoloFormatado: map[protocoloFormatadoCol] as String,
      nomeArvore: map[nomeArvoreCol] as String?,
      numero: map[numeroCol] as String?,
      serieNome: map[serieNomeCol] as String,
      idUnidadeResponsavel: SeiCoreUtils.inteiro(
        map[idUnidadeResponsavelCol],
        nomeCampo: idUnidadeResponsavelCol,
      ),
      unidadeResponsavelSigla: map[unidadeResponsavelSiglaCol] as String,
      estadoDocumento: map[estadoDocumentoCol] as String,
      nivelAcesso: map[nivelAcessoCol] as String,
      bloqueado: SeiCoreUtils.simNaoParaBool(
        map[bloqueadoCol] as String,
        nomeCampo: bloqueadoCol,
      ),
      arquivamento: SeiCoreUtils.simNaoParaBool(
        map[arquivamentoCol] as String,
        nomeCampo: arquivamentoCol,
      ),
      possuiVersoes: SeiCoreUtils.simNaoParaBool(
        map[possuiVersoesCol] as String,
        nomeCampo: possuiVersoesCol,
      ),
      sequencia: SeiCoreUtils.inteiro(
        map[sequenciaCol],
        nomeCampo: sequenciaCol,
      ),
      estadoAssociacao: map[estadoAssociacaoCol] as String,
      dataAssociacao: SeiCoreUtils.dataHoraLocal(
        map[dataAssociacaoCol],
        nomeCampo: dataAssociacaoCol,
      ),
      ciencia: SeiCoreUtils.simNaoParaBool(
        map[cienciaCol] as String,
        nomeCampo: cienciaCol,
      ),
      dataGeracao: SeiCoreUtils.dataHoraLocal(
        map[dataGeracaoCol],
        nomeCampo: dataGeracaoCol,
      ),
    );
  }

  final String idRelacao;
  final String idDocumento;
  final String protocoloFormatado;
  final String? nomeArvore;
  final String? numero;
  final String serieNome;
  final int idUnidadeResponsavel;
  final String unidadeResponsavelSigla;
  final String estadoDocumento;
  final String nivelAcesso;
  final bool bloqueado;
  final bool arquivamento;
  final bool possuiVersoes;
  final int sequencia;
  final String estadoAssociacao;
  final DateTime dataAssociacao;
  final bool ciencia;
  final DateTime dataGeracao;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idRelacaoCol: idRelacao,
      idDocumentoCol: idDocumento,
      protocoloFormatadoCol: protocoloFormatado,
      nomeArvoreCol: nomeArvore,
      numeroCol: numero,
      serieNomeCol: serieNome,
      idUnidadeResponsavelCol: idUnidadeResponsavel,
      unidadeResponsavelSiglaCol: unidadeResponsavelSigla,
      estadoDocumentoCol: estadoDocumento,
      nivelAcessoCol: nivelAcesso,
      bloqueadoCol: SeiCoreUtils.boolParaSimNao(bloqueado),
      arquivamentoCol: SeiCoreUtils.boolParaSimNao(arquivamento),
      possuiVersoesCol: SeiCoreUtils.boolParaSimNao(possuiVersoes),
      sequenciaCol: sequencia,
      estadoAssociacaoCol: estadoAssociacao,
      dataAssociacaoCol: dataAssociacao.toIso8601String(),
      cienciaCol: SeiCoreUtils.boolParaSimNao(ciencia),
      dataGeracaoCol: dataGeracao.toIso8601String(),
    };
  }
}
