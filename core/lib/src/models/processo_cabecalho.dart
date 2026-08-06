import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Dados de identificação e situação exibidos no cabeçalho do processo.
///
/// Este DTO representa a projeção somente leitura de `protocolo` e
/// `procedimento`; ele não substitui as entidades persistidas do SEI.
class ProcessoCabecalho extends BaseModel {
  static const String schemaName = 'public';

  static const String protocoloFqtn = '$schemaName.protocolo';
  static const String procedimentoFqtn = '$schemaName.procedimento';
  static const String tipoProcedimentoFqtn = '$schemaName.tipo_procedimento';
  static const String unidadeFqtn = '$schemaName.unidade';
  static const String usuarioFqtn = '$schemaName.usuario';

  static const String protocoloIdSourceCol = 'id_protocolo';
  static const String protocoloIdFqCol = '$protocoloFqtn.$protocoloIdSourceCol';
  static const String protocoloFormatadoSourceCol = 'protocolo_formatado';
  static const String protocoloFormatadoFqCol =
      '$protocoloFqtn.$protocoloFormatadoSourceCol';
  static const String protocoloDescricaoSourceCol = 'descricao';
  static const String protocoloDescricaoFqCol =
      '$protocoloFqtn.$protocoloDescricaoSourceCol';
  static const String protocoloEstadoSourceCol = 'sta_estado';
  static const String protocoloEstadoFqCol =
      '$protocoloFqtn.$protocoloEstadoSourceCol';
  static const String protocoloGeracaoSourceCol = 'dta_geracao';
  static const String protocoloGeracaoFqCol =
      '$protocoloFqtn.$protocoloGeracaoSourceCol';
  static const String protocoloNivelAcessoLocalSourceCol =
      'sta_nivel_acesso_local';
  static const String protocoloNivelAcessoLocalFqCol =
      '$protocoloFqtn.$protocoloNivelAcessoLocalSourceCol';
  static const String protocoloNivelAcessoGlobalSourceCol =
      'sta_nivel_acesso_global';
  static const String protocoloNivelAcessoGlobalFqCol =
      '$protocoloFqtn.$protocoloNivelAcessoGlobalSourceCol';
  static const String protocoloEliminadoSourceCol = 'sin_eliminado';
  static const String protocoloEliminadoFqCol =
      '$protocoloFqtn.$protocoloEliminadoSourceCol';
  static const String protocoloIdUnidadeGeradoraSourceCol =
      'id_unidade_geradora';
  static const String protocoloIdUnidadeGeradoraFqCol =
      '$protocoloFqtn.$protocoloIdUnidadeGeradoraSourceCol';
  static const String protocoloIdUsuarioGeradorSourceCol = 'id_usuario_gerador';
  static const String protocoloIdUsuarioGeradorFqCol =
      '$protocoloFqtn.$protocoloIdUsuarioGeradorSourceCol';

  static const String procedimentoIdSourceCol = 'id_procedimento';
  static const String procedimentoIdFqCol =
      '$procedimentoFqtn.$procedimentoIdSourceCol';
  static const String procedimentoIdTipoSourceCol = 'id_tipo_procedimento';
  static const String procedimentoIdTipoFqCol =
      '$procedimentoFqtn.$procedimentoIdTipoSourceCol';
  static const String procedimentoConclusaoSourceCol = 'dta_conclusao';
  static const String procedimentoConclusaoFqCol =
      '$procedimentoFqtn.$procedimentoConclusaoSourceCol';

  static const String tipoProcedimentoIdSourceCol = 'id_tipo_procedimento';
  static const String tipoProcedimentoIdFqCol =
      '$tipoProcedimentoFqtn.$tipoProcedimentoIdSourceCol';
  static const String tipoProcedimentoNomeSourceCol = 'nome';
  static const String tipoProcedimentoNomeFqCol =
      '$tipoProcedimentoFqtn.$tipoProcedimentoNomeSourceCol';

  static const String unidadeIdSourceCol = 'id_unidade';
  static const String unidadeIdFqCol = '$unidadeFqtn.$unidadeIdSourceCol';
  static const String unidadeSiglaSourceCol = 'sigla';
  static const String unidadeSiglaFqCol = '$unidadeFqtn.$unidadeSiglaSourceCol';
  static const String unidadeDescricaoSourceCol = 'descricao';
  static const String unidadeDescricaoFqCol =
      '$unidadeFqtn.$unidadeDescricaoSourceCol';

  static const String usuarioIdSourceCol = 'id_usuario';
  static const String usuarioIdFqCol = '$usuarioFqtn.$usuarioIdSourceCol';
  static const String usuarioSiglaSourceCol = 'sigla';
  static const String usuarioSiglaFqCol = '$usuarioFqtn.$usuarioSiglaSourceCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioNomeFqCol = '$usuarioFqtn.$usuarioNomeSourceCol';

