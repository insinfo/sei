import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Recurso (tela ou ação) cadastrado no SIP para um sistema.
///
/// Projeção somente leitura de `public.recurso`. A chave é composta por
/// `id_recurso` e `id_sistema`: são 1.578 linhas na Base de Referência,
/// divididas entre o SIP (234) e o SEI (1.344). Um perfil libera um recurso
/// através de `rel_perfil_recurso`, e é essa liberação que autoriza a tela
/// ou ação correspondente.
class RecursoSip extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'recurso';
  static const String fqtn = '$schemaName.$tableName';

  static const String idSistemaCol = 'id_sistema';
  static const String idSistemaFqCol = '$fqtn.$idSistemaCol';
  static const String idRecursoCol = 'id_recurso';
  static const String idRecursoFqCol = '$fqtn.$idRecursoCol';
  static const String nomeCol = 'nome';
  static const String nomeFqCol = '$fqtn.$nomeCol';
  static const String descricaoCol = 'descricao';
  static const String descricaoFqCol = '$fqtn.$descricaoCol';
  static const String caminhoCol = 'caminho';
  static const String caminhoFqCol = '$fqtn.$caminhoCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';

  RecursoSip({
    required this.idSistema,
    required this.idRecurso,
    required this.nome,
    this.descricao,
    required this.caminho,
    required this.ativo,
  });

  factory RecursoSip.fromMap(Map<String, dynamic> map) {
    return RecursoSip(
      idSistema: SeiCoreUtils.inteiro(
        map[idSistemaCol],
        nomeCampo: idSistemaCol,
      ),
      idRecurso: SeiCoreUtils.inteiro(
        map[idRecursoCol],
        nomeCampo: idRecursoCol,
      ),
      nome: map[nomeCol] as String,
      descricao: map[descricaoCol] as String?,
      caminho: map[caminhoCol] as String,
      ativo: SeiCoreUtils.simNaoParaBool(
        map[ativoCol] as String,
        nomeCampo: ativoCol,
      ),
    );
  }

  final int idSistema;
  final int idRecurso;
  final String nome;
  final String? descricao;

  /// Identificador funcional do recurso, usado pela tela para checar acesso.
  final String caminho;

  /// Situação do cadastro do recurso no catálogo do SIP.
  final bool ativo;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idSistemaCol: idSistema,
      idRecursoCol: idRecurso,
      nomeCol: nome,
      descricaoCol: descricao,
      caminhoCol: caminho,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
    };
  }
}
