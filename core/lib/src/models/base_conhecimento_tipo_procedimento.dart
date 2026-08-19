import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Vínculo entre uma base de conhecimento e um tipo de processo, gravável em
/// `rel_base_conhec_tipo_proced`.
///
/// A Base de Conhecimento é associada ao **tipo de processo**, não a um
/// processo específico; é essa indireção que sustenta o ícone "B" exibido ao
/// lado de qualquer processo cujo tipo tenha uma base vinculada.
///
/// A chave primária é composta por [idBaseConhecimento] e
/// [idTipoProcedimento], os dois atribuídos pela aplicação, sem `DEFAULT` no
/// banco, e por isso os dois participam de [toInsertMap]. A tabela não tem
/// nenhuma outra coluna, então [toUpdateMap] sempre devolve um mapa vazio —
/// esta relação só é criada ou removida, nunca atualizada.
class BaseConhecimentoTipoProcedimento extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'rel_base_conhec_tipo_proced';
  static const String fqtn = '$schemaName.$tableName';

  static const String idTipoProcedimentoCol = 'id_tipo_procedimento';
  static const String idTipoProcedimentoFqCol = '$fqtn.$idTipoProcedimentoCol';
  static const String idBaseConhecimentoCol = 'id_base_conhecimento';
  static const String idBaseConhecimentoFqCol = '$fqtn.$idBaseConhecimentoCol';

  BaseConhecimentoTipoProcedimento({
    required this.idTipoProcedimento,
    required this.idBaseConhecimento,
  });

  factory BaseConhecimentoTipoProcedimento.fromMap(
    Map<String, dynamic> map,
  ) {
    return BaseConhecimentoTipoProcedimento(
      idTipoProcedimento: SeiCoreUtils.inteiro(
        map[idTipoProcedimentoCol],
        nomeCampo: idTipoProcedimentoCol,
      ),
      idBaseConhecimento: SeiCoreUtils.inteiro(
        map[idBaseConhecimentoCol],
        nomeCampo: idBaseConhecimentoCol,
      ),
    );
  }

  final int idTipoProcedimento;
  final int idBaseConhecimento;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idTipoProcedimentoCol: idTipoProcedimento,
      idBaseConhecimentoCol: idBaseConhecimento,
    };
  }

  /// Mapa de inserção com a chave composta atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização vazio: as duas colunas da tabela formam a chave
  /// composta, e não há nenhuma outra coluna para atualizar.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idTipoProcedimentoCol);
    mapa.remove(idBaseConhecimentoCol);
    return mapa;
  }
}
