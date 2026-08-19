import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Prazo de devolução definido ao enviar um processo, gravável em
/// `retorno_programado`.
///
/// O manual do usuário é explícito sobre os limites deste recurso: ele apenas
/// determina prazos, não retira o acesso da unidade demandada e não devolve o
/// processo automaticamente. A contagem só cessa quando o processo é enviado
/// de volta à unidade demandante — a simples conclusão não encerra o prazo.
///
/// [idAtividadeEnvio] é a atividade da remessa que criou o prazo;
/// [idAtividadeRetorno] é preenchida quando o processo efetivamente retorna,
/// e é o que marca o prazo como cumprido.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap].
class RetornoProgramado extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'retorno_programado';
  static const String fqtn = '$schemaName.$tableName';

  static const String idRetornoProgramadoCol = 'id_retorno_programado';
  static const String idRetornoProgramadoFqCol =
      '$fqtn.$idRetornoProgramadoCol';
  static const String idAtividadeEnvioCol = 'id_atividade_envio';
  static const String idAtividadeEnvioFqCol = '$fqtn.$idAtividadeEnvioCol';
  static const String idAtividadeRetornoCol = 'id_atividade_retorno';
  static const String idAtividadeRetornoFqCol = '$fqtn.$idAtividadeRetornoCol';
  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String dataProgramadaCol = 'dta_programada';
  static const String dataProgramadaFqCol = '$fqtn.$dataProgramadaCol';
  static const String dataAlteracaoCol = 'dth_alteracao';
  static const String dataAlteracaoFqCol = '$fqtn.$dataAlteracaoCol';
  static const String idUnidadeEnvioCol = 'id_unidade_envio';
  static const String idUnidadeEnvioFqCol = '$fqtn.$idUnidadeEnvioCol';
  static const String idUnidadeRetornoCol = 'id_unidade_retorno';
  static const String idUnidadeRetornoFqCol = '$fqtn.$idUnidadeRetornoCol';
  static const String idProtocoloCol = 'id_protocolo';
  static const String idProtocoloFqCol = '$fqtn.$idProtocoloCol';

  RetornoProgramado({
    required this.idRetornoProgramado,
    required this.idAtividadeEnvio,
    required this.idUsuario,
    required this.dataProgramada,
    required this.idUnidadeEnvio,
    required this.idUnidadeRetorno,
    required this.idProtocolo,
    this.idAtividadeRetorno,
    this.dataAlteracao,
  });

  factory RetornoProgramado.fromMap(Map<String, dynamic> map) {
    return RetornoProgramado(
      idRetornoProgramado: SeiCoreUtils.inteiro(
        map[idRetornoProgramadoCol],
        nomeCampo: idRetornoProgramadoCol,
      ),
      idAtividadeEnvio: SeiCoreUtils.inteiro(
        map[idAtividadeEnvioCol],
        nomeCampo: idAtividadeEnvioCol,
      ),
      idAtividadeRetorno: map[idAtividadeRetornoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idAtividadeRetornoCol],
              nomeCampo: idAtividadeRetornoCol,
            ),
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      dataProgramada: SeiCoreUtils.dataHoraLocal(
        map[dataProgramadaCol],
        nomeCampo: dataProgramadaCol,
      ),
      dataAlteracao: map[dataAlteracaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataAlteracaoCol],
              nomeCampo: dataAlteracaoCol,
            ),
      idUnidadeEnvio: SeiCoreUtils.inteiro(
        map[idUnidadeEnvioCol],
        nomeCampo: idUnidadeEnvioCol,
      ),
      idUnidadeRetorno: SeiCoreUtils.inteiro(
        map[idUnidadeRetornoCol],
        nomeCampo: idUnidadeRetornoCol,
      ),
      idProtocolo: SeiCoreUtils.inteiro(
        map[idProtocoloCol],
        nomeCampo: idProtocoloCol,
      ),
    );
  }

  /// Identificador do retorno programado, atribuído pela aplicação.
  final int idRetornoProgramado;

  /// Atividade de remessa que originou o prazo.
  final int idAtividadeEnvio;

  /// Atividade criada quando o processo retorna; enquanto nula, o prazo
  /// segue em aberto ou vencido.
  final int? idAtividadeRetorno;

  final int idUsuario;
  final DateTime dataProgramada;
  final DateTime? dataAlteracao;

  /// Unidade que demandou o retorno.
  final int idUnidadeEnvio;

  /// Unidade que recebeu o processo e deve devolvê-lo.
  final int idUnidadeRetorno;

  final int idProtocolo;

  /// Indica que o processo já retornou à unidade demandante.
  bool get cumprido => idAtividadeRetorno != null;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idRetornoProgramadoCol: idRetornoProgramado,
      idAtividadeEnvioCol: idAtividadeEnvio,
      idAtividadeRetornoCol: idAtividadeRetorno,
      idUsuarioCol: idUsuario,
      dataProgramadaCol: dataProgramada,
      dataAlteracaoCol: dataAlteracao,
      idUnidadeEnvioCol: idUnidadeEnvio,
      idUnidadeRetornoCol: idUnidadeRetorno,
      idProtocoloCol: idProtocolo,
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idRetornoProgramadoCol);
    return mapa;
  }
}
