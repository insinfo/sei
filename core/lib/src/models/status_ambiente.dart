import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/catalogo_resumo.dart';

/// Estado operacional exposto pela API de desenvolvimento somente leitura.
class StatusAmbiente extends BaseModel {
  static const String statusCol = 'status';
  static const String modoCol = 'modo';
  static const String bancoDadosCol = 'banco_dados';
  static const String catalogosCol = 'catalogos';

  StatusAmbiente({
    required this.status,
    required this.modo,
    required this.bancoDados,
    required this.catalogos,
  });

  factory StatusAmbiente.fromMap(Map<String, dynamic> map) {
    return StatusAmbiente(
      status: map[statusCol] as String,
      modo: map[modoCol] as String,
      bancoDados: map[bancoDadosCol] as String,
      catalogos: CatalogoResumo.fromMap(
        map[catalogosCol] as Map<String, dynamic>,
      ),
    );
  }

  final String status;
  final String modo;
  final String bancoDados;
  final CatalogoResumo catalogos;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      statusCol: status,
      modoCol: modo,
      bancoDadosCol: bancoDados,
      catalogosCol: catalogos.toMap(),
    };
  }
}
