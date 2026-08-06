import 'package:sei_core/src/models/base_model.dart';

/// Quantitativos dos catálogos necessários para validar a carga de referência.
class CatalogoResumo extends BaseModel {
  static const String assuntoTableName = 'assunto';
  static const String assuntoFqtn = 'public.$assuntoTableName';
  static const String hipoteseLegalTableName = 'hipotese_legal';
  static const String hipoteseLegalFqtn = 'public.$hipoteseLegalTableName';
  static const String arquivoExtensaoTableName = 'arquivo_extensao';
  static const String arquivoExtensaoFqtn = 'public.$arquivoExtensaoTableName';
  static const String unidadeTableName = 'unidade';
  static const String unidadeFqtn = 'public.$unidadeTableName';
  static const String usuarioTableName = 'usuario';
  static const String usuarioFqtn = 'public.$usuarioTableName';

  static const String tiposProcedimentoCol = 'tipos_procedimento';
  static const String seriesCol = 'series';
  static const String assuntosCol = 'assuntos';
  static const String hipotesesLegaisCol = 'hipoteses_legais';
  static const String extensoesArquivoCol = 'extensoes_arquivo';
  static const String unidadesCol = 'unidades';
  static const String usuariosCol = 'usuarios';

  CatalogoResumo({
    required this.tiposProcedimento,
    required this.series,
    required this.assuntos,
    required this.hipotesesLegais,
    required this.extensoesArquivo,
    required this.unidades,
    required this.usuarios,
  });

  factory CatalogoResumo.fromMap(Map<String, dynamic> map) {
    return CatalogoResumo(
      tiposProcedimento: map[tiposProcedimentoCol] as int,
      series: map[seriesCol] as int,
      assuntos: map[assuntosCol] as int,
      hipotesesLegais: map[hipotesesLegaisCol] as int,
      extensoesArquivo: map[extensoesArquivoCol] as int,
      unidades: map[unidadesCol] as int,
      usuarios: map[usuariosCol] as int,
    );
  }

  final int tiposProcedimento;
  final int series;
  final int assuntos;
  final int hipotesesLegais;
  final int extensoesArquivo;
  final int unidades;
  final int usuarios;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      tiposProcedimentoCol: tiposProcedimento,
      seriesCol: series,
      assuntosCol: assuntos,
      hipotesesLegaisCol: hipotesesLegais,
      extensoesArquivoCol: extensoesArquivo,
      unidadesCol: unidades,
      usuariosCol: usuarios,
    };
  }
}
