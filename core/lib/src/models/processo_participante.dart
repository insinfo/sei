import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Papéis de participação registrados em `participante.sta_participacao`.
///
/// O dump histórico local contém quatro códigos: `I` com 1.438 linhas, `D`
/// com 51, `R` com 36 e `A` com 11. Os três primeiros correspondem aos campos
/// Interessados, Destinatários e Remetente do cadastro de processo e de
/// documento descritos no manual do usuário. O código `A` aparece nos dados
/// mas não tem correspondência provada no corpus local, e por isso não é
/// declarado aqui: o DTO preserva o código bruto para não perder informação.
enum ProcessoParticipacao {
  /// Interessado no mérito do processo ou do documento.
  interessado('I'),

  /// Remetente do documento recebido.
  remetente('R'),

  /// Destinatário do documento produzido.
  destinatario('D');

  const ProcessoParticipacao(this.valor);

  /// Valor persistido em `participante.sta_participacao`.
  final String valor;

  /// Converte o código do banco em papel conhecido, quando houver.
  static ProcessoParticipacao? fromValueOrNull(String valor) {
    final String normalizado = valor.trim();
    for (final ProcessoParticipacao participacao in values) {
      if (participacao.valor == normalizado) {
        return participacao;
      }
    }
    return null;
  }
}

/// Contato vinculado a um protocolo como interessado, remetente ou
/// destinatário.
class ProcessoParticipante extends BaseModel {
  static const String schemaName = 'public';

  static const String participanteFqtn = '$schemaName.participante';
  static const String contatoFqtn = '$schemaName.contato';

  static const String participanteIdSourceCol = 'id_participante';
  static const String participanteIdFqCol =
      '$participanteFqtn.$participanteIdSourceCol';
  static const String participanteIdProtocoloSourceCol = 'id_protocolo';
  static const String participanteIdProtocoloFqCol =
      '$participanteFqtn.$participanteIdProtocoloSourceCol';
  static const String participanteIdContatoSourceCol = 'id_contato';
  static const String participanteIdContatoFqCol =
      '$participanteFqtn.$participanteIdContatoSourceCol';
  static const String participanteIdUnidadeSourceCol = 'id_unidade';
  static const String participanteIdUnidadeFqCol =
      '$participanteFqtn.$participanteIdUnidadeSourceCol';
  static const String participanteStaParticipacaoSourceCol = 'sta_participacao';
  static const String participanteStaParticipacaoFqCol =
      '$participanteFqtn.$participanteStaParticipacaoSourceCol';
  static const String participanteSequenciaSourceCol = 'sequencia';
  static const String participanteSequenciaFqCol =
      '$participanteFqtn.$participanteSequenciaSourceCol';

  static const String contatoIdSourceCol = 'id_contato';
  static const String contatoIdFqCol = '$contatoFqtn.$contatoIdSourceCol';
  static const String contatoNomeSourceCol = 'nome';
  static const String contatoNomeFqCol = '$contatoFqtn.$contatoNomeSourceCol';
  static const String contatoSiglaSourceCol = 'sigla';
  static const String contatoSiglaFqCol = '$contatoFqtn.$contatoSiglaSourceCol';
  static const String contatoEmailSourceCol = 'email';
  static const String contatoEmailFqCol = '$contatoFqtn.$contatoEmailSourceCol';
  static const String contatoNaturezaSourceCol = 'sta_natureza';
  static const String contatoNaturezaFqCol =
      '$contatoFqtn.$contatoNaturezaSourceCol';
  static const String contatoIdTipoContatoSourceCol = 'id_tipo_contato';
  static const String contatoIdTipoContatoFqCol =
      '$contatoFqtn.$contatoIdTipoContatoSourceCol';

  static const String idParticipanteCol = 'id_participante';
  static const String idContatoCol = 'id_contato';
  static const String contatoNomeCol = 'contato_nome';
  static const String contatoSiglaCol = 'contato_sigla';
  static const String contatoEmailCol = 'contato_email';
  static const String contatoNaturezaCol = 'contato_natureza';
  static const String idTipoContatoCol = 'id_tipo_contato';
  static const String codigoParticipacaoCol = 'codigo_participacao';
  static const String sequenciaCol = 'sequencia';
  static const String idUnidadeCol = 'id_unidade';

  ProcessoParticipante({
    required this.idParticipante,
    required this.idContato,
    required this.contatoNome,
    required this.contatoNatureza,
    required this.idTipoContato,
    required this.codigoParticipacao,
    required this.sequencia,
    required this.idUnidade,
    this.contatoSigla,
    this.contatoEmail,
  });

  factory ProcessoParticipante.fromMap(Map<String, dynamic> map) {
    return ProcessoParticipante(
      idParticipante: SeiCoreUtils.inteiro(
        map[idParticipanteCol],
        nomeCampo: idParticipanteCol,
      ),
      idContato: SeiCoreUtils.inteiro(
        map[idContatoCol],
        nomeCampo: idContatoCol,
      ),
      contatoNome: map[contatoNomeCol] as String,
      contatoSigla: map[contatoSiglaCol] as String?,
      contatoEmail: map[contatoEmailCol] as String?,
      contatoNatureza: (map[contatoNaturezaCol] as String).trim(),
      idTipoContato: SeiCoreUtils.inteiro(
        map[idTipoContatoCol],
        nomeCampo: idTipoContatoCol,
      ),
      codigoParticipacao: (map[codigoParticipacaoCol] as String).trim(),
      sequencia: SeiCoreUtils.inteiro(
        map[sequenciaCol],
        nomeCampo: sequenciaCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
    );
  }

  final int idParticipante;
  final int idContato;
  final String contatoNome;
  final String? contatoSigla;
  final String? contatoEmail;

  /// Natureza do contato persistida em `contato.sta_natureza`, que separa
  /// pessoa física de pessoa jurídica.
  final String contatoNatureza;
  final int idTipoContato;

  /// Código bruto de `participante.sta_participacao`, preservado porque o
  /// domínio conhecido não cobre todos os valores presentes nos dados.
  final String codigoParticipacao;

  /// Ordem do participante dentro do papel, definida no cadastro.
  final int sequencia;

  /// Unidade que registrou o participante.
  final int idUnidade;

  /// Papel conhecido correspondente ao código, quando houver.
  ProcessoParticipacao? get participacao =>
      ProcessoParticipacao.fromValueOrNull(codigoParticipacao);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idParticipanteCol: idParticipante,
      idContatoCol: idContato,
      contatoNomeCol: contatoNome,
      contatoSiglaCol: contatoSigla,
      contatoEmailCol: contatoEmail,
      contatoNaturezaCol: contatoNatureza,
      idTipoContatoCol: idTipoContato,
      codigoParticipacaoCol: codigoParticipacao,
      sequenciaCol: sequencia,
      idUnidadeCol: idUnidade,
    };
  }
}
