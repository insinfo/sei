import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Prazo interno da unidade sobre um processo, gravável em `controle_prazo`.
///
/// Diferente do Retorno Programado, este recurso é de organização interna:
/// outras unidades não têm acesso a ele. Concluir o prazo é preencher
/// [dataConclusao]; o processo pode ter vários controles de prazo ao longo do
/// tempo, um por linha.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap].
class ControlePrazo extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'controle_prazo';
  static const String fqtn = '$schemaName.$tableName';

  static const String idControlePrazoCol = 'id_controle_prazo';
  static const String idControlePrazoFqCol = '$fqtn.$idControlePrazoCol';
  static const String idProtocoloCol = 'id_protocolo';
  static const String idProtocoloFqCol = '$fqtn.$idProtocoloCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String dataPrazoCol = 'dta_prazo';
  static const String dataPrazoFqCol = '$fqtn.$dataPrazoCol';
  static const String dataConclusaoCol = 'dta_conclusao';
  static const String dataConclusaoFqCol = '$fqtn.$dataConclusaoCol';

  ControlePrazo({
    required this.idControlePrazo,
    required this.idProtocolo,
    required this.idUnidade,
    required this.idUsuario,
    required this.dataPrazo,
    this.dataConclusao,
  });

  factory ControlePrazo.fromMap(Map<String, dynamic> map) {
    return ControlePrazo(
      idControlePrazo: SeiCoreUtils.inteiro(
        map[idControlePrazoCol],
        nomeCampo: idControlePrazoCol,
      ),
      idProtocolo: SeiCoreUtils.inteiro(
        map[idProtocoloCol],
        nomeCampo: idProtocoloCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      dataPrazo: SeiCoreUtils.dataHoraLocal(
        map[dataPrazoCol],
        nomeCampo: dataPrazoCol,
      ),
      dataConclusao: map[dataConclusaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataConclusaoCol],
              nomeCampo: dataConclusaoCol,
            ),
    );
  }

  /// Identificador do controle de prazo, atribuído pela aplicação.
  final int idControlePrazo;
  final int idProtocolo;

  /// Unidade dona do controle; outras unidades não o veem.
  final int idUnidade;
  final int idUsuario;
  final DateTime dataPrazo;

  /// Enquanto for nula, o prazo está em andamento ou vencido.
  final DateTime? dataConclusao;

  /// Indica que o prazo foi marcado como concluído.
  bool get concluido => dataConclusao != null;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idControlePrazoCol: idControlePrazo,
      idProtocoloCol: idProtocolo,
      idUnidadeCol: idUnidade,
      idUsuarioCol: idUsuario,
      dataPrazoCol: dataPrazo,
      dataConclusaoCol: dataConclusao,
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idControlePrazoCol);
    return mapa;
  }
}
