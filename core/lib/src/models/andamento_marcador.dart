import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/operacao_marcador.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Linha de histórico da atribuição de marcador a um processo.
///
/// Gravável em `andamento_marcador`, esta tabela nunca é atualizada in-place:
/// cada inclusão, alteração de texto ou remoção grava uma linha nova. O
/// cruzamento comprovado no dump histórico mostra o mecanismo completo:
///
/// - a linha corrente do par processo e marcador tem `sin_ultimo = 'S'` e
///   sempre `sin_ativo = 'S'`, com operação [OperacaoMarcador.inclusao] ou
///   [OperacaoMarcador.alteracao];
/// - uma remoção grava uma linha com `sin_ultimo = 'N'` e `sin_ativo = 'N'` e
///   encerra o vínculo, sem deixar linha corrente para aquele par.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap].
class AndamentoMarcador extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'andamento_marcador';
  static const String fqtn = '$schemaName.$tableName';

  static const String idAndamentoMarcadorCol = 'id_andamento_marcador';
  static const String idAndamentoMarcadorFqCol =
      '$fqtn.$idAndamentoMarcadorCol';
  static const String idMarcadorCol = 'id_marcador';
  static const String idMarcadorFqCol = '$fqtn.$idMarcadorCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String idProcedimentoCol = 'id_procedimento';
  static const String idProcedimentoFqCol = '$fqtn.$idProcedimentoCol';
  static const String dataExecucaoCol = 'dth_execucao';
  static const String dataExecucaoFqCol = '$fqtn.$dataExecucaoCol';
  static const String ultimoCol = 'sin_ultimo';
  static const String ultimoFqCol = '$fqtn.$ultimoCol';
  static const String textoCol = 'texto';
  static const String textoFqCol = '$fqtn.$textoCol';
  static const String operacaoCol = 'sta_operacao';
  static const String operacaoFqCol = '$fqtn.$operacaoCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';

  AndamentoMarcador({
    required this.idAndamentoMarcador,
    required this.idUnidade,
    required this.idUsuario,
    required this.idProcedimento,
    required this.dataExecucao,
    required this.operacao,
    this.idMarcador,
    this.ultimo = true,
    this.texto,
    this.ativo = true,
  });

  factory AndamentoMarcador.fromMap(Map<String, dynamic> map) {
    return AndamentoMarcador(
      idAndamentoMarcador: SeiCoreUtils.inteiro(
        map[idAndamentoMarcadorCol],
        nomeCampo: idAndamentoMarcadorCol,
      ),
      idMarcador: map[idMarcadorCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idMarcadorCol],
              nomeCampo: idMarcadorCol,
            ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      idProcedimento: SeiCoreUtils.inteiro(
        map[idProcedimentoCol],
        nomeCampo: idProcedimentoCol,
      ),
      dataExecucao: SeiCoreUtils.dataHoraLocal(
        map[dataExecucaoCol],
        nomeCampo: dataExecucaoCol,
      ),
      ultimo: SeiCoreUtils.simNaoParaBool(
        (map[ultimoCol] as String).trim(),
        nomeCampo: ultimoCol,
      ),
      texto: map[textoCol] as String?,
      operacao: OperacaoMarcador.fromValue(map[operacaoCol] as String),
      ativo: SeiCoreUtils.simNaoParaBool(
        (map[ativoCol] as String).trim(),
        nomeCampo: ativoCol,
      ),
    );
  }

  /// Identificador da linha de histórico, atribuído pela aplicação.
  final int idAndamentoMarcador;

  /// Marcador atribuído; nulo apenas quando a coluna permite, sem caso
  /// observado nos dados reais.
  final int? idMarcador;

  final int idUnidade;
  final int idUsuario;
  final int idProcedimento;
  final DateTime dataExecucao;

  /// Indica que esta é a linha corrente do par processo e marcador.
  final bool ultimo;

  /// Texto complementar informado ao atribuir o marcador.
  final String? texto;

  final OperacaoMarcador operacao;

  /// Indica que o marcador está ativo no processo nesta linha.
  ///
  /// A linha corrente de um marcador em uso tem sempre `ultimo == true` e
  /// `ativo == true` ao mesmo tempo; nenhuma combinação com `ultimo == true`
  /// e `ativo == false` foi observada.
  final bool ativo;

  /// Indica que esta linha representa um marcador em uso no processo.
  bool get vigente => ultimo && ativo;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idAndamentoMarcadorCol: idAndamentoMarcador,
      idMarcadorCol: idMarcador,
      idUnidadeCol: idUnidade,
      idUsuarioCol: idUsuario,
      idProcedimentoCol: idProcedimento,
      dataExecucaoCol: dataExecucao,
      ultimoCol: SeiCoreUtils.boolParaSimNao(ultimo),
      textoCol: texto,
      operacaoCol: operacao.valor,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  ///
  /// Uma linha de histórico não é editada; este método existe para cumprir o
  /// contrato de [BaseModel] e serve apenas ao caso de correção excepcional.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idAndamentoMarcadorCol);
    return mapa;
  }
}
