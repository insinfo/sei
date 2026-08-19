import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Unidade em que o processo está aberto, com a síntese das suas atividades.
///
/// No SEI o estado aberto ou concluído não pertence ao processo: ele pertence
/// ao par processo e unidade, materializado em `atividade` com
/// `dth_conclusao` nula. Concluir em uma unidade não conclui nas demais, e é
/// por isso que a tela do processo lista as unidades em que ele está aberto.
///
/// Uma unidade pode ter mais de uma atividade aberta ao mesmo tempo, porque
/// nem toda tarefa fecha os andamentos anteriores. Este DTO agrega essas
/// atividades em uma linha por unidade e preserva a contagem original.
class ProcessoUnidadeAberta extends BaseModel {
  static const String schemaName = 'public';

  static const String atividadeFqtn = '$schemaName.atividade';
  static const String unidadeFqtn = '$schemaName.unidade';
  static const String usuarioFqtn = '$schemaName.usuario';

  static const String atividadeIdSourceCol = 'id_atividade';
  static const String atividadeIdFqCol = '$atividadeFqtn.$atividadeIdSourceCol';
  static const String atividadeIdProtocoloSourceCol = 'id_protocolo';
  static const String atividadeIdProtocoloFqCol =
      '$atividadeFqtn.$atividadeIdProtocoloSourceCol';
  static const String atividadeIdUnidadeSourceCol = 'id_unidade';
  static const String atividadeIdUnidadeFqCol =
      '$atividadeFqtn.$atividadeIdUnidadeSourceCol';
  static const String atividadeIdUsuarioAtribuicaoSourceCol =
      'id_usuario_atribuicao';
  static const String atividadeIdUsuarioAtribuicaoFqCol =
      '$atividadeFqtn.$atividadeIdUsuarioAtribuicaoSourceCol';
  static const String atividadeAberturaSourceCol = 'dth_abertura';
  static const String atividadeAberturaFqCol =
      '$atividadeFqtn.$atividadeAberturaSourceCol';
  static const String atividadeConclusaoSourceCol = 'dth_conclusao';
  static const String atividadeConclusaoFqCol =
      '$atividadeFqtn.$atividadeConclusaoSourceCol';
  static const String atividadeInicialSourceCol = 'sin_inicial';
  static const String atividadeInicialFqCol =
      '$atividadeFqtn.$atividadeInicialSourceCol';

  static const String unidadeIdSourceCol = 'id_unidade';
  static const String unidadeIdFqCol = '$unidadeFqtn.$unidadeIdSourceCol';
  static const String unidadeSiglaSourceCol = 'sigla';
  static const String unidadeSiglaFqCol = '$unidadeFqtn.$unidadeSiglaSourceCol';
  static const String unidadeDescricaoSourceCol = 'descricao';
  static const String unidadeDescricaoFqCol =
      '$unidadeFqtn.$unidadeDescricaoSourceCol';

  static const String usuarioIdSourceCol = 'id_usuario';
  static const String usuarioIdFqCol = '$usuarioFqtn.$usuarioIdSourceCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioNomeFqCol = '$usuarioFqtn.$usuarioNomeSourceCol';

  static const String idUnidadeCol = 'id_unidade';
  static const String unidadeSiglaCol = 'unidade_sigla';
  static const String unidadeDescricaoCol = 'unidade_descricao';
  static const String dataAberturaCol = 'data_abertura';
  static const String dataUltimaAtividadeCol = 'data_ultima_atividade';
  static const String atividadesAbertasCol = 'atividades_abertas';
  static const String idAtividadeRecenteCol = 'id_atividade_recente';
  static const String geradoNaUnidadeCol = 'gerado_na_unidade';
  static const String idUsuarioAtribuicaoCol = 'id_usuario_atribuicao';
  static const String usuarioAtribuicaoNomeCol = 'usuario_atribuicao_nome';

  ProcessoUnidadeAberta({
    required this.idUnidade,
    required this.unidadeSigla,
    required this.unidadeDescricao,
    required this.dataAbertura,
    required this.dataUltimaAtividade,
    required this.atividadesAbertas,
    required this.idAtividadeRecente,
    required this.geradoNaUnidade,
    this.idUsuarioAtribuicao,
    this.usuarioAtribuicaoNome,
  });

