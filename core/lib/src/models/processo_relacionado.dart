import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Sentido em que o vínculo de relacionamento foi gravado.
///
/// A linha de `rel_protocolo_protocolo` é única e direcionada, mas a tela do
/// SEI mostra o relacionamento nos dois processos. O sentido preserva quem
/// originou o vínculo, informação necessária porque somente a unidade que o
/// criou pode desfazê-lo.
enum SentidoRelacionamento {
  /// O processo consultado é a origem gravada em `id_protocolo_1`.
  origem('origem'),

  /// O processo consultado é o destino gravado em `id_protocolo_2`.
  destino('destino');

  const SentidoRelacionamento(this.valor);

  /// Valor estável exposto pela API.
  final String valor;

  /// Converte o valor de transporte em sentido conhecido, com erro controlado.
  static SentidoRelacionamento fromValue(String valor) {
    for (final SentidoRelacionamento sentido in values) {
      if (sentido.valor == valor) {
        return sentido;
      }
    }
    throw FormatException('O sentido de relacionamento é inválido: $valor.');
  }
}

/// Processo vinculado por relacionamento ao processo consultado.
///
/// Processos relacionados não tramitam juntos e não possuem hierarquia entre
/// si; o vínculo é apenas de afinidade temática e pode ser desfeito pela
/// unidade que o criou.
class ProcessoRelacionado extends BaseModel {
  static const String schemaName = 'public';

  static const String relacaoFqtn = '$schemaName.rel_protocolo_protocolo';
  static const String protocoloFqtn = '$schemaName.protocolo';
  static const String procedimentoFqtn = '$schemaName.procedimento';
  static const String tipoProcedimentoFqtn = '$schemaName.tipo_procedimento';
  static const String unidadeFqtn = '$schemaName.unidade';

  static const String relacaoIdSourceCol = 'id_rel_protocolo_protocolo';
  static const String relacaoIdFqCol = '$relacaoFqtn.$relacaoIdSourceCol';
  static const String relacaoIdProtocolo1SourceCol = 'id_protocolo_1';
  static const String relacaoIdProtocolo1FqCol =
      '$relacaoFqtn.$relacaoIdProtocolo1SourceCol';
  static const String relacaoIdProtocolo2SourceCol = 'id_protocolo_2';
  static const String relacaoIdProtocolo2FqCol =
      '$relacaoFqtn.$relacaoIdProtocolo2SourceCol';
  static const String relacaoStaAssociacaoSourceCol = 'sta_associacao';
  static const String relacaoStaAssociacaoFqCol =
      '$relacaoFqtn.$relacaoStaAssociacaoSourceCol';
  static const String relacaoDataAssociacaoSourceCol = 'dth_associacao';
  static const String relacaoDataAssociacaoFqCol =
      '$relacaoFqtn.$relacaoDataAssociacaoSourceCol';
  static const String relacaoIdUnidadeSourceCol = 'id_unidade';
  static const String relacaoIdUnidadeFqCol =
      '$relacaoFqtn.$relacaoIdUnidadeSourceCol';

  static const String protocoloIdSourceCol = 'id_protocolo';
  static const String protocoloIdFqCol = '$protocoloFqtn.$protocoloIdSourceCol';
  static const String protocoloFormatadoSourceCol = 'protocolo_formatado';
  static const String protocoloFormatadoFqCol =
      '$protocoloFqtn.$protocoloFormatadoSourceCol';
  static const String protocoloDescricaoSourceCol = 'descricao';
  static const String protocoloDescricaoFqCol =
      '$protocoloFqtn.$protocoloDescricaoSourceCol';
  static const String protocoloEstadoSourceCol = 'sta_estado';
  static const String protocoloEstadoFqCol =
      '$protocoloFqtn.$protocoloEstadoSourceCol';
  static const String protocoloNivelAcessoGlobalSourceCol =
      'sta_nivel_acesso_global';
  static const String protocoloNivelAcessoGlobalFqCol =
      '$protocoloFqtn.$protocoloNivelAcessoGlobalSourceCol';

  static const String procedimentoIdSourceCol = 'id_procedimento';
  static const String procedimentoIdFqCol =
      '$procedimentoFqtn.$procedimentoIdSourceCol';
  static const String procedimentoIdTipoSourceCol = 'id_tipo_procedimento';
  static const String procedimentoIdTipoFqCol =
      '$procedimentoFqtn.$procedimentoIdTipoSourceCol';

  static const String tipoProcedimentoIdSourceCol = 'id_tipo_procedimento';
  static const String tipoProcedimentoIdFqCol =
      '$tipoProcedimentoFqtn.$tipoProcedimentoIdSourceCol';
  static const String tipoProcedimentoNomeSourceCol = 'nome';
  static const String tipoProcedimentoNomeFqCol =
      '$tipoProcedimentoFqtn.$tipoProcedimentoNomeSourceCol';

