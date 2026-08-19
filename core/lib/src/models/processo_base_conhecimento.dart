import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Base de Conhecimento associada ao **tipo** deste processo, com a unidade
/// e o usuário gerador resolvidos.
///
/// No SEI, a Base de Conhecimento não é vinculada a um processo específico,
/// e sim ao seu tipo (`rel_base_conhec_tipo_proced`); é assim que o sistema
/// decide quando mostrar o ícone "B" ao lado do processo. Esta projeção
/// parte de `procedimento` para descobrir `id_tipo_procedimento` do
/// processo consultado, junta `rel_base_conhec_tipo_proced` e
/// `base_conhecimento`, e resolve `unidade` e `usuario`.
///
/// [estado] e [documento] são o código bruto de `sta_estado` e
/// `sta_documento`: `base_conhecimento` não tem nenhuma linha real nas fontes
/// locais para comprovar esse domínio — lacuna registrada em
/// `backend/docs/evidencias_processo_detalhe.md`. O corpo (`conteudo`) fica
/// fora desta listagem por ser potencialmente grande, no mesmo padrão do
/// conteúdo de documento.
class ProcessoBaseConhecimento extends BaseModel {
  static const String schemaName = 'public';

  static const String procedimentoFqtn = '$schemaName.procedimento';
  static const String relacaoFqtn = '$schemaName.rel_base_conhec_tipo_proced';
  static const String baseConhecimentoFqtn = '$schemaName.base_conhecimento';
  static const String unidadeFqtn = '$schemaName.unidade';
  static const String usuarioFqtn = '$schemaName.usuario';

  static const String procedimentoIdSourceCol = 'id_procedimento';
  static const String procedimentoIdFqCol =
      '$procedimentoFqtn.$procedimentoIdSourceCol';
  static const String procedimentoIdTipoSourceCol = 'id_tipo_procedimento';
  static const String procedimentoIdTipoFqCol =
      '$procedimentoFqtn.$procedimentoIdTipoSourceCol';

  static const String relacaoIdTipoProcedimentoSourceCol =
      'id_tipo_procedimento';
  static const String relacaoIdTipoProcedimentoFqCol =
      '$relacaoFqtn.$relacaoIdTipoProcedimentoSourceCol';
  static const String relacaoIdBaseConhecimentoSourceCol =
      'id_base_conhecimento';
  static const String relacaoIdBaseConhecimentoFqCol =
      '$relacaoFqtn.$relacaoIdBaseConhecimentoSourceCol';

  static const String baseConhecimentoIdSourceCol = 'id_base_conhecimento';
  static const String baseConhecimentoIdFqCol =
      '$baseConhecimentoFqtn.$baseConhecimentoIdSourceCol';
  static const String baseConhecimentoDescricaoSourceCol = 'descricao';
  static const String baseConhecimentoDescricaoFqCol =
      '$baseConhecimentoFqtn.$baseConhecimentoDescricaoSourceCol';
  static const String baseConhecimentoEstadoSourceCol = 'sta_estado';
  static const String baseConhecimentoEstadoFqCol =
      '$baseConhecimentoFqtn.$baseConhecimentoEstadoSourceCol';
  static const String baseConhecimentoDocumentoSourceCol = 'sta_documento';
  static const String baseConhecimentoDocumentoFqCol =
      '$baseConhecimentoFqtn.$baseConhecimentoDocumentoSourceCol';
  static const String baseConhecimentoDataGeracaoSourceCol = 'dth_geracao';
  static const String baseConhecimentoDataGeracaoFqCol =
      '$baseConhecimentoFqtn.$baseConhecimentoDataGeracaoSourceCol';
  static const String baseConhecimentoDataLiberacaoSourceCol = 'dth_liberacao';
  static const String baseConhecimentoDataLiberacaoFqCol =
      '$baseConhecimentoFqtn.$baseConhecimentoDataLiberacaoSourceCol';
  static const String baseConhecimentoIdUnidadeSourceCol = 'id_unidade';
  static const String baseConhecimentoIdUnidadeFqCol =
      '$baseConhecimentoFqtn.$baseConhecimentoIdUnidadeSourceCol';
  static const String baseConhecimentoIdUsuarioGeradorSourceCol =
      'id_usuario_gerador';
  static const String baseConhecimentoIdUsuarioGeradorFqCol =
      '$baseConhecimentoFqtn.$baseConhecimentoIdUsuarioGeradorSourceCol';

