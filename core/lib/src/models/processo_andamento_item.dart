import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/processo_andamento_atributo.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Evento cronológico do histórico de um processo, originado de `atividade`.
///
/// Os atributos são carregados em uma projeção própria de
/// `atributo_andamento`, evitando multiplicar linhas da paginação principal.
class ProcessoAndamentoItem extends BaseModel {
  static const String schemaName = 'public';

  static const String atividadeFqtn = '$schemaName.atividade';
  static const String tarefaFqtn = '$schemaName.tarefa';
  static const String unidadeFqtn = '$schemaName.unidade';
  static const String usuarioFqtn = '$schemaName.usuario';

  static const String unidadeOrigemAlias = 'unidade_origem';
  static const String unidadeOrigemAliasTable =
      '$unidadeFqtn as $unidadeOrigemAlias';
  static const String usuarioOrigemAlias = 'usuario_origem';
  static const String usuarioOrigemAliasTable =
      '$usuarioFqtn as $usuarioOrigemAlias';
  static const String usuarioConclusaoAlias = 'usuario_conclusao';
  static const String usuarioConclusaoAliasTable =
      '$usuarioFqtn as $usuarioConclusaoAlias';

  static const String atividadeIdCol = 'id_atividade';
  static const String atividadeIdFqCol = '$atividadeFqtn.$atividadeIdCol';
  static const String atividadeIdProtocoloSourceCol = 'id_protocolo';
  static const String atividadeIdProtocoloFqCol =
      '$atividadeFqtn.$atividadeIdProtocoloSourceCol';
  static const String atividadeIdTarefaSourceCol = 'id_tarefa';
  static const String atividadeIdTarefaFqCol =
      '$atividadeFqtn.$atividadeIdTarefaSourceCol';
  static const String atividadeIdUnidadeSourceCol = 'id_unidade';
  static const String atividadeIdUnidadeFqCol =
      '$atividadeFqtn.$atividadeIdUnidadeSourceCol';
  static const String atividadeIdUnidadeOrigemSourceCol = 'id_unidade_origem';
  static const String atividadeIdUnidadeOrigemFqCol =
      '$atividadeFqtn.$atividadeIdUnidadeOrigemSourceCol';
  static const String atividadeIdUsuarioSourceCol = 'id_usuario';
  static const String atividadeIdUsuarioFqCol =
      '$atividadeFqtn.$atividadeIdUsuarioSourceCol';
  static const String atividadeIdUsuarioOrigemSourceCol = 'id_usuario_origem';
  static const String atividadeIdUsuarioOrigemFqCol =
      '$atividadeFqtn.$atividadeIdUsuarioOrigemSourceCol';
  static const String atividadeIdUsuarioConclusaoSourceCol =
      'id_usuario_conclusao';
  static const String atividadeIdUsuarioConclusaoFqCol =
      '$atividadeFqtn.$atividadeIdUsuarioConclusaoSourceCol';
  static const String atividadeAberturaSourceCol = 'dth_abertura';
  static const String atividadeAberturaFqCol =
      '$atividadeFqtn.$atividadeAberturaSourceCol';
  static const String atividadeConclusaoSourceCol = 'dth_conclusao';
  static const String atividadeConclusaoFqCol =
      '$atividadeFqtn.$atividadeConclusaoSourceCol';
  static const String atividadePrazoSourceCol = 'dta_prazo';
  static const String atividadePrazoFqCol =
      '$atividadeFqtn.$atividadePrazoSourceCol';
  static const String atividadeInicialSourceCol = 'sin_inicial';
  static const String atividadeInicialFqCol =
      '$atividadeFqtn.$atividadeInicialSourceCol';
  static const String atividadeTipoVisualizacaoSourceCol = 'tipo_visualizacao';
  static const String atividadeTipoVisualizacaoFqCol =
      '$atividadeFqtn.$atividadeTipoVisualizacaoSourceCol';

  static const String tarefaIdCol = 'id_tarefa';
  static const String tarefaIdFqCol = '$tarefaFqtn.$tarefaIdCol';
  static const String tarefaNomeSourceCol = 'nome';
  static const String tarefaNomeFqCol = '$tarefaFqtn.$tarefaNomeSourceCol';

