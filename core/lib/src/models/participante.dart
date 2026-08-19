import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/processo_participante.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Vínculo entre um contato e um protocolo, gravável em `participante`.
///
/// É a tabela que sustenta os campos Interessados, Remetente e Destinatários
/// do cadastro de processo e de documento. A projeção de leitura usada pela
/// tela é [ProcessoParticipante]; esta entidade existe para a escrita.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap].
class Participante extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'participante';
  static const String fqtn = '$schemaName.$tableName';

  static const String idParticipanteCol = 'id_participante';
  static const String idParticipanteFqCol = '$fqtn.$idParticipanteCol';
  static const String idProtocoloCol = 'id_protocolo';
  static const String idProtocoloFqCol = '$fqtn.$idProtocoloCol';
  static const String idContatoCol = 'id_contato';
  static const String idContatoFqCol = '$fqtn.$idContatoCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String participacaoCol = 'sta_participacao';
  static const String participacaoFqCol = '$fqtn.$participacaoCol';
  static const String sequenciaCol = 'sequencia';
  static const String sequenciaFqCol = '$fqtn.$sequenciaCol';

  Participante({
    required this.idParticipante,
    required this.idProtocolo,
    required this.idContato,
    required this.idUnidade,
    required this.codigoParticipacao,
    this.sequencia = 0,
  });

  /// Cria o vínculo a partir de um papel conhecido do domínio.
  factory Participante.comPapel({
    required int idParticipante,
    required int idProtocolo,
    required int idContato,
    required int idUnidade,
    required ProcessoParticipacao participacao,
    int sequencia = 0,
  }) {
    return Participante(
      idParticipante: idParticipante,
      idProtocolo: idProtocolo,
      idContato: idContato,
      idUnidade: idUnidade,
      codigoParticipacao: participacao.valor,
      sequencia: sequencia,
    );
  }

  factory Participante.fromMap(Map<String, dynamic> map) {
    return Participante(
      idParticipante: SeiCoreUtils.inteiro(
        map[idParticipanteCol],
        nomeCampo: idParticipanteCol,
      ),
      idProtocolo: SeiCoreUtils.inteiro(
        map[idProtocoloCol],
        nomeCampo: idProtocoloCol,
      ),
      idContato: SeiCoreUtils.inteiro(
        map[idContatoCol],
        nomeCampo: idContatoCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      codigoParticipacao: (map[participacaoCol] as String).trim(),
      sequencia: SeiCoreUtils.inteiro(
        map[sequenciaCol],
        nomeCampo: sequenciaCol,
      ),
    );
  }

  /// Identificador do participante, atribuído pela aplicação.
  final int idParticipante;
  final int idProtocolo;
  final int idContato;

  /// Unidade que registrou o vínculo.
  final int idUnidade;

  /// Código bruto do papel; o domínio conhecido está em
  /// [ProcessoParticipacao], que não cobre todos os valores dos dados reais.
  final String codigoParticipacao;

  /// Ordem do participante dentro do papel.
  final int sequencia;

  /// Papel conhecido correspondente ao código, quando houver.
  ProcessoParticipacao? get participacao =>
      ProcessoParticipacao.fromValueOrNull(codigoParticipacao);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idParticipanteCol: idParticipante,
      idProtocoloCol: idProtocolo,
      idContatoCol: idContato,
      idUnidadeCol: idUnidade,
      participacaoCol: codigoParticipacao,
      sequenciaCol: sequencia,
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idParticipanteCol);
    return mapa;
  }
}
