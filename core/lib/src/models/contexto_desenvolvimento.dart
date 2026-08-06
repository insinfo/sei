import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/unidade_resumo.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Contexto de navegação local enquanto a autenticação SIP ainda não foi ativada.
///
/// Os valores são lidos da referência restaurada e não constituem uma sessão
/// autenticada nem uma decisão de autorização.
class ContextoDesenvolvimento extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'usuario';
  static const String fqtn = '$schemaName.$tableName';

  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String idOrgaoCol = 'id_orgao';
  static const String idOrgaoFqCol = '$fqtn.$idOrgaoCol';
  static const String siglaUsuarioCol = 'sigla_usuario';
  static const String nomeUsuarioCol = 'nome_usuario';
  static const String usuarioSiglaSourceCol = 'sigla';
  static const String usuarioSiglaFqCol = '$fqtn.$usuarioSiglaSourceCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioNomeFqCol = '$fqtn.$usuarioNomeSourceCol';
  static const String usuarioAtivoSourceCol = 'sin_ativo';
  static const String usuarioAtivoFqCol = '$fqtn.$usuarioAtivoSourceCol';
  static const String unidadesCol = 'unidades';
  static const String idUnidadeInicialCol = 'id_unidade_inicial';

  ContextoDesenvolvimento({
    required this.idUsuario,
    required this.idOrgao,
    required this.siglaUsuario,
    required this.nomeUsuario,
    required this.unidades,
    required this.idUnidadeInicial,
  }) {
    if (unidades.isEmpty) {
      throw ArgumentError.value(
        unidades,
        unidadesCol,
        'O contexto de desenvolvimento deve conter ao menos uma unidade.',
      );
    }
    if (!unidades.any(
        (UnidadeResumo unidade) => unidade.idUnidade == idUnidadeInicial)) {
      throw ArgumentError.value(
        idUnidadeInicial,
        idUnidadeInicialCol,
        'A unidade inicial deve fazer parte do contexto de desenvolvimento.',
      );
    }
  }

  factory ContextoDesenvolvimento.fromMap(Map<String, dynamic> map) {
    final Object? unidadesBrutas = map[unidadesCol];
    if (unidadesBrutas is! List<Object?>) {
      throw FormatException('O campo $unidadesCol deve conter uma lista.');
    }

    final unidades = <UnidadeResumo>[];
    for (final Object? unidadeBruta in unidadesBrutas) {
      if (unidadeBruta is! Map<String, dynamic>) {
        throw FormatException(
          'Cada item de $unidadesCol deve conter uma unidade válida.',
        );
      }
      unidades.add(UnidadeResumo.fromMap(unidadeBruta));
    }

    return ContextoDesenvolvimento(
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      idOrgao: SeiCoreUtils.inteiro(
        map[idOrgaoCol],
        nomeCampo: idOrgaoCol,
      ),
      siglaUsuario: map[siglaUsuarioCol] as String,
      nomeUsuario: map[nomeUsuarioCol] as String,
      unidades: unidades,
      idUnidadeInicial: SeiCoreUtils.inteiro(
        map[idUnidadeInicialCol],
        nomeCampo: idUnidadeInicialCol,
      ),
    );
  }

  final int idUsuario;
  final int idOrgao;
  final String siglaUsuario;
  final String nomeUsuario;
  final List<UnidadeResumo> unidades;
  final int idUnidadeInicial;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idUsuarioCol: idUsuario,
      idOrgaoCol: idOrgao,
      siglaUsuarioCol: siglaUsuario,
      nomeUsuarioCol: nomeUsuario,
      unidadesCol: unidades
          .map((UnidadeResumo unidade) => unidade.toMap())
          .toList(growable: false),
      idUnidadeInicialCol: idUnidadeInicial,
    };
  }
}
