import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Nota interna da unidade sobre um processo, gravável em `anotacao`.
///
/// A anotação nunca tramita com o processo: é um registro exclusivo da
/// unidade que a criou. Ao enviar o processo com a opção "Remover anotação",
/// a linha é apagada para que ela não reapareça se o processo retornar.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap].
class Anotacao extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'anotacao';
  static const String fqtn = '$schemaName.$tableName';

  static const String idAnotacaoCol = 'id_anotacao';
  static const String idAnotacaoFqCol = '$fqtn.$idAnotacaoCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idProtocoloCol = 'id_protocolo';
  static const String idProtocoloFqCol = '$fqtn.$idProtocoloCol';
  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String descricaoCol = 'descricao';
  static const String descricaoFqCol = '$fqtn.$descricaoCol';
  static const String dataAnotacaoCol = 'dth_anotacao';
  static const String dataAnotacaoFqCol = '$fqtn.$dataAnotacaoCol';
  static const String prioridadeCol = 'sin_prioridade';
  static const String prioridadeFqCol = '$fqtn.$prioridadeCol';
  static const String situacaoCol = 'sta_anotacao';
  static const String situacaoFqCol = '$fqtn.$situacaoCol';

  Anotacao({
    required this.idAnotacao,
    required this.idUnidade,
    required this.idProtocolo,
    required this.idUsuario,
    required this.dataAnotacao,
    required this.situacao,
    this.prioridade = false,
    this.descricao,
  });

  factory Anotacao.fromMap(Map<String, dynamic> map) {
    return Anotacao(
      idAnotacao: SeiCoreUtils.inteiro(
        map[idAnotacaoCol],
        nomeCampo: idAnotacaoCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      idProtocolo: SeiCoreUtils.inteiro(
        map[idProtocoloCol],
        nomeCampo: idProtocoloCol,
      ),
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      descricao: map[descricaoCol] as String?,
      dataAnotacao: SeiCoreUtils.dataHoraLocal(
        map[dataAnotacaoCol],
        nomeCampo: dataAnotacaoCol,
      ),
      prioridade: SeiCoreUtils.simNaoParaBool(
        (map[prioridadeCol] as String).trim(),
        nomeCampo: prioridadeCol,
      ),
      situacao: (map[situacaoCol] as String).trim(),
    );
  }

  /// Identificador da anotação, atribuído pela aplicação.
  final int idAnotacao;

  /// Unidade que criou a anotação; somente ela a visualiza.
  final int idUnidade;
  final int idProtocolo;
  final int idUsuario;
  final String? descricao;
  final DateTime dataAnotacao;

  /// Quando verdadeiro, o ícone da anotação é exibido em vermelho.
  final bool prioridade;

  /// Código bruto de `sta_anotacao`.
  ///
  /// O corpus local só comprova o valor `U` nos dados reais, sem descrição
  /// correspondente no manual do usuário. Por não haver evidência suficiente
  /// para um domínio fechado, o código é preservado como veio do banco, sem
  /// enum. A lacuna está registrada em
  /// `backend/docs/evidencias_processo_detalhe.md`.
  final String situacao;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idAnotacaoCol: idAnotacao,
      idUnidadeCol: idUnidade,
      idProtocoloCol: idProtocolo,
      idUsuarioCol: idUsuario,
      descricaoCol: descricao,
      dataAnotacaoCol: dataAnotacao,
      prioridadeCol: SeiCoreUtils.boolParaSimNao(prioridade),
      situacaoCol: situacao,
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idAnotacaoCol);
    return mapa;
  }
}
