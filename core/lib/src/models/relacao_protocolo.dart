import 'package:sei_core/src/models/associacao_protocolo.dart';
import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Associação entre dois protocolos, gravável em `rel_protocolo_protocolo`.
///
/// A mesma tabela liga o processo aos seus documentos, aos processos
/// relacionados e aos processos anexados; o papel é dado por
/// [codigoAssociacao]. O vínculo é gravado uma única vez e é direcionado,
/// mesmo quando a tela o exibe dos dois lados.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap].
class RelacaoProtocolo extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'rel_protocolo_protocolo';
  static const String fqtn = '$schemaName.$tableName';

  static const String idRelacaoCol = 'id_rel_protocolo_protocolo';
  static const String idRelacaoFqCol = '$fqtn.$idRelacaoCol';
  static const String idProtocolo1Col = 'id_protocolo_1';
  static const String idProtocolo1FqCol = '$fqtn.$idProtocolo1Col';
  static const String idProtocolo2Col = 'id_protocolo_2';
  static const String idProtocolo2FqCol = '$fqtn.$idProtocolo2Col';
  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String associacaoCol = 'sta_associacao';
  static const String associacaoFqCol = '$fqtn.$associacaoCol';
  static const String dataAssociacaoCol = 'dth_associacao';
  static const String dataAssociacaoFqCol = '$fqtn.$dataAssociacaoCol';
  static const String sequenciaCol = 'sequencia';
  static const String sequenciaFqCol = '$fqtn.$sequenciaCol';
  static const String cienciaCol = 'sin_ciencia';
  static const String cienciaFqCol = '$fqtn.$cienciaCol';

  RelacaoProtocolo({
    required this.idRelacao,
    required this.idProtocolo1,
    required this.idProtocolo2,
    required this.idUsuario,
    required this.idUnidade,
    required this.codigoAssociacao,
    required this.dataAssociacao,
    this.sequencia = 0,
    this.ciencia = false,
  });

  /// Cria a associação a partir de um papel conhecido do domínio.
  factory RelacaoProtocolo.comAssociacao({
    required int idRelacao,
    required int idProtocolo1,
    required int idProtocolo2,
    required int idUsuario,
    required int idUnidade,
    required AssociacaoProtocolo associacao,
    required DateTime dataAssociacao,
    int sequencia = 0,
    bool ciencia = false,
  }) {
    return RelacaoProtocolo(
      idRelacao: idRelacao,
      idProtocolo1: idProtocolo1,
      idProtocolo2: idProtocolo2,
      idUsuario: idUsuario,
      idUnidade: idUnidade,
      codigoAssociacao: associacao.valor,
      dataAssociacao: dataAssociacao,
      sequencia: sequencia,
      ciencia: ciencia,
    );
  }

  factory RelacaoProtocolo.fromMap(Map<String, dynamic> map) {
    return RelacaoProtocolo(
      idRelacao: SeiCoreUtils.inteiro(
        map[idRelacaoCol],
        nomeCampo: idRelacaoCol,
      ),
      idProtocolo1: SeiCoreUtils.inteiro(
        map[idProtocolo1Col],
        nomeCampo: idProtocolo1Col,
      ),
      idProtocolo2: SeiCoreUtils.inteiro(
        map[idProtocolo2Col],
        nomeCampo: idProtocolo2Col,
      ),
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      codigoAssociacao: (map[associacaoCol] as String).trim(),
      dataAssociacao: SeiCoreUtils.dataHoraLocal(
        map[dataAssociacaoCol],
        nomeCampo: dataAssociacaoCol,
      ),
      sequencia: SeiCoreUtils.inteiro(
        map[sequenciaCol],
        nomeCampo: sequenciaCol,
      ),
      ciencia: SeiCoreUtils.simNaoParaBool(
        (map[cienciaCol] as String).trim(),
        nomeCampo: cienciaCol,
      ),
    );
  }

  /// Identificador da associação, atribuído pela aplicação.
  final int idRelacao;

  /// Protocolo de origem do vínculo.
  final int idProtocolo1;

  /// Protocolo de destino do vínculo.
  final int idProtocolo2;

  final int idUsuario;

  /// Unidade que gravou o vínculo; somente ela pode removê-lo.
  final int idUnidade;

  /// Código bruto do papel da associação; o domínio comprovado está em
  /// [AssociacaoProtocolo].
  final String codigoAssociacao;

  final DateTime dataAssociacao;

  /// Ordem do protocolo de destino dentro da associação; é o que define a
  /// ordenação da árvore de documentos.
  final int sequencia;

  final bool ciencia;

  /// Papel conhecido correspondente ao código, quando houver.
  AssociacaoProtocolo? get associacao =>
      AssociacaoProtocolo.fromValueOrNull(codigoAssociacao);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idRelacaoCol: idRelacao,
      idProtocolo1Col: idProtocolo1,
      idProtocolo2Col: idProtocolo2,
      idUsuarioCol: idUsuario,
      idUnidadeCol: idUnidade,
      associacaoCol: codigoAssociacao,
      dataAssociacaoCol: dataAssociacao,
      sequenciaCol: sequencia,
      cienciaCol: SeiCoreUtils.boolParaSimNao(ciencia),
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idRelacaoCol);
    return mapa;
  }
}
