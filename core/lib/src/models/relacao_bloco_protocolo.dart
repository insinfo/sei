import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Vínculo entre um bloco e um protocolo, gravável em `rel_bloco_protocolo`.
///
/// `id_protocolo` é genérico: aceita tanto processo quanto documento, porque
/// os dois são `protocolo`. Um bloco de Assinatura vincula documentos; um
/// bloco de Reunião ou Interno vincula processos — comprovado em
/// `backend/docs/evidencias_processo_detalhe.md`.
///
/// A chave primária é composta por [idBloco] e [idProtocolo], os dois
/// atribuídos pela aplicação, sem `DEFAULT` no banco, e por isso os dois
/// participam de [toInsertMap]. A coluna `idx_rel_bloco_protocolo` é índice
/// de busca textual mantido pelo próprio SEI, no mesmo padrão de
/// `idx_bloco`, e esta entidade não a grava.
class RelacaoBlocoProtocolo extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'rel_bloco_protocolo';
  static const String fqtn = '$schemaName.$tableName';

  static const String idProtocoloCol = 'id_protocolo';
  static const String idProtocoloFqCol = '$fqtn.$idProtocoloCol';
  static const String idBlocoCol = 'id_bloco';
  static const String idBlocoFqCol = '$fqtn.$idBlocoCol';
  static const String anotacaoCol = 'anotacao';
  static const String anotacaoFqCol = '$fqtn.$anotacaoCol';
  static const String sequenciaCol = 'sequencia';
  static const String sequenciaFqCol = '$fqtn.$sequenciaCol';

  RelacaoBlocoProtocolo({
    required this.idProtocolo,
    required this.idBloco,
    this.sequencia = 1,
    this.anotacao,
  });

  factory RelacaoBlocoProtocolo.fromMap(Map<String, dynamic> map) {
    return RelacaoBlocoProtocolo(
      idProtocolo: SeiCoreUtils.inteiro(
        map[idProtocoloCol],
        nomeCampo: idProtocoloCol,
      ),
      idBloco: SeiCoreUtils.inteiro(map[idBlocoCol], nomeCampo: idBlocoCol),
      sequencia: SeiCoreUtils.inteiro(
        map[sequenciaCol],
        nomeCampo: sequenciaCol,
      ),
      anotacao: map[anotacaoCol] as String?,
    );
  }

  /// Protocolo vinculado ao bloco; pode ser processo ou documento.
  final int idProtocolo;

  /// Bloco ao qual o protocolo foi incluído.
  final int idBloco;

  /// Ordem do protocolo dentro do bloco.
  final int sequencia;

  /// Anotação exclusiva desta linha, feita ao incluir o protocolo no bloco.
  final String? anotacao;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idProtocoloCol: idProtocolo,
      idBlocoCol: idBloco,
      anotacaoCol: anotacao,
      sequenciaCol: sequencia,
    };
  }

  /// Mapa de inserção com a chave composta atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem as duas colunas da chave composta.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idProtocoloCol);
    mapa.remove(idBlocoCol);
    return mapa;
  }
}