  /// Reconstrói a linha agregada, com a atribuição resolvida à parte.
  ///
  /// A atribuição vive na atividade, não na unidade; o repositório a consulta
  /// para a atividade mais recente e a informa aqui. Quando o DTO é lido de
  /// volta a partir da resposta da API, os mesmos campos chegam no mapa.
  factory ProcessoUnidadeAberta.fromMap(
    Map<String, dynamic> map, {
    int? idUsuarioAtribuicao,
    String? usuarioAtribuicaoNome,
  }) {
    final Object? idAtribuicaoBruto =
        idUsuarioAtribuicao ?? map[idUsuarioAtribuicaoCol];

    return ProcessoUnidadeAberta(
      idUnidade:
          SeiCoreUtils.inteiro(map[idUnidadeCol], nomeCampo: idUnidadeCol),
      unidadeSigla: map[unidadeSiglaCol] as String,
      unidadeDescricao: map[unidadeDescricaoCol] as String,
      dataAbertura: SeiCoreUtils.dataHoraLocal(
        map[dataAberturaCol],
        nomeCampo: dataAberturaCol,
      ),
      dataUltimaAtividade: SeiCoreUtils.dataHoraLocal(
        map[dataUltimaAtividadeCol],
        nomeCampo: dataUltimaAtividadeCol,
      ),
      atividadesAbertas: SeiCoreUtils.inteiro(
        map[atividadesAbertasCol],
        nomeCampo: atividadesAbertasCol,
      ),
      idAtividadeRecente: SeiCoreUtils.inteiro(
        map[idAtividadeRecenteCol],
        nomeCampo: idAtividadeRecenteCol,
      ),
      geradoNaUnidade: SeiCoreUtils.simNaoParaBool(
        (map[geradoNaUnidadeCol] as String).trim(),
        nomeCampo: geradoNaUnidadeCol,
      ),
      idUsuarioAtribuicao: idAtribuicaoBruto == null
          ? null
          : SeiCoreUtils.inteiro(
              idAtribuicaoBruto,
              nomeCampo: idUsuarioAtribuicaoCol,
            ),
      usuarioAtribuicaoNome:
          usuarioAtribuicaoNome ?? map[usuarioAtribuicaoNomeCol] as String?,
    );
  }

  final int idUnidade;
  final String unidadeSigla;
  final String unidadeDescricao;

  /// Momento da atividade aberta mais antiga; é desde quando a unidade
  /// responde pelo processo para efeito de contagem de tempo.
  final DateTime dataAbertura;

  /// Momento da atividade aberta mais recente na unidade.
  final DateTime dataUltimaAtividade;

  /// Quantidade de atividades abertas na unidade.
  final int atividadesAbertas;

  /// Atividade aberta mais recente, usada para resolver a atribuição.
  final int idAtividadeRecente;

  /// Indica que ao menos uma das atividades abertas é inicial, ou seja, que a
  /// unidade aparece na coluna Gerados do Controle de Processos.
  final bool geradoNaUnidade;

  final int? idUsuarioAtribuicao;
  final String? usuarioAtribuicaoNome;

  /// Indica que o processo está atribuído a um usuário nesta unidade.
  bool get possuiAtribuicao => idUsuarioAtribuicao != null;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idUnidadeCol: idUnidade,
      unidadeSiglaCol: unidadeSigla,
      unidadeDescricaoCol: unidadeDescricao,
      dataAberturaCol: dataAbertura.toIso8601String(),
      dataUltimaAtividadeCol: dataUltimaAtividade.toIso8601String(),
      atividadesAbertasCol: atividadesAbertas,
      idAtividadeRecenteCol: idAtividadeRecente,
      geradoNaUnidadeCol: SeiCoreUtils.boolParaSimNao(geradoNaUnidade),
      idUsuarioAtribuicaoCol: idUsuarioAtribuicao,
      usuarioAtribuicaoNomeCol: usuarioAtribuicaoNome,
    };
  }
}