  static const String unidadeIdCol = 'id_unidade';
  static const String unidadeIdFqCol = '$unidadeFqtn.$unidadeIdCol';
  static const String unidadeSiglaSourceCol = 'sigla';
  static const String unidadeSiglaFqCol = '$unidadeFqtn.$unidadeSiglaSourceCol';
  static const String unidadeDescricaoSourceCol = 'descricao';
  static const String unidadeDescricaoFqCol =
      '$unidadeFqtn.$unidadeDescricaoSourceCol';
  static const String unidadeOrigemIdFqCol =
      '$unidadeOrigemAlias.$unidadeIdCol';
  static const String unidadeOrigemSiglaFqCol =
      '$unidadeOrigemAlias.$unidadeSiglaSourceCol';
  static const String unidadeOrigemDescricaoFqCol =
      '$unidadeOrigemAlias.$unidadeDescricaoSourceCol';

  static const String usuarioIdCol = 'id_usuario';
  static const String usuarioIdFqCol = '$usuarioFqtn.$usuarioIdCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioNomeFqCol = '$usuarioFqtn.$usuarioNomeSourceCol';
  static const String usuarioOrigemIdFqCol =
      '$usuarioOrigemAlias.$usuarioIdCol';
  static const String usuarioOrigemNomeFqCol =
      '$usuarioOrigemAlias.$usuarioNomeSourceCol';
  static const String usuarioConclusaoIdFqCol =
      '$usuarioConclusaoAlias.$usuarioIdCol';
  static const String usuarioConclusaoNomeFqCol =
      '$usuarioConclusaoAlias.$usuarioNomeSourceCol';

  static const String idAtividadeCol = 'id_atividade';
  static const String idProcessoCol = 'id_processo';
  static const String idTarefaCol = 'id_tarefa';
  static const String tarefaNomeCol = 'tarefa_nome';
  static const String idUnidadeCol = 'id_unidade';
  static const String unidadeSiglaCol = 'unidade_sigla';
  static const String unidadeDescricaoCol = 'unidade_descricao';
  static const String idUnidadeOrigemCol = 'id_unidade_origem';
  static const String unidadeOrigemSiglaCol = 'unidade_origem_sigla';
  static const String unidadeOrigemDescricaoCol = 'unidade_origem_descricao';
  static const String idUsuarioCol = 'id_usuario';
  static const String usuarioNomeCol = 'usuario_nome';
  static const String idUsuarioOrigemCol = 'id_usuario_origem';
  static const String usuarioOrigemNomeCol = 'usuario_origem_nome';
  static const String idUsuarioConclusaoCol = 'id_usuario_conclusao';
  static const String usuarioConclusaoNomeCol = 'usuario_conclusao_nome';
  static const String dataAberturaCol = 'data_abertura';
  static const String dataConclusaoCol = 'data_conclusao';
  static const String dataPrazoCol = 'data_prazo';
  static const String atividadeInicialCol = 'atividade_inicial';
  static const String tipoVisualizacaoCol = 'tipo_visualizacao';
  static const String atributosCol = 'atributos';

  ProcessoAndamentoItem({
    required this.idAtividade,
    required this.idProcesso,
    required this.idUnidade,
    required this.unidadeSigla,
    required this.unidadeDescricao,
    required this.idUnidadeOrigem,
    required this.unidadeOrigemSigla,
    required this.unidadeOrigemDescricao,
    required this.idUsuarioOrigem,
    required this.usuarioOrigemNome,
    required this.dataAbertura,
    required this.atividadeInicial,
    required this.tipoVisualizacao,
    required this.atributos,
    this.idTarefa,
    this.tarefaNome,
    this.idUsuario,
    this.usuarioNome,
    this.idUsuarioConclusao,
    this.usuarioConclusaoNome,
    this.dataConclusao,
    this.dataPrazo,
  });

