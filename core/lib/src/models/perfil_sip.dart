import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Perfil de acesso cadastrado no SIP para um sistema.
///
/// Projeção somente leitura de `public.perfil`. A chave é composta por
/// `id_perfil` e `id_sistema`: o mesmo número de perfil pode existir em mais
/// de um sistema, com significado independente em cada um.
class PerfilSip extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'perfil';
  static const String fqtn = '$schemaName.$tableName';

  static const String idPerfilCol = 'id_perfil';
  static const String idPerfilFqCol = '$fqtn.$idPerfilCol';
  static const String idSistemaCol = 'id_sistema';
  static const String idSistemaFqCol = '$fqtn.$idSistemaCol';
  static const String nomeCol = 'nome';
  static const String nomeFqCol = '$fqtn.$nomeCol';
  static const String descricaoCol = 'descricao';
  static const String descricaoFqCol = '$fqtn.$descricaoCol';
  static const String coordenadoCol = 'sin_coordenado';
  static const String coordenadoFqCol = '$fqtn.$coordenadoCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';
  static const String doisFatoresCol = 'sin_2_fatores';
  static const String doisFatoresFqCol = '$fqtn.$doisFatoresCol';

  PerfilSip({
    required this.idPerfil,
    required this.idSistema,
    required this.nome,
    this.descricao,
    required this.coordenado,
    required this.ativo,
    required this.doisFatores,
  });

  factory PerfilSip.fromMap(Map<String, dynamic> map) {
    return PerfilSip(
      idPerfil: SeiCoreUtils.inteiro(map[idPerfilCol], nomeCampo: idPerfilCol),
      idSistema: SeiCoreUtils.inteiro(
        map[idSistemaCol],
        nomeCampo: idSistemaCol,
      ),
      nome: map[nomeCol] as String,
      descricao: map[descricaoCol] as String?,
      coordenado: SeiCoreUtils.simNaoParaBool(
        map[coordenadoCol] as String,
        nomeCampo: coordenadoCol,
      ),
      ativo: SeiCoreUtils.simNaoParaBool(
        map[ativoCol] as String,
        nomeCampo: ativoCol,
      ),
      doisFatores: SeiCoreUtils.simNaoParaBool(
        map[doisFatoresCol] as String,
        nomeCampo: doisFatoresCol,
      ),
    );
  }

  final int idPerfil;
  final int idSistema;
  final String nome;
  final String? descricao;

  /// Indica se o perfil é coordenado, ou seja, exige aprovação de um
  /// coordenador para ser concedido.
  final bool coordenado;

  /// Situação do cadastro do perfil no catálogo do SIP.
  ///
  /// Independente da vigência de uma concessão específica em [PerfilAtivo]:
  /// um perfil pode estar desativado no catálogo mesmo com uma permissão
  /// ainda dentro da janela `dta_inicio`/`dta_fim`.
  final bool ativo;

  /// Indica se o perfil exige segundo fator de autenticação.
  final bool doisFatores;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idPerfilCol: idPerfil,
      idSistemaCol: idSistema,
      nomeCol: nome,
      descricaoCol: descricao,
      coordenadoCol: SeiCoreUtils.boolParaSimNao(coordenado),
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
      doisFatoresCol: SeiCoreUtils.boolParaSimNao(doisFatores),
    };
  }
}
