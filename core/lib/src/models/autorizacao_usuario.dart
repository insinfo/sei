import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/perfil_ativo.dart';
import 'package:sei_core/src/models/recurso_sip.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Resolução de autorização do SIP para um usuário em uma unidade.
///
/// **Isto não é autenticação.** A Base de Referência não guarda senha nem
/// hash algum: `public.usuario` não tem nenhuma coluna de credencial, e
/// `servidor_autenticacao` tem só 2 linhas reais, ambas `sta_tipo = 'AD'`
/// (Active Directory), delegando a verificação de identidade a um LDAP/AD
/// externo por órgão que não existe neste laboratório local. A fronteira
/// entre os dois está registrada em
/// `backend/docs/evidencias_processo_detalhe.md`.
///
/// Este DTO resolve só a metade de autorização: dado um `idUsuario` e um
/// `idUnidade` já conhecidos por outro mecanismo (o contexto de
/// desenvolvimento do projeto, hoje não autenticado), quais [perfis] estão
/// vigentes e quais [recursos] (telas/ações do SEI e do SIP) esses perfis
/// liberam.
class AutorizacaoUsuario extends BaseModel {
  static const String schemaName = 'public';

  /// `rel_perfil_recurso` não tem DTO de catálogo próprio: é só a ponte N:N
  /// entre `perfil` e `recurso` usada para resolver [recursos], sem colunas
  /// de saída próprias.
  static const String tableRelPerfilRecurso = 'rel_perfil_recurso';
  static const String fqtnRelPerfilRecurso =
      '$schemaName.$tableRelPerfilRecurso';

  static const String relIdPerfilCol = 'id_perfil';
  static const String relIdPerfilFqCol =
      '$fqtnRelPerfilRecurso.$relIdPerfilCol';
  static const String relIdSistemaCol = 'id_sistema';
  static const String relIdSistemaFqCol =
      '$fqtnRelPerfilRecurso.$relIdSistemaCol';
  static const String relIdRecursoCol = 'id_recurso';
  static const String relIdRecursoFqCol =
      '$fqtnRelPerfilRecurso.$relIdRecursoCol';

  static const String idUsuarioCol = 'id_usuario';
  static const String idUnidadeCol = 'id_unidade';
  static const String perfisCol = 'perfis';
  static const String recursosCol = 'recursos';

  AutorizacaoUsuario({
    required this.idUsuario,
    required this.idUnidade,
    required this.perfis,
    required this.recursos,
  });

  factory AutorizacaoUsuario.fromMap(Map<String, dynamic> map) {
    final Object? perfisBrutos = map[perfisCol];
    if (perfisBrutos is! List<Object?>) {
      throw FormatException('O campo $perfisCol deve conter uma lista.');
    }
    final perfis = <PerfilAtivo>[];
    for (final Object? perfilBruto in perfisBrutos) {
      if (perfilBruto is! Map<String, dynamic>) {
        throw FormatException('Cada item de $perfisCol deve ser um objeto.');
      }
      perfis.add(PerfilAtivo.fromMap(perfilBruto));
    }

    final Object? recursosBrutos = map[recursosCol];
    if (recursosBrutos is! List<Object?>) {
      throw FormatException('O campo $recursosCol deve conter uma lista.');
    }
    final recursos = <RecursoSip>[];
    for (final Object? recursoBruto in recursosBrutos) {
      if (recursoBruto is! Map<String, dynamic>) {
        throw FormatException(
          'Cada item de $recursosCol deve ser um objeto.',
        );
      }
      recursos.add(RecursoSip.fromMap(recursoBruto));
    }

    return AutorizacaoUsuario(
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      perfis: perfis,
      recursos: recursos,
    );
  }

  final int idUsuario;
  final int idUnidade;

  /// Perfis vigentes na janela `dta_inicio`/`dta_fim` da concessão.
  final List<PerfilAtivo> perfis;

  /// Recursos liberados por qualquer um dos [perfis], sem repetição — o
  /// mesmo recurso pode ser alcançado por mais de um perfil e aparece uma
  /// única vez aqui.
  final List<RecursoSip> recursos;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idUsuarioCol: idUsuario,
      idUnidadeCol: idUnidade,
      perfisCol: perfis
          .map((PerfilAtivo perfil) => perfil.toMap())
          .toList(growable: false),
      recursosCol: recursos
          .map((RecursoSip recurso) => recurso.toMap())
          .toList(growable: false),
    };
  }
}
