import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/processo_recebido_item.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Página de atividades abertas da unidade para o Controle de Processos.
class PaginaProcessosRecebidos extends BaseModel {
  static const String itensCol = 'itens';
  static const String totalCol = 'total';
  static const String limiteCol = 'limite';
  static const String deslocamentoCol = 'deslocamento';

  PaginaProcessosRecebidos({
    required this.itens,
    required this.total,
    required this.limite,
    required this.deslocamento,
  });

  factory PaginaProcessosRecebidos.fromMap(Map<String, dynamic> map) {
    final Object? itensBrutos = map[itensCol];
    if (itensBrutos is! List<Object?>) {
      throw FormatException('O campo $itensCol deve conter uma lista.');
    }

    final itens = <ProcessoRecebidoItem>[];
    for (final Object? item in itensBrutos) {
      if (item is! Map<String, dynamic>) {
        throw FormatException('Cada item de $itensCol deve ser um objeto.');
      }
      itens.add(ProcessoRecebidoItem.fromMap(item));
    }

    return PaginaProcessosRecebidos(
      itens: itens,
      total: SeiCoreUtils.inteiro(map[totalCol], nomeCampo: totalCol),
      limite: SeiCoreUtils.inteiro(map[limiteCol], nomeCampo: limiteCol),
      deslocamento: SeiCoreUtils.inteiro(
        map[deslocamentoCol],
        nomeCampo: deslocamentoCol,
      ),
    );
  }

  final List<ProcessoRecebidoItem> itens;
  final int total;
  final int limite;
  final int deslocamento;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      itensCol: itens.map((ProcessoRecebidoItem item) => item.toMap()).toList(),
      totalCol: total,
      limiteCol: limite,
      deslocamentoCol: deslocamento,
    };
  }
}
