import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/processo_arvore_documento_item.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Página incremental da árvore de documentos de um processo.
///
/// O cursor é opaco para a interface e evita uma contagem total custosa em
/// processos longos.
class PaginaProcessoArvoreDocumentos extends BaseModel {
  static const String itensCol = 'itens';
  static const String limiteCol = 'limite';
  static const String proximoCursorCol = 'proximo_cursor';

  PaginaProcessoArvoreDocumentos({
    required this.itens,
    required this.limite,
    this.proximoCursor,
  });

  factory PaginaProcessoArvoreDocumentos.fromMap(Map<String, dynamic> map) {
    final Object? itensBrutos = map[itensCol];
    if (itensBrutos is! List<Object?>) {
      throw FormatException('O campo $itensCol deve conter uma lista.');
    }

    final itens = <ProcessoArvoreDocumentoItem>[];
    for (final Object? itemBruto in itensBrutos) {
      if (itemBruto is! Map<String, dynamic>) {
        throw FormatException('Cada item de $itensCol deve ser um objeto.');
      }
      itens.add(ProcessoArvoreDocumentoItem.fromMap(itemBruto));
    }

    return PaginaProcessoArvoreDocumentos(
      itens: itens,
      limite: SeiCoreUtils.inteiro(map[limiteCol], nomeCampo: limiteCol),
      proximoCursor: map[proximoCursorCol] as String?,
    );
  }

  final List<ProcessoArvoreDocumentoItem> itens;
  final int limite;
  final String? proximoCursor;

  bool get temProximaPagina => proximoCursor != null;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      itensCol: itens
          .map((ProcessoArvoreDocumentoItem item) => item.toMap())
          .toList(growable: false),
      limiteCol: limite,
      proximoCursorCol: proximoCursor,
    };
  }
}
