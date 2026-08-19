import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Prazo interno da unidade sobre o processo, com o autor resolvido.
///
/// Projeção somente leitura de `controle_prazo`; a escrita usa a entidade
/// [ControlePrazo]. É recurso de organização interna: outras unidades não têm
/// acesso a ele.
class ProcessoControlePrazo extends BaseModel {
  static const String schemaName = 'public';

  static const String controlePrazoFqtn = '$schemaName.controle_prazo';
  static const String usuarioFqtn = '$schemaName.usuario';

  static const String controlePrazoIdSourceCol = 'id_controle_prazo';
  static const String controlePrazoIdFqCol =
      '$controlePrazoFqtn.$controlePrazoIdSourceCol';
  static const String controlePrazoIdProtocoloSourceCol = 'id_protocolo';
  static const String controlePrazoIdProtocoloFqCol =
      '$controlePrazoFqtn.$controlePrazoIdProtocoloSourceCol';
  static const String controlePrazoIdUnidadeSourceCol = 'id_unidade';
  static const String controlePrazoIdUnidadeFqCol =
      '$controlePrazoFqtn.$controlePrazoIdUnidadeSourceCol';
  static const String controlePrazoIdUsuarioSourceCol = 'id_usuario';
  static const String controlePrazoIdUsuarioFqCol =
      '$controlePrazoFqtn.$controlePrazoIdUsuarioSourceCol';
  static const String controlePrazoDataPrazoSourceCol = 'dta_prazo';
  static const String controlePrazoDataPrazoFqCol =
      '$controlePrazoFqtn.$controlePrazoDataPrazoSourceCol';
  static const String controlePrazoDataConclusaoSourceCol = 'dta_conclusao';
  static const String controlePrazoDataConclusaoFqCol =
      '$controlePrazoFqtn.$controlePrazoDataConclusaoSourceCol';

  static const String usuarioIdSourceCol = 'id_usuario';
  static const String usuarioIdFqCol = '$usuarioFqtn.$usuarioIdSourceCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioNomeFqCol = '$usuarioFqtn.$usuarioNomeSourceCol';

  static const String idControlePrazoCol = 'id_controle_prazo';
  static const String dataPrazoCol = 'data_prazo';
  static const String dataConclusaoCol = 'data_conclusao';
  static const String idUsuarioCol = 'id_usuario';
  static const String usuarioNomeCol = 'usuario_nome';

  ProcessoControlePrazo({
    required this.idControlePrazo,
    required this.dataPrazo,
    required this.idUsuario,
    required this.usuarioNome,
    this.dataConclusao,
  });

  factory ProcessoControlePrazo.fromMap(Map<String, dynamic> map) {
    return ProcessoControlePrazo(
      idControlePrazo: SeiCoreUtils.inteiro(
        map[idControlePrazoCol],
        nomeCampo: idControlePrazoCol,
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
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      usuarioNome: map[usuarioNomeCol] as String,
    );
  }

  final int idControlePrazo;
  final DateTime dataPrazo;
  final DateTime? dataConclusao;
  final int idUsuario;
  final String usuarioNome;

  /// Indica que o prazo foi marcado como concluído.
  bool get concluido => dataConclusao != null;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idControlePrazoCol: idControlePrazo,
      dataPrazoCol: dataPrazo.toIso8601String(),
      dataConclusaoCol: dataConclusao?.toIso8601String(),
      idUsuarioCol: idUsuario,
      usuarioNomeCol: usuarioNome,
    };
  }
}
