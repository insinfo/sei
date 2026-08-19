import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/estado_bloco.dart';
import 'package:sei_core/src/models/tipo_bloco.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Bloco de Assinatura, Reunião ou Interno, gravável em `bloco`.
///
/// É a mesma tabela para os três tipos descritos no manual do usuário; o que
/// muda é [tipo] e o que ele aceita conter — comprovado em
/// `backend/docs/evidencias_processo_detalhe.md`: blocos de Assinatura só
/// reúnem documentos, blocos de Reunião e Interno só reúnem processos. O
/// vínculo com cada protocolo vive em [RelacaoBlocoProtocolo].
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap]. A coluna `idx_bloco` é o índice de busca
/// textual mantido pelo próprio SEI sobre a descrição; assim como
/// `idx_acompanhamento` em `Acompanhamento`, a regra de normalização não está
/// comprovada e esta entidade não a grava.
class Bloco extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'bloco';
  static const String fqtn = '$schemaName.$tableName';

  static const String idBlocoCol = 'id_bloco';
  static const String idBlocoFqCol = '$fqtn.$idBlocoCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String descricaoCol = 'descricao';
  static const String descricaoFqCol = '$fqtn.$descricaoCol';
  static const String tipoCol = 'sta_tipo';
  static const String tipoFqCol = '$fqtn.$tipoCol';
  static const String estadoCol = 'sta_estado';
  static const String estadoFqCol = '$fqtn.$estadoCol';

  Bloco({
    required this.idBloco,
    required this.idUnidade,
    required this.idUsuario,
    required this.tipo,
    required this.estado,
    this.descricao,
  });

  factory Bloco.fromMap(Map<String, dynamic> map) {
    return Bloco(
      idBloco: SeiCoreUtils.inteiro(map[idBlocoCol], nomeCampo: idBlocoCol),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      descricao: map[descricaoCol] as String?,
      tipo: TipoBloco.fromValue(map[tipoCol] as String),
      estado: EstadoBloco.fromValue(map[estadoCol] as String),
    );
  }

  /// Identificador do bloco, atribuído pela aplicação.
  final int idBloco;

  /// Unidade geradora do bloco.
  final int idUnidade;

  /// Usuário que criou o bloco.
  final int idUsuario;

  final String? descricao;
  final TipoBloco tipo;
  final EstadoBloco estado;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idBlocoCol: idBloco,
      idUnidadeCol: idUnidade,
      idUsuarioCol: idUsuario,
      descricaoCol: descricao,
      tipoCol: tipo.valor,
      estadoCol: estado.valor,
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idBlocoCol);
    return mapa;
  }
}
