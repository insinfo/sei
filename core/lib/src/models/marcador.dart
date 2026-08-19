import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Etiqueta de organização interna da unidade, gravável em `marcador`.
///
/// O manual do usuário registra 32 opções de cor para marcadores. Os dados
/// reais confirmam a natureza numérica de `sta_icone`: os valores observados
/// vão de `0` a `31`, guardados como texto porque a coluna é
/// `character varying`.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap]. Um marcador já utilizado não pode ser
/// excluído, apenas desativado — esta entidade não impõe essa regra, que
/// pertence à camada de service.
class Marcador extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'marcador';
  static const String fqtn = '$schemaName.$tableName';

  static const String idMarcadorCol = 'id_marcador';
  static const String idMarcadorFqCol = '$fqtn.$idMarcadorCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String nomeCol = 'nome';
  static const String nomeFqCol = '$fqtn.$nomeCol';
  static const String descricaoCol = 'descricao';
  static const String descricaoFqCol = '$fqtn.$descricaoCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';
  static const String iconeCol = 'sta_icone';
  static const String iconeFqCol = '$fqtn.$iconeCol';

  Marcador({
    required this.idMarcador,
    required this.idUnidade,
    required this.nome,
    required this.icone,
    this.ativo = true,
    this.descricao,
  });

  factory Marcador.fromMap(Map<String, dynamic> map) {
    return Marcador(
      idMarcador: SeiCoreUtils.inteiro(
        map[idMarcadorCol],
        nomeCampo: idMarcadorCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      nome: map[nomeCol] as String,
      descricao: map[descricaoCol] as String?,
      ativo: map[ativoCol] == null
          ? true
          : SeiCoreUtils.simNaoParaBool(
              (map[ativoCol] as String).trim(),
              nomeCampo: ativoCol,
            ),
      icone: (map[iconeCol] as String).trim(),
    );
  }

  /// Identificador do marcador, atribuído pela aplicação.
  final int idMarcador;

  /// Unidade que criou o marcador; a gestão é exclusiva dela.
  final int idUnidade;
  final String nome;
  final String? descricao;
  final bool ativo;

  /// Índice do ícone dentre as 32 opções de cor do SEI, gravado como texto.
  final String icone;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idMarcadorCol: idMarcador,
      idUnidadeCol: idUnidade,
      nomeCol: nome,
      descricaoCol: descricao,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
      iconeCol: icone,
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idMarcadorCol);
    return mapa;
  }
}