  static const String unidadeIdSourceCol = 'id_unidade';
  static const String unidadeIdFqCol = '$unidadeFqtn.$unidadeIdSourceCol';
  static const String unidadeSiglaSourceCol = 'sigla';
  static const String unidadeSiglaFqCol = '$unidadeFqtn.$unidadeSiglaSourceCol';

  static const String idRelacaoCol = 'id_relacao';
  static const String idProcessoRelacionadoCol = 'id_processo_relacionado';
  static const String protocoloFormatadoCol = 'protocolo_formatado';
  static const String descricaoCol = 'descricao';
  static const String estadoProtocoloCol = 'estado_protocolo';
  static const String nivelAcessoGlobalCol = 'nivel_acesso_global';
  static const String idTipoProcedimentoCol = 'id_tipo_procedimento';
  static const String tipoProcedimentoNomeCol = 'tipo_procedimento_nome';
  static const String dataAssociacaoCol = 'data_associacao';
  static const String idUnidadeAssociacaoCol = 'id_unidade_associacao';
  static const String unidadeAssociacaoSiglaCol = 'unidade_associacao_sigla';
  static const String sentidoCol = 'sentido';

  ProcessoRelacionado({
    required this.idRelacao,
    required this.idProcessoRelacionado,
    required this.protocoloFormatado,
    required this.estadoProtocolo,
    required this.nivelAcessoGlobal,
    required this.idTipoProcedimento,
    required this.tipoProcedimentoNome,
    required this.dataAssociacao,
    required this.idUnidadeAssociacao,
    required this.unidadeAssociacaoSigla,
    required this.sentido,
    this.descricao,
  });

  factory ProcessoRelacionado.fromMap(
    Map<String, dynamic> map, {
    SentidoRelacionamento? sentido,
  }) {
    return ProcessoRelacionado(
      idRelacao: SeiCoreUtils.identificadorParaString(
        map[idRelacaoCol],
        nomeCampo: idRelacaoCol,
      ),
      idProcessoRelacionado: SeiCoreUtils.identificadorParaString(
        map[idProcessoRelacionadoCol],
        nomeCampo: idProcessoRelacionadoCol,
      ),
      protocoloFormatado: map[protocoloFormatadoCol] as String,
      descricao: map[descricaoCol] as String?,
      estadoProtocolo: (map[estadoProtocoloCol] as String).trim(),
      nivelAcessoGlobal: (map[nivelAcessoGlobalCol] as String).trim(),
      idTipoProcedimento: SeiCoreUtils.inteiro(
        map[idTipoProcedimentoCol],
        nomeCampo: idTipoProcedimentoCol,
      ),
      tipoProcedimentoNome: map[tipoProcedimentoNomeCol] as String,
      dataAssociacao: SeiCoreUtils.dataHoraLocal(
        map[dataAssociacaoCol],
        nomeCampo: dataAssociacaoCol,
      ),
      idUnidadeAssociacao: SeiCoreUtils.inteiro(
        map[idUnidadeAssociacaoCol],
        nomeCampo: idUnidadeAssociacaoCol,
      ),
      unidadeAssociacaoSigla: map[unidadeAssociacaoSiglaCol] as String,
      sentido:
          sentido ?? SentidoRelacionamento.fromValue(map[sentidoCol] as String),
    );
  }

  final String idRelacao;
  final String idProcessoRelacionado;
  final String protocoloFormatado;
  final String? descricao;
  final String estadoProtocolo;
  final String nivelAcessoGlobal;
  final int idTipoProcedimento;
  final String tipoProcedimentoNome;
  final DateTime dataAssociacao;

  /// Unidade que gravou o vínculo; somente ela pode removê-lo.
  final int idUnidadeAssociacao;
  final String unidadeAssociacaoSigla;
  final SentidoRelacionamento sentido;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idRelacaoCol: idRelacao,
      idProcessoRelacionadoCol: idProcessoRelacionado,
      protocoloFormatadoCol: protocoloFormatado,
      descricaoCol: descricao,
      estadoProtocoloCol: estadoProtocolo,
      nivelAcessoGlobalCol: nivelAcessoGlobal,
      idTipoProcedimentoCol: idTipoProcedimento,
      tipoProcedimentoNomeCol: tipoProcedimentoNome,
      dataAssociacaoCol: dataAssociacao.toIso8601String(),
      idUnidadeAssociacaoCol: idUnidadeAssociacao,
      unidadeAssociacaoSiglaCol: unidadeAssociacaoSigla,
      sentidoCol: sentido.valor,
    };
  }
}