  static const String idProcessoCol = 'id_processo';
  static const String protocoloFormatadoCol = 'protocolo_formatado';
  static const String descricaoCol = 'descricao';
  static const String estadoProtocoloCol = 'estado_protocolo';
  static const String dataGeracaoCol = 'data_geracao';
  static const String nivelAcessoLocalCol = 'nivel_acesso_local';
  static const String nivelAcessoGlobalCol = 'nivel_acesso_global';
  static const String eliminadoCol = 'eliminado';
  static const String dataConclusaoCol = 'data_conclusao';
  static const String idTipoProcedimentoCol = 'id_tipo_procedimento';
  static const String tipoProcedimentoNomeCol = 'tipo_procedimento_nome';
  static const String idUnidadeGeradoraCol = 'id_unidade_geradora';
  static const String unidadeGeradoraSiglaCol = 'unidade_geradora_sigla';
  static const String unidadeGeradoraDescricaoCol =
      'unidade_geradora_descricao';
  static const String idUsuarioGeradorCol = 'id_usuario_gerador';
  static const String usuarioGeradorSiglaCol = 'usuario_gerador_sigla';
  static const String usuarioGeradorNomeCol = 'usuario_gerador_nome';

  ProcessoCabecalho({
    required this.idProcesso,
    required this.protocoloFormatado,
    required this.estadoProtocolo,
    required this.dataGeracao,
    required this.nivelAcessoLocal,
    required this.nivelAcessoGlobal,
    required this.eliminado,
    required this.idTipoProcedimento,
    required this.tipoProcedimentoNome,
    required this.idUnidadeGeradora,
    required this.unidadeGeradoraSigla,
    required this.unidadeGeradoraDescricao,
    required this.idUsuarioGerador,
    required this.usuarioGeradorSigla,
    required this.usuarioGeradorNome,
    this.descricao,
    this.dataConclusao,
  });

  factory ProcessoCabecalho.fromMap(Map<String, dynamic> map) {
    return ProcessoCabecalho(
      idProcesso: SeiCoreUtils.identificadorParaString(
        map[idProcessoCol],
        nomeCampo: idProcessoCol,
      ),
      protocoloFormatado: map[protocoloFormatadoCol] as String,
      descricao: map[descricaoCol] as String?,
      estadoProtocolo: map[estadoProtocoloCol] as String,
      dataGeracao: SeiCoreUtils.dataHoraLocal(
        map[dataGeracaoCol],
        nomeCampo: dataGeracaoCol,
      ),
      nivelAcessoLocal: map[nivelAcessoLocalCol] as String,
      nivelAcessoGlobal: map[nivelAcessoGlobalCol] as String,
      eliminado: SeiCoreUtils.simNaoParaBool(
        map[eliminadoCol] as String,
        nomeCampo: eliminadoCol,
      ),
      dataConclusao: map[dataConclusaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataConclusaoCol],
              nomeCampo: dataConclusaoCol,
            ),
      idTipoProcedimento: SeiCoreUtils.inteiro(
        map[idTipoProcedimentoCol],
        nomeCampo: idTipoProcedimentoCol,
      ),
      tipoProcedimentoNome: map[tipoProcedimentoNomeCol] as String,
      idUnidadeGeradora: SeiCoreUtils.inteiro(
        map[idUnidadeGeradoraCol],
        nomeCampo: idUnidadeGeradoraCol,
      ),
      unidadeGeradoraSigla: map[unidadeGeradoraSiglaCol] as String,
      unidadeGeradoraDescricao: map[unidadeGeradoraDescricaoCol] as String,
      idUsuarioGerador: SeiCoreUtils.inteiro(
        map[idUsuarioGeradorCol],
        nomeCampo: idUsuarioGeradorCol,
      ),
      usuarioGeradorSigla: map[usuarioGeradorSiglaCol] as String,
      usuarioGeradorNome: map[usuarioGeradorNomeCol] as String,
    );
  }

  final String idProcesso;
  final String protocoloFormatado;
  final String? descricao;
  final String estadoProtocolo;
  final DateTime dataGeracao;
  final String nivelAcessoLocal;
  final String nivelAcessoGlobal;
  final bool eliminado;
  final DateTime? dataConclusao;
  final int idTipoProcedimento;
  final String tipoProcedimentoNome;
  final int idUnidadeGeradora;
  final String unidadeGeradoraSigla;
  final String unidadeGeradoraDescricao;
  final int idUsuarioGerador;
  final String usuarioGeradorSigla;
  final String usuarioGeradorNome;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idProcessoCol: idProcesso,
      protocoloFormatadoCol: protocoloFormatado,
      descricaoCol: descricao,
      estadoProtocoloCol: estadoProtocolo,
      dataGeracaoCol: dataGeracao.toIso8601String(),
      nivelAcessoLocalCol: nivelAcessoLocal,
      nivelAcessoGlobalCol: nivelAcessoGlobal,
      eliminadoCol: SeiCoreUtils.boolParaSimNao(eliminado),
      dataConclusaoCol: dataConclusao?.toIso8601String(),
      idTipoProcedimentoCol: idTipoProcedimento,
      tipoProcedimentoNomeCol: tipoProcedimentoNome,
      idUnidadeGeradoraCol: idUnidadeGeradora,
      unidadeGeradoraSiglaCol: unidadeGeradoraSigla,
      unidadeGeradoraDescricaoCol: unidadeGeradoraDescricao,
      idUsuarioGeradorCol: idUsuarioGerador,
      usuarioGeradorSiglaCol: usuarioGeradorSigla,
      usuarioGeradorNomeCol: usuarioGeradorNome,
    };
  }
}
