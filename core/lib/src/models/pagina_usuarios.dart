import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/usuario.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Página de usuários para `GET /api/v1/usuarios`.
class PaginaUsuarios extends BaseModel {
  static const String itensCol = 'itens';
  static const String totalCol = 'total';
  static const String limiteCol = 'limite';
  static const String deslocamentoCol = 'deslocamento';

  PaginaUsuarios({
    required this.itens,
    required this.total,
    required this.limite,
    required this.deslocamento,
  });

  factory PaginaUsuarios.fromMap(Map<String, dynamic> map) {
    final Object? itensBrutos = map[itensCol];
    if (itensBrutos is! List<Object?>) {
      throw FormatException('O campo $itensCol deve conter uma lista.');
    }

    final itens = <Usuario>[];
    for (final Object? item in itensBrutos) {
      if (item is! Map<String, dynamic>) {
        throw FormatException('Cada item de $itensCol deve ser um objeto.');
      }
      itens.add(Usuario.fromMap(item));
    }

    return PaginaUsuarios(
      itens: itens,
      total: SeiCoreUtils.inteiro(map[totalCol], nomeCampo: totalCol),
      limite: SeiCoreUtils.inteiro(map[limiteCol], nomeCampo: limiteCol),
      deslocamento: SeiCoreUtils.inteiro(
        map[deslocamentoCol],
        nomeCampo: deslocamentoCol,
      ),
    );
  }

  final List<Usuario> itens;
  final int total;
  final int limite;
  final int deslocamento;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      itensCol: itens.map((Usuario item) => item.toMap()).toList(),
      totalCol: total,
      limiteCol: limite,
      deslocamentoCol: deslocamento,
    };
  }
}
