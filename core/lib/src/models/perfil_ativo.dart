import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/perfil_sip.dart';
import 'package:sei_core/src/models/tipo_permissao.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Perfil concedido a um usuário em uma unidade, vigente na janela de tempo
/// da concessão.
///
/// Projeção de `public.permissao` unida a `public.perfil` pela chave
/// composta `(id_perfil, id_sistema)`. "Vigente" aqui segue exclusivamente
/// `dta_inicio`/`dta_fim` de `permissao`: uma concessão vale quando
/// `dta_inicio` já passou e (`dta_fim` é nulo ou ainda não passou). Isso é
/// independente do `sin_ativo` do catálogo de [perfil] — os dois campos não
/// têm relação entre si e por isso ambos são preservados.
///
/// Este DTO resolve autorização, não autenticação: a identidade do usuário
/// (`idUsuario`) e a unidade corrente (`idUnidade`) já chegam resolvidas por
/// outro mecanismo. Ver `AutorizacaoUsuario` para o porquê.
class PerfilAtivo extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'permissao';
  static const String fqtn = '$schemaName.$tableName';

  static const String idPerfilCol = 'id_perfil';
  static const String idPerfilFqCol = '$fqtn.$idPerfilCol';
  static const String idSistemaCol = 'id_sistema';
  static const String idSistemaFqCol = '$fqtn.$idSistemaCol';
  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idTipoPermissaoCol = 'id_tipo_permissao';
  static const String idTipoPermissaoFqCol = '$fqtn.$idTipoPermissaoCol';
  static const String dataInicioCol = 'dta_inicio';
  static const String dataInicioFqCol = '$fqtn.$dataInicioCol';
  static const String dataFimCol = 'dta_fim';
  static const String dataFimFqCol = '$fqtn.$dataFimCol';
  static const String subunidadesCol = 'sin_subunidades';
  static const String subunidadesFqCol = '$fqtn.$subunidadesCol';

  /// Chave do envelope usado em [toMap]/[fromMap] para o [perfil] aninhado.
  static const String perfilCol = 'perfil';

  PerfilAtivo({
    required this.perfil,
    required this.tipoPermissao,
    required this.dataInicio,
    this.dataFim,
    required this.subunidades,
  });

  /// Reconstrói a partir do contrato JSON emitido por [toMap].
  factory PerfilAtivo.fromMap(Map<String, dynamic> map) {
    final Object? perfilBruto = map[perfilCol];
    if (perfilBruto is! Map<String, dynamic>) {
      throw FormatException('O campo $perfilCol deve conter um objeto.');
    }
    return _fromCampos(map, PerfilSip.fromMap(perfilBruto));
  }

  /// Constrói a partir de uma linha de junção de `permissao` com `perfil`.
  factory PerfilAtivo.fromConsultaRow(Map<String, dynamic> row) {
    return _fromCampos(row, PerfilSip.fromMap(row));
  }

  static PerfilAtivo _fromCampos(
    Map<String, dynamic> campos,
    PerfilSip perfil,
  ) {
    return PerfilAtivo(
      perfil: perfil,
      tipoPermissao: TipoPermissao.fromId(
        SeiCoreUtils.inteiro(
          campos[idTipoPermissaoCol],
          nomeCampo: idTipoPermissaoCol,
        ),
      ),
      dataInicio: SeiCoreUtils.dataHoraLocal(
        campos[dataInicioCol],
        nomeCampo: dataInicioCol,
      ),
      dataFim: campos[dataFimCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              campos[dataFimCol],
              nomeCampo: dataFimCol,
            ),
      subunidades: SeiCoreUtils.simNaoParaBool(
        campos[subunidadesCol] as String,
        nomeCampo: subunidadesCol,
      ),
    );
  }

  /// Catálogo do perfil concedido, com o `sin_ativo` do próprio cadastro.
  final PerfilSip perfil;

  /// Regra de repasse desta concessão específica.
  final TipoPermissao tipoPermissao;

  /// Início de vigência da concessão.
  final DateTime dataInicio;

  /// Fim de vigência da concessão, ou `null` quando não expira.
  final DateTime? dataFim;

  /// Indica se a concessão também vale para as subunidades da [idUnidade]
  /// original da permissão.
  final bool subunidades;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      perfilCol: perfil.toMap(),
      idTipoPermissaoCol: tipoPermissao.id,
      dataInicioCol: dataInicio.toIso8601String(),
      dataFimCol: dataFim?.toIso8601String(),
      subunidadesCol: SeiCoreUtils.boolParaSimNao(subunidades),
    };
  }
}
