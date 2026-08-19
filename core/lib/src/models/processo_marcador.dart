import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Marcador em uso no processo, com o nome e o ícone do catálogo resolvidos.
///
/// Projeção somente leitura da linha corrente de `andamento_marcador`
/// (`sin_ultimo = 'S'` e `sin_ativo = 'S'`) unida a `marcador`. Escrever uma
/// atribuição ou remoção usa a entidade [AndamentoMarcador], nunca esta
/// projeção.
class ProcessoMarcador extends BaseModel {
  static const String schemaName = 'public';

  static const String andamentoFqtn = '$schemaName.andamento_marcador';
  static const String marcadorFqtn = '$schemaName.marcador';
  static const String usuarioFqtn = '$schemaName.usuario';

  static const String andamentoIdSourceCol = 'id_andamento_marcador';
  static const String andamentoIdFqCol = '$andamentoFqtn.$andamentoIdSourceCol';
  static const String andamentoIdProcedimentoSourceCol = 'id_procedimento';
  static const String andamentoIdProcedimentoFqCol =
      '$andamentoFqtn.$andamentoIdProcedimentoSourceCol';
  static const String andamentoIdMarcadorSourceCol = 'id_marcador';
  static const String andamentoIdMarcadorFqCol =
      '$andamentoFqtn.$andamentoIdMarcadorSourceCol';
  static const String andamentoUltimoSourceCol = 'sin_ultimo';
  static const String andamentoUltimoFqCol =
      '$andamentoFqtn.$andamentoUltimoSourceCol';
  static const String andamentoAtivoSourceCol = 'sin_ativo';
  static const String andamentoAtivoFqCol =
      '$andamentoFqtn.$andamentoAtivoSourceCol';
  static const String andamentoTextoSourceCol = 'texto';
  static const String andamentoTextoFqCol =
      '$andamentoFqtn.$andamentoTextoSourceCol';
  static const String andamentoDataSourceCol = 'dth_execucao';
  static const String andamentoDataFqCol =
      '$andamentoFqtn.$andamentoDataSourceCol';
  static const String andamentoIdUsuarioSourceCol = 'id_usuario';
  static const String andamentoIdUsuarioFqCol =
      '$andamentoFqtn.$andamentoIdUsuarioSourceCol';

  static const String marcadorIdSourceCol = 'id_marcador';
  static const String marcadorIdFqCol = '$marcadorFqtn.$marcadorIdSourceCol';
  static const String marcadorNomeSourceCol = 'nome';
  static const String marcadorNomeFqCol =
      '$marcadorFqtn.$marcadorNomeSourceCol';
  static const String marcadorIconeSourceCol = 'sta_icone';
  static const String marcadorIconeFqCol =
      '$marcadorFqtn.$marcadorIconeSourceCol';

  static const String usuarioIdSourceCol = 'id_usuario';
  static const String usuarioIdFqCol = '$usuarioFqtn.$usuarioIdSourceCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioNomeFqCol = '$usuarioFqtn.$usuarioNomeSourceCol';

  static const String idAndamentoMarcadorCol = 'id_andamento_marcador';
  static const String idMarcadorCol = 'id_marcador';
  static const String marcadorNomeCol = 'marcador_nome';
  static const String marcadorIconeCol = 'marcador_icone';
  static const String textoCol = 'texto';
  static const String dataExecucaoCol = 'data_execucao';
  static const String idUsuarioCol = 'id_usuario';
  static const String usuarioNomeCol = 'usuario_nome';

  ProcessoMarcador({
    required this.idAndamentoMarcador,
    required this.idMarcador,
    required this.marcadorNome,
    required this.marcadorIcone,
    required this.dataExecucao,
    required this.idUsuario,
    required this.usuarioNome,
    this.texto,
  });

  factory ProcessoMarcador.fromMap(Map<String, dynamic> map) {
    return ProcessoMarcador(
      idAndamentoMarcador: SeiCoreUtils.inteiro(
        map[idAndamentoMarcadorCol],
        nomeCampo: idAndamentoMarcadorCol,
      ),
      idMarcador: SeiCoreUtils.inteiro(
        map[idMarcadorCol],
        nomeCampo: idMarcadorCol,
      ),
      marcadorNome: map[marcadorNomeCol] as String,
      marcadorIcone: (map[marcadorIconeCol] as String).trim(),
      texto: map[textoCol] as String?,
      dataExecucao: SeiCoreUtils.dataHoraLocal(
        map[dataExecucaoCol],
        nomeCampo: dataExecucaoCol,
      ),
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      usuarioNome: map[usuarioNomeCol] as String,
    );
  }

  final int idAndamentoMarcador;
  final int idMarcador;
  final String marcadorNome;
  final String marcadorIcone;
  final String? texto;
  final DateTime dataExecucao;
  final int idUsuario;
  final String usuarioNome;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idAndamentoMarcadorCol: idAndamentoMarcador,
      idMarcadorCol: idMarcador,
      marcadorNomeCol: marcadorNome,
      marcadorIconeCol: marcadorIcone,
      textoCol: texto,
      dataExecucaoCol: dataExecucao.toIso8601String(),
      idUsuarioCol: idUsuario,
      usuarioNomeCol: usuarioNome,
    };
  }
}
