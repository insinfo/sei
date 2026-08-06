import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Parâmetros de paginação incremental dos recursos do detalhe de processo.
///
/// O cursor é produzido pela API e deve ser tratado pela interface como valor
/// opaco. Cada recurso pode interpretar o cursor conforme sua ordenação.
class ProcessoDetalhePaginacao extends BaseModel {
  static const String limiteCol = 'limite';
  static const String cursorCol = 'cursor';
  static const int limitePadrao = 50;
  static const int limiteMaximo = 100;

  ProcessoDetalhePaginacao({
    this.limite = limitePadrao,
    this.cursor,
  }) {
    if (limite <= 0 || limite > limiteMaximo) {
      throw ArgumentError.value(
        limite,
        limiteCol,
        'O limite deve estar entre 1 e $limiteMaximo.',
      );
    }
    if (cursor != null && cursor!.trim().isEmpty) {
      throw ArgumentError.value(
        cursor,
        cursorCol,
        'O cursor não pode estar vazio.',
      );
    }
  }

  factory ProcessoDetalhePaginacao.fromMap(Map<String, dynamic> map) {
    final Object? cursorBruto = map[cursorCol];
    if (cursorBruto != null && cursorBruto is! String) {
      throw FormatException('O parâmetro $cursorCol deve conter texto.');
    }

    return ProcessoDetalhePaginacao(
      limite: map[limiteCol] == null
          ? limitePadrao
          : SeiCoreUtils.inteiro(map[limiteCol], nomeCampo: limiteCol),
      cursor: cursorBruto as String?,
    );
  }

  final int limite;
  final String? cursor;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      limiteCol: limite,
      cursorCol: cursor,
    };
  }
}
