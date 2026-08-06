import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/processo_andamento_item.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Página incremental do histórico de andamentos de um processo.
class PaginaProcessoAndamentos extends BaseModel {
  static const String itensCol = 'itens';
  static const String limiteCol = 'limite';
  static const String proximoCursorCol = 'proximo_cursor';

  PaginaProcessoAndamentos({
    required this.itens,
    required this.limite,
    this.proximoCursor,
  });

  factory PaginaProcessoAndamentos.fromMap(Map<String, dynamic> map) {
    final Object? itensBrutos = map[itensCol];
    if (itensBrutos is! List<Object?>) {
      throw FormatException('O campo $itensCol deve conter uma lista.');
    }

    final itens = <ProcessoAndamentoItem>[];
    for (final Object? itemBruto in itensBrutos) {
      if (itemBruto is! Map<String, dynamic>) {
        throw FormatException('Cada item de $itensCol deve ser um objeto.');
      }
      itens.add(ProcessoAndamentoItem.fromMap(itemBruto));
    }

    return PaginaProcessoAndamentos(
      itens: itens,
      limite: SeiCoreUtils.inteiro(map[limiteCol], nomeCampo: limiteCol),
      proximoCursor: map[proximoCursorCol] as String?,
    );
  }

  final List<ProcessoAndamentoItem> itens;
  final int limite;
  final String? proximoCursor;

  bool get temProximaPagina => proximoCursor != null;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      itensCol: itens
          .map((ProcessoAndamentoItem item) => item.toMap())
          .toList(growable: false),
      limiteCol: limite,
      proximoCursorCol: proximoCursor,
    };
  }
}
