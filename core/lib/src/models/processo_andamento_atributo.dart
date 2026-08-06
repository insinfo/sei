import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Atributo textual associado a um evento de andamento de processo.
class ProcessoAndamentoAtributo extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'atributo_andamento';
  static const String fqtn = '$schemaName.$tableName';

  static const String idCol = 'id_atributo_andamento';
  static const String idFqCol = '$fqtn.$idCol';
  static const String idAtividadeCol = 'id_atividade';
  static const String idAtividadeFqCol = '$fqtn.$idAtividadeCol';
  static const String idOrigemCol = 'id_origem';
  static const String idOrigemFqCol = '$fqtn.$idOrigemCol';
  static const String nomeCol = 'nome';
  static const String nomeFqCol = '$fqtn.$nomeCol';
  static const String valorCol = 'valor';
  static const String valorFqCol = '$fqtn.$valorCol';

  ProcessoAndamentoAtributo({
    required this.idAtributoAndamento,
    required this.nome,
    this.idOrigem,
    this.valor,
  });

  factory ProcessoAndamentoAtributo.fromMap(Map<String, dynamic> map) {
    return ProcessoAndamentoAtributo(
      idAtributoAndamento: SeiCoreUtils.inteiro(
        map[idCol],
        nomeCampo: idCol,
      ),
      idOrigem: map[idOrigemCol] as String?,
      nome: map[nomeCol] as String,
      valor: map[valorCol] as String?,
    );
  }

  final int idAtributoAndamento;
  final String? idOrigem;
  final String nome;
  final String? valor;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: idAtributoAndamento,
      idOrigemCol: idOrigem,
      nomeCol: nome,
      valorCol: valor,
    };
  }
}
