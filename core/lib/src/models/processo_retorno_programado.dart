import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Prazo de devolução do processo, com as unidades e o autor resolvidos.
///
/// Projeção somente leitura de `retorno_programado`; a escrita usa a entidade
/// [RetornoProgramado]. O manual do usuário é explícito: este recurso só
/// determina prazos, não retira o acesso da unidade demandada e não devolve o
/// processo automaticamente ao vencer.
class ProcessoRetornoProgramado extends BaseModel {
  static const String schemaName = 'public';

  static const String retornoFqtn = '$schemaName.retorno_programado';
  static const String unidadeEnvioFqtn = '$schemaName.unidade';
  static const String usuarioFqtn = '$schemaName.usuario';

  static const String unidadeRetornoAlias = 'unidade_retorno_programado';
  static const String unidadeRetornoAliasTable =
      '$unidadeEnvioFqtn as $unidadeRetornoAlias';

  static const String retornoIdSourceCol = 'id_retorno_programado';
  static const String retornoIdFqCol = '$retornoFqtn.$retornoIdSourceCol';
  static const String retornoIdProtocoloSourceCol = 'id_protocolo';
  static const String retornoIdProtocoloFqCol =
      '$retornoFqtn.$retornoIdProtocoloSourceCol';
  static const String retornoIdAtividadeRetornoSourceCol =
      'id_atividade_retorno';
  static const String retornoIdAtividadeRetornoFqCol =
      '$retornoFqtn.$retornoIdAtividadeRetornoSourceCol';
  static const String retornoDataProgramadaSourceCol = 'dta_programada';
  static const String retornoDataProgramadaFqCol =
      '$retornoFqtn.$retornoDataProgramadaSourceCol';
  static const String retornoDataAlteracaoSourceCol = 'dth_alteracao';
  static const String retornoDataAlteracaoFqCol =
      '$retornoFqtn.$retornoDataAlteracaoSourceCol';
  static const String retornoIdUnidadeEnvioSourceCol = 'id_unidade_envio';
  static const String retornoIdUnidadeEnvioFqCol =
      '$retornoFqtn.$retornoIdUnidadeEnvioSourceCol';
  static const String retornoIdUnidadeRetornoSourceCol = 'id_unidade_retorno';
  static const String retornoIdUnidadeRetornoFqCol =
      '$retornoFqtn.$retornoIdUnidadeRetornoSourceCol';
  static const String retornoIdUsuarioSourceCol = 'id_usuario';
  static const String retornoIdUsuarioFqCol =
      '$retornoFqtn.$retornoIdUsuarioSourceCol';

  static const String unidadeEnvioIdSourceCol = 'id_unidade';
  static const String unidadeEnvioIdFqCol =
      '$unidadeEnvioFqtn.$unidadeEnvioIdSourceCol';
  static const String unidadeEnvioSiglaSourceCol = 'sigla';
  static const String unidadeEnvioSiglaFqCol =
      '$unidadeEnvioFqtn.$unidadeEnvioSiglaSourceCol';

  static const String unidadeRetornoIdSourceCol = 'id_unidade';
  static const String unidadeRetornoIdFqCol =
      '$unidadeRetornoAlias.$unidadeRetornoIdSourceCol';
  static const String unidadeRetornoSiglaSourceCol = 'sigla';
  static const String unidadeRetornoSiglaFqCol =
      '$unidadeRetornoAlias.$unidadeRetornoSiglaSourceCol';

  static const String usuarioIdSourceCol = 'id_usuario';
  static const String usuarioIdFqCol = '$usuarioFqtn.$usuarioIdSourceCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioNomeFqCol = '$usuarioFqtn.$usuarioNomeSourceCol';

  static const String idRetornoProgramadoCol = 'id_retorno_programado';
  static const String dataProgramadaCol = 'data_programada';
  static const String dataAlteracaoCol = 'data_alteracao';
  static const String cumpridoCol = 'cumprido';
  static const String idUnidadeEnvioCol = 'id_unidade_envio';
  static const String unidadeEnvioSiglaCol = 'unidade_envio_sigla';
  static const String idUnidadeRetornoCol = 'id_unidade_retorno';
  static const String unidadeRetornoSiglaCol = 'unidade_retorno_sigla';
  static const String idUsuarioCol = 'id_usuario';
  static const String usuarioNomeCol = 'usuario_nome';

  ProcessoRetornoProgramado({
    required this.idRetornoProgramado,
    required this.dataProgramada,
    required this.cumprido,
    required this.idUnidadeEnvio,
    required this.unidadeEnvioSigla,
    required this.idUnidadeRetorno,
    required this.unidadeRetornoSigla,
    required this.idUsuario,
    required this.usuarioNome,
    this.dataAlteracao,
  });

  factory ProcessoRetornoProgramado.fromMap(Map<String, dynamic> map) {
    return ProcessoRetornoProgramado(
      idRetornoProgramado: SeiCoreUtils.inteiro(
        map[idRetornoProgramadoCol],
        nomeCampo: idRetornoProgramadoCol,
      ),
      dataProgramada: SeiCoreUtils.dataHoraLocal(
        map[dataProgramadaCol],
        nomeCampo: dataProgramadaCol,
      ),
      dataAlteracao: map[dataAlteracaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataAlteracaoCol],
              nomeCampo: dataAlteracaoCol,
            ),
      cumprido: SeiCoreUtils.simNaoParaBool(
        map[cumpridoCol] as String,
        nomeCampo: cumpridoCol,
      ),
      idUnidadeEnvio: SeiCoreUtils.inteiro(
        map[idUnidadeEnvioCol],
        nomeCampo: idUnidadeEnvioCol,
      ),
      unidadeEnvioSigla: map[unidadeEnvioSiglaCol] as String,
      idUnidadeRetorno: SeiCoreUtils.inteiro(
        map[idUnidadeRetornoCol],
        nomeCampo: idUnidadeRetornoCol,
      ),
      unidadeRetornoSigla: map[unidadeRetornoSiglaCol] as String,
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      usuarioNome: map[usuarioNomeCol] as String,
    );
  }

  final int idRetornoProgramado;
  final DateTime dataProgramada;
  final DateTime? dataAlteracao;

  /// Indica que o processo já retornou à unidade demandante.
  final bool cumprido;

  /// Unidade que demandou o retorno.
  final int idUnidadeEnvio;
  final String unidadeEnvioSigla;

  /// Unidade que recebeu o processo e deve devolvê-lo.
  final int idUnidadeRetorno;
  final String unidadeRetornoSigla;

  final int idUsuario;
  final String usuarioNome;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idRetornoProgramadoCol: idRetornoProgramado,
      dataProgramadaCol: dataProgramada.toIso8601String(),
      dataAlteracaoCol: dataAlteracao?.toIso8601String(),
      cumpridoCol: SeiCoreUtils.boolParaSimNao(cumprido),
      idUnidadeEnvioCol: idUnidadeEnvio,
      unidadeEnvioSiglaCol: unidadeEnvioSigla,
      idUnidadeRetornoCol: idUnidadeRetorno,
      unidadeRetornoSiglaCol: unidadeRetornoSigla,
      idUsuarioCol: idUsuario,
      usuarioNomeCol: usuarioNome,
    };
  }
}