  static const String unidadeIdSourceCol = 'id_unidade';
  static const String unidadeIdFqCol = '$unidadeFqtn.$unidadeIdSourceCol';
  static const String unidadeSiglaSourceCol = 'sigla';
  static const String unidadeSiglaFqCol = '$unidadeFqtn.$unidadeSiglaSourceCol';

  static const String usuarioIdSourceCol = 'id_usuario';
  static const String usuarioIdFqCol = '$usuarioFqtn.$usuarioIdSourceCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioNomeFqCol = '$usuarioFqtn.$usuarioNomeSourceCol';

  static const String idBaseConhecimentoCol = 'id_base_conhecimento';
  static const String descricaoCol = 'descricao';
  static const String estadoCol = 'estado';
  static const String documentoCol = 'documento';
  static const String dataGeracaoCol = 'data_geracao';
  static const String dataLiberacaoCol = 'data_liberacao';
  static const String idUnidadeCol = 'id_unidade';
  static const String unidadeSiglaCol = 'unidade_sigla';
  static const String idUsuarioGeradorCol = 'id_usuario_gerador';
  static const String usuarioGeradorNomeCol = 'usuario_gerador_nome';

  ProcessoBaseConhecimento({
    required this.idBaseConhecimento,
    required this.descricao,
    required this.estado,
    required this.documento,
    required this.dataGeracao,
    required this.idUnidade,
    required this.unidadeSigla,
    required this.idUsuarioGerador,
    required this.usuarioGeradorNome,
    this.dataLiberacao,
  });

  factory ProcessoBaseConhecimento.fromMap(Map<String, dynamic> map) {
    return ProcessoBaseConhecimento(
      idBaseConhecimento: SeiCoreUtils.inteiro(
        map[idBaseConhecimentoCol],
        nomeCampo: idBaseConhecimentoCol,
      ),
      descricao: map[descricaoCol] as String,
      estado: (map[estadoCol] as String).trim(),
      documento: (map[documentoCol] as String).trim(),
      dataGeracao: SeiCoreUtils.dataHoraLocal(
        map[dataGeracaoCol],
        nomeCampo: dataGeracaoCol,
      ),
      dataLiberacao: map[dataLiberacaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataLiberacaoCol],
              nomeCampo: dataLiberacaoCol,
            ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      unidadeSigla: map[unidadeSiglaCol] as String,
      idUsuarioGerador: SeiCoreUtils.inteiro(
        map[idUsuarioGeradorCol],
        nomeCampo: idUsuarioGeradorCol,
      ),
      usuarioGeradorNome: map[usuarioGeradorNomeCol] as String,
    );
  }

  final int idBaseConhecimento;
  final String descricao;

  /// Código bruto de `sta_estado`; ver a lacuna no Dartdoc da classe.
  final String estado;

  /// Código bruto de `sta_documento`; ver a lacuna no Dartdoc da classe.
  final String documento;

  final DateTime dataGeracao;
  final DateTime? dataLiberacao;

  /// Unidade geradora da base de conhecimento.
  final int idUnidade;
  final String unidadeSigla;

  final int idUsuarioGerador;
  final String usuarioGeradorNome;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idBaseConhecimentoCol: idBaseConhecimento,
      descricaoCol: descricao,
      estadoCol: estado,
      documentoCol: documento,
      dataGeracaoCol: dataGeracao.toIso8601String(),
      dataLiberacaoCol: dataLiberacao?.toIso8601String(),
      idUnidadeCol: idUnidade,
      unidadeSiglaCol: unidadeSigla,
      idUsuarioGeradorCol: idUsuarioGerador,
      usuarioGeradorNomeCol: usuarioGeradorNome,
    };
  }
}
