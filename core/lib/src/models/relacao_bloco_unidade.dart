import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Disponibilização de um bloco para uma unidade, gravável em
/// `rel_bloco_unidade`.
///
/// Uma linha existe para cada unidade que já teve acesso ao bloco, a começar
/// pela própria unidade geradora. As três sinalizações da tela Blocos —
/// Prioritário, Revisado e Comentado, descritas no manual do usuário — batem
/// com [prioridade], [revisado] e [comentado] aqui: cada uma guarda também o
/// usuário e o momento em que foi marcada, exatamente como o manual descreve
/// ("ao posicionar o cursor sobre o ícone, será possível visualizar o
/// usuário... bem como a data e a hora").
///
/// [retornado] é a hipótese local, ainda não comprovada por nenhuma linha do
/// dump histórico (as 204 observadas são todas `N`), para o estado
/// "Retornado" que o manual atribui ao bloco — ver a lacuna registrada em
/// `EstadoBloco` e em `backend/docs/evidencias_processo_detalhe.md`.
///
/// A chave primária é composta por [idBloco] e [idUnidade], os dois
/// atribuídos pela aplicação, sem `DEFAULT` no banco, e por isso os dois
/// participam de [toInsertMap].
class RelacaoBlocoUnidade extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'rel_bloco_unidade';
  static const String fqtn = '$schemaName.$tableName';

  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idBlocoCol = 'id_bloco';
  static const String idBlocoFqCol = '$fqtn.$idBlocoCol';
  static const String retornadoCol = 'sin_retornado';
  static const String retornadoFqCol = '$fqtn.$retornadoCol';
  static const String idUsuarioAtribuicaoCol = 'id_usuario_atribuicao';
  static const String idUsuarioAtribuicaoFqCol =
      '$fqtn.$idUsuarioAtribuicaoCol';
  static const String idUsuarioRevisaoCol = 'id_usuario_revisao';
  static const String idUsuarioRevisaoFqCol = '$fqtn.$idUsuarioRevisaoCol';
  static const String idUsuarioPrioridadeCol = 'id_usuario_prioridade';
  static const String idUsuarioPrioridadeFqCol =
      '$fqtn.$idUsuarioPrioridadeCol';
  static const String idUsuarioComentarioCol = 'id_usuario_comentario';
  static const String idUsuarioComentarioFqCol =
      '$fqtn.$idUsuarioComentarioCol';
  static const String revisadoCol = 'sin_revisao';
  static const String revisadoFqCol = '$fqtn.$revisadoCol';
  static const String prioridadeCol = 'sin_prioridade';
  static const String prioridadeFqCol = '$fqtn.$prioridadeCol';
  static const String comentadoCol = 'sin_comentario';
  static const String comentadoFqCol = '$fqtn.$comentadoCol';
  static const String textoComentarioCol = 'texto_comentario';
  static const String textoComentarioFqCol = '$fqtn.$textoComentarioCol';
  static const String dataRevisaoCol = 'dth_revisao';
  static const String dataRevisaoFqCol = '$fqtn.$dataRevisaoCol';
  static const String dataPrioridadeCol = 'dth_prioridade';
  static const String dataPrioridadeFqCol = '$fqtn.$dataPrioridadeCol';
  static const String dataComentarioCol = 'dth_comentario';
  static const String dataComentarioFqCol = '$fqtn.$dataComentarioCol';
  static const String idGrupoBlocoCol = 'id_grupo_bloco';
  static const String idGrupoBlocoFqCol = '$fqtn.$idGrupoBlocoCol';

  RelacaoBlocoUnidade({
    required this.idUnidade,
    required this.idBloco,
    this.retornado = false,
    this.revisado = false,
    this.prioridade = false,
    this.comentado = false,
    this.idUsuarioAtribuicao,
    this.idUsuarioRevisao,
    this.idUsuarioPrioridade,
    this.idUsuarioComentario,
    this.textoComentario,
    this.dataRevisao,
    this.dataPrioridade,
    this.dataComentario,
    this.idGrupoBloco,
  });

  factory RelacaoBlocoUnidade.fromMap(Map<String, dynamic> map) {
    return RelacaoBlocoUnidade(
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      idBloco: SeiCoreUtils.inteiro(map[idBlocoCol], nomeCampo: idBlocoCol),
      retornado: SeiCoreUtils.simNaoParaBool(
        (map[retornadoCol] as String).trim(),
        nomeCampo: retornadoCol,
      ),
      idUsuarioAtribuicao: map[idUsuarioAtribuicaoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUsuarioAtribuicaoCol],
              nomeCampo: idUsuarioAtribuicaoCol,
            ),
      idUsuarioRevisao: map[idUsuarioRevisaoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUsuarioRevisaoCol],
              nomeCampo: idUsuarioRevisaoCol,
            ),
      idUsuarioPrioridade: map[idUsuarioPrioridadeCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUsuarioPrioridadeCol],
              nomeCampo: idUsuarioPrioridadeCol,
            ),
      idUsuarioComentario: map[idUsuarioComentarioCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUsuarioComentarioCol],
              nomeCampo: idUsuarioComentarioCol,
            ),
      revisado: SeiCoreUtils.simNaoParaBool(
        (map[revisadoCol] as String).trim(),
        nomeCampo: revisadoCol,
      ),
      prioridade: SeiCoreUtils.simNaoParaBool(
        (map[prioridadeCol] as String).trim(),
        nomeCampo: prioridadeCol,
      ),
      comentado: SeiCoreUtils.simNaoParaBool(
        (map[comentadoCol] as String).trim(),
        nomeCampo: comentadoCol,
      ),
      textoComentario: map[textoComentarioCol] as String?,
      dataRevisao: map[dataRevisaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataRevisaoCol],
              nomeCampo: dataRevisaoCol,
            ),
      dataPrioridade: map[dataPrioridadeCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataPrioridadeCol],
              nomeCampo: dataPrioridadeCol,
            ),
      dataComentario: map[dataComentarioCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataComentarioCol],
              nomeCampo: dataComentarioCol,
            ),
      idGrupoBloco: map[idGrupoBlocoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idGrupoBlocoCol],
              nomeCampo: idGrupoBlocoCol,
            ),
    );
  }

  final int idUnidade;
  final int idBloco;

  /// Indica que esta unidade já devolveu o bloco à unidade geradora.
  final bool retornado;

  final int? idUsuarioAtribuicao;
  final int? idUsuarioRevisao;
  final int? idUsuarioPrioridade;
  final int? idUsuarioComentario;

  /// Sinalização "Revisado" da tela Blocos.
  final bool revisado;

  /// Sinalização "Prioritário" da tela Blocos.
  final bool prioridade;

  /// Sinalização "Comentado" da tela Blocos.
  final bool comentado;

  final String? textoComentario;
  final DateTime? dataRevisao;
  final DateTime? dataPrioridade;
  final DateTime? dataComentario;

  /// Grupo ao qual esta unidade classificou o bloco, próprio desta relação.
  final int? idGrupoBloco;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idUnidadeCol: idUnidade,
      idBlocoCol: idBloco,
      retornadoCol: SeiCoreUtils.boolParaSimNao(retornado),
      idUsuarioAtribuicaoCol: idUsuarioAtribuicao,
      idUsuarioRevisaoCol: idUsuarioRevisao,
      idUsuarioPrioridadeCol: idUsuarioPrioridade,
      idUsuarioComentarioCol: idUsuarioComentario,
      revisadoCol: SeiCoreUtils.boolParaSimNao(revisado),
      prioridadeCol: SeiCoreUtils.boolParaSimNao(prioridade),
      comentadoCol: SeiCoreUtils.boolParaSimNao(comentado),
      textoComentarioCol: textoComentario,
      dataRevisaoCol: dataRevisao,
      dataPrioridadeCol: dataPrioridade,
      dataComentarioCol: dataComentario,
      idGrupoBlocoCol: idGrupoBloco,
    };
  }

  /// Mapa de inserção com a chave composta atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem as duas colunas da chave composta.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idUnidadeCol);
    mapa.remove(idBlocoCol);
    return mapa;
  }
}