  factory ProcessoAndamentoItem.fromMap(
    Map<String, dynamic> map, {
    List<ProcessoAndamentoAtributo>? atributos,
  }) {
    final atributosMapeados = atributos ?? _atributosDoMapa(map);

    return ProcessoAndamentoItem(
      idAtividade: SeiCoreUtils.inteiro(
        map[idAtividadeCol],
        nomeCampo: idAtividadeCol,
      ),
      idProcesso: SeiCoreUtils.identificadorParaString(
        map[idProcessoCol],
        nomeCampo: idProcessoCol,
      ),
      idTarefa: map[idTarefaCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idTarefaCol],
              nomeCampo: idTarefaCol,
            ),
      tarefaNome: map[tarefaNomeCol] as String?,
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      unidadeSigla: map[unidadeSiglaCol] as String,
      unidadeDescricao: map[unidadeDescricaoCol] as String,
      idUnidadeOrigem: SeiCoreUtils.inteiro(
        map[idUnidadeOrigemCol],
        nomeCampo: idUnidadeOrigemCol,
      ),
      unidadeOrigemSigla: map[unidadeOrigemSiglaCol] as String,
      unidadeOrigemDescricao: map[unidadeOrigemDescricaoCol] as String,
      idUsuario: map[idUsuarioCol] == null
          ? null
          : SeiCoreUtils.inteiro(map[idUsuarioCol], nomeCampo: idUsuarioCol),
      usuarioNome: map[usuarioNomeCol] as String?,
      idUsuarioOrigem: SeiCoreUtils.inteiro(
        map[idUsuarioOrigemCol],
        nomeCampo: idUsuarioOrigemCol,
      ),
      usuarioOrigemNome: map[usuarioOrigemNomeCol] as String,
      idUsuarioConclusao: map[idUsuarioConclusaoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idUsuarioConclusaoCol],
              nomeCampo: idUsuarioConclusaoCol,
            ),
      usuarioConclusaoNome: map[usuarioConclusaoNomeCol] as String?,
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
      dataPrazo: map[dataPrazoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataPrazoCol],
              nomeCampo: dataPrazoCol,
            ),
      atividadeInicial: SeiCoreUtils.simNaoParaBool(
        map[atividadeInicialCol] as String,
        nomeCampo: atividadeInicialCol,
      ),
      tipoVisualizacao: SeiCoreUtils.inteiro(
        map[tipoVisualizacaoCol],
        nomeCampo: tipoVisualizacaoCol,
      ),
      atributos: atributosMapeados,
    );
  }

  static List<ProcessoAndamentoAtributo> _atributosDoMapa(
    Map<String, dynamic> map,
  ) {
    final Object? atributosBrutos = map[atributosCol];
    if (atributosBrutos is! List<Object?>) {
      throw FormatException('O campo $atributosCol deve conter uma lista.');
    }

    final atributos = <ProcessoAndamentoAtributo>[];
    for (final Object? atributoBruto in atributosBrutos) {
      if (atributoBruto is! Map<String, dynamic>) {
        throw FormatException(
          'Cada item de $atributosCol deve conter um atributo válido.',
        );
      }
      atributos.add(ProcessoAndamentoAtributo.fromMap(atributoBruto));
    }
    return atributos;
  }

  final int idAtividade;
  final String idProcesso;
  final int? idTarefa;
  final String? tarefaNome;
  final int idUnidade;
  final String unidadeSigla;
  final String unidadeDescricao;
  final int idUnidadeOrigem;
  final String unidadeOrigemSigla;
  final String unidadeOrigemDescricao;
  final int? idUsuario;
  final String? usuarioNome;
  final int idUsuarioOrigem;
  final String usuarioOrigemNome;
  final int? idUsuarioConclusao;
  final String? usuarioConclusaoNome;
  final DateTime dataAbertura;
  final DateTime? dataConclusao;
  final DateTime? dataPrazo;
  final bool atividadeInicial;
  final int tipoVisualizacao;
  final List<ProcessoAndamentoAtributo> atributos;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idAtividadeCol: idAtividade,
      idProcessoCol: idProcesso,
      idTarefaCol: idTarefa,
      tarefaNomeCol: tarefaNome,
      idUnidadeCol: idUnidade,
      unidadeSiglaCol: unidadeSigla,
      unidadeDescricaoCol: unidadeDescricao,
      idUnidadeOrigemCol: idUnidadeOrigem,
      unidadeOrigemSiglaCol: unidadeOrigemSigla,
      unidadeOrigemDescricaoCol: unidadeOrigemDescricao,
      idUsuarioCol: idUsuario,
      usuarioNomeCol: usuarioNome,
      idUsuarioOrigemCol: idUsuarioOrigem,
      usuarioOrigemNomeCol: usuarioOrigemNome,
      idUsuarioConclusaoCol: idUsuarioConclusao,
      usuarioConclusaoNomeCol: usuarioConclusaoNome,
      dataAberturaCol: dataAbertura.toIso8601String(),
      dataConclusaoCol: dataConclusao?.toIso8601String(),
      dataPrazoCol: dataPrazo?.toIso8601String(),
      atividadeInicialCol: SeiCoreUtils.boolParaSimNao(atividadeInicial),
      tipoVisualizacaoCol: tipoVisualizacao,
      atributosCol: atributos
          .map((ProcessoAndamentoAtributo atributo) => atributo.toMap())
          .toList(growable: false),
    };
  }
}
