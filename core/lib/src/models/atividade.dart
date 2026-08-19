import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Andamento de um protocolo em uma unidade, gravável em `atividade`.
///
/// Esta é a tabela que carrega o estado operacional do SEI. Não existe uma
/// coluna de processo aberto ou concluído: a unidade tem o processo aberto
/// enquanto houver uma linha sua com [dataConclusao] nula. Concluir é
/// preencher essa data; reabrir é lançar um andamento novo em aberto.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap].
class Atividade extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'atividade';
  static const String fqtn = '$schemaName.$tableName';

  static const String idAtividadeCol = 'id_atividade';
  static const String idAtividadeFqCol = '$fqtn.$idAtividadeCol';
  static const String idProtocoloCol = 'id_protocolo';
  static const String idProtocoloFqCol = '$fqtn.$idProtocoloCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idTarefaCol = 'id_tarefa';
  static const String idTarefaFqCol = '$fqtn.$idTarefaCol';
  static const String idUnidadeOrigemCol = 'id_unidade_origem';
  static const String idUnidadeOrigemFqCol = '$fqtn.$idUnidadeOrigemCol';
  static const String idUsuarioConclusaoCol = 'id_usuario_conclusao';
  static const String idUsuarioConclusaoFqCol = '$fqtn.$idUsuarioConclusaoCol';
  static const String idUsuarioVisualizacaoCol = 'id_usuario_visualizacao';
  static const String idUsuarioVisualizacaoFqCol =
      '$fqtn.$idUsuarioVisualizacaoCol';
  static const String idUsuarioAtribuicaoCol = 'id_usuario_atribuicao';
  static const String idUsuarioAtribuicaoFqCol =
      '$fqtn.$idUsuarioAtribuicaoCol';
  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String idUsuarioOrigemCol = 'id_usuario_origem';
  static const String idUsuarioOrigemFqCol = '$fqtn.$idUsuarioOrigemCol';
  static const String dataAberturaCol = 'dth_abertura';
  static const String dataAberturaFqCol = '$fqtn.$dataAberturaCol';
  static const String dataConclusaoCol = 'dth_conclusao';
  static const String dataConclusaoFqCol = '$fqtn.$dataConclusaoCol';
  static const String inicialCol = 'sin_inicial';
  static const String inicialFqCol = '$fqtn.$inicialCol';
  static const String dataPrazoCol = 'dta_prazo';
  static const String dataPrazoFqCol = '$fqtn.$dataPrazoCol';
  static const String tipoVisualizacaoCol = 'tipo_visualizacao';
  static const String tipoVisualizacaoFqCol = '$fqtn.$tipoVisualizacaoCol';

  Atividade({
    required this.idAtividade,
    required this.idProtocolo,
    required this.idUnidade,
    required this.idUnidadeOrigem,
    required this.idUsuarioOrigem,
    required this.dataAbertura,
    required this.inicial,
    this.idTarefa,
    this.idUsuarioConclusao,
    this.idUsuarioVisualizacao,
    this.idUsuarioAtribuicao,
    this.idUsuario,
    this.dataConclusao,
    this.dataPrazo,
    this.tipoVisualizacao = tipoVisualizacaoPadrao,
  });

  factory Atividade.fromMap(Map<String, dynamic> map) {
    return Atividade(
      idAtividade: SeiCoreUtils.inteiro(
        map[idAtividadeCol],
        nomeCampo: idAtividadeCol,
      ),
      idProtocolo: SeiCoreUtils.inteiro(
        map[idProtocoloCol],
        nomeCampo: idProtocoloCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      idTarefa: map[idTarefaCol] == null
          ? null
          : SeiCoreUtils.inteiro(map[idTarefaCol], nomeCampo: idTarefaCol),
      idUnidadeOrigem: SeiCoreUtils.inteiro(
        map[idUnidadeOrigemCol],
        nomeCampo: idUnidadeOrigemCol,
      ),
      idUsuarioConclusao: map[idUsuarioConclusaoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUsuarioConclusaoCol],
              nomeCampo: idUsuarioConclusaoCol,
            ),
      idUsuarioVisualizacao: map[idUsuarioVisualizacaoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUsuarioVisualizacaoCol],
              nomeCampo: idUsuarioVisualizacaoCol,
            ),
      idUsuarioAtribuicao: map[idUsuarioAtribuicaoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUsuarioAtribuicaoCol],
              nomeCampo: idUsuarioAtribuicaoCol,
            ),
      idUsuario: map[idUsuarioCol] == null
          ? null
          : SeiCoreUtils.inteiro(map[idUsuarioCol], nomeCampo: idUsuarioCol),
      idUsuarioOrigem: SeiCoreUtils.inteiro(
        map[idUsuarioOrigemCol],
        nomeCampo: idUsuarioOrigemCol,
      ),
      dataAbertura: SeiCoreUtils.dataHoraLocal(
        map[dataAberturaCol],
        nomeCampo: dataAberturaCol,
      ),
      dataConclusao: map[dataConclusaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataConclusaoCol],
              nomeCampo: dataConclusaoCol,
            ),
      inicial: SeiCoreUtils.simNaoParaBool(
        (map[inicialCol] as String).trim(),
        nomeCampo: inicialCol,
      ),
      dataPrazo: map[dataPrazoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataPrazoCol],
              nomeCampo: dataPrazoCol,
            ),
      tipoVisualizacao: SeiCoreUtils.inteiro(
        map[tipoVisualizacaoCol],
        nomeCampo: tipoVisualizacaoCol,
      ),
    );
  }

  /// Valor mais frequente de `tipo_visualizacao` no dump histórico local,
  /// presente em 4.301 das 4.830 atividades.
  static const int tipoVisualizacaoPadrao = 0;

  /// Identificador da atividade, atribuído pela aplicação.
  final int idAtividade;
  final int idProtocolo;

  /// Unidade que responde pelo processo enquanto a atividade estiver aberta.
  final int idUnidade;

  /// Tipo de andamento; suas marcações em `tarefa` decidem o efeito do evento
  /// sobre as atividades abertas da unidade.
  final int? idTarefa;

  final int idUnidadeOrigem;
  final int? idUsuarioConclusao;
  final int? idUsuarioVisualizacao;

  /// Usuário a quem o processo está atribuído na unidade.
  final int? idUsuarioAtribuicao;

  final int? idUsuario;
  final int idUsuarioOrigem;
  final DateTime dataAbertura;

  /// Enquanto for nula, o processo está aberto nesta unidade.
  final DateTime? dataConclusao;

  /// Indica atividade inicial: separa a coluna Gerados da coluna Recebidos no
  /// Controle de Processos.
  final bool inicial;

  final DateTime? dataPrazo;
  final int tipoVisualizacao;

  /// Indica que a unidade ainda responde pelo processo.
  bool get aberta => dataConclusao == null;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idAtividadeCol: idAtividade,
      idProtocoloCol: idProtocolo,
      idUnidadeCol: idUnidade,
      idTarefaCol: idTarefa,
      idUnidadeOrigemCol: idUnidadeOrigem,
      idUsuarioConclusaoCol: idUsuarioConclusao,
      idUsuarioVisualizacaoCol: idUsuarioVisualizacao,
      idUsuarioAtribuicaoCol: idUsuarioAtribuicao,
      idUsuarioCol: idUsuario,
      idUsuarioOrigemCol: idUsuarioOrigem,
      dataAberturaCol: dataAbertura,
      dataConclusaoCol: dataConclusao,
      inicialCol: SeiCoreUtils.boolParaSimNao(inicial),
      dataPrazoCol: dataPrazo,
      tipoVisualizacaoCol: tipoVisualizacao,
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idAtividadeCol);
    return mapa;
  }
}
