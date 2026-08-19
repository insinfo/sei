import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Inclusão de processo em Acompanhamento Especial, gravável em
/// `acompanhamento`.
///
/// Diferente de Bloco Interno, o Acompanhamento Especial não exige que o
/// processo esteja aberto na unidade: ele monitora processos públicos,
/// restritos já tramitados ou sigilosos com credencial, mesmo tramitando em
/// outra unidade, sem abrir andamento nem exigir que ele esteja aberto.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap]. A coluna `idx_acompanhamento` é o índice
/// de busca textual mantido pelo próprio SEI sobre `observacao`; a regra de
/// normalização não está comprovada pelas fontes locais, e por isso esta
/// entidade não a grava.
class Acompanhamento extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'acompanhamento';
  static const String fqtn = '$schemaName.$tableName';

  static const String idAcompanhamentoCol = 'id_acompanhamento';
  static const String idAcompanhamentoFqCol = '$fqtn.$idAcompanhamentoCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idGrupoAcompanhamentoCol = 'id_grupo_acompanhamento';
  static const String idGrupoAcompanhamentoFqCol =
      '$fqtn.$idGrupoAcompanhamentoCol';
  static const String idProtocoloCol = 'id_protocolo';
  static const String idProtocoloFqCol = '$fqtn.$idProtocoloCol';
  static const String observacaoCol = 'observacao';
  static const String observacaoFqCol = '$fqtn.$observacaoCol';
  static const String tipoVisualizacaoCol = 'tipo_visualizacao';
  static const String tipoVisualizacaoFqCol = '$fqtn.$tipoVisualizacaoCol';
  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String dataAlteracaoCol = 'dth_alteracao';
  static const String dataAlteracaoFqCol = '$fqtn.$dataAlteracaoCol';

  /// Valor mais frequente de `tipo_visualizacao` no dump histórico local,
  /// presente em 56 dos 58 acompanhamentos.
  static const int tipoVisualizacaoPadrao = 0;

  Acompanhamento({
    required this.idAcompanhamento,
    required this.idUnidade,
    required this.idProtocolo,
    required this.idUsuario,
    required this.dataAlteracao,
    this.idGrupoAcompanhamento,
    this.observacao,
    this.tipoVisualizacao = tipoVisualizacaoPadrao,
  });

  factory Acompanhamento.fromMap(Map<String, dynamic> map) {
    return Acompanhamento(
      idAcompanhamento: SeiCoreUtils.inteiro(
        map[idAcompanhamentoCol],
        nomeCampo: idAcompanhamentoCol,
      ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      idGrupoAcompanhamento: map[idGrupoAcompanhamentoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idGrupoAcompanhamentoCol],
              nomeCampo: idGrupoAcompanhamentoCol,
            ),
      idProtocolo: SeiCoreUtils.inteiro(
        map[idProtocoloCol],
        nomeCampo: idProtocoloCol,
      ),
      observacao: map[observacaoCol] as String?,
      tipoVisualizacao: SeiCoreUtils.inteiro(
        map[tipoVisualizacaoCol],
        nomeCampo: tipoVisualizacaoCol,
      ),
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      dataAlteracao: SeiCoreUtils.dataHoraLocal(
        map[dataAlteracaoCol],
        nomeCampo: dataAlteracaoCol,
      ),
    );
  }

  /// Identificador do acompanhamento, atribuído pela aplicação.
  final int idAcompanhamento;
  final int idUnidade;
  final int? idGrupoAcompanhamento;
  final int idProtocolo;
  final String? observacao;

  /// Código bruto de `tipo_visualizacao`.
  ///
  /// Os dados reais só comprovam os valores `0` e `2`, insuficientes para um
  /// domínio fechado. O código é preservado como veio do banco, sem enum.
  final int tipoVisualizacao;

  final int idUsuario;
  final DateTime dataAlteracao;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idAcompanhamentoCol: idAcompanhamento,
      idUnidadeCol: idUnidade,
      idGrupoAcompanhamentoCol: idGrupoAcompanhamento,
      idProtocoloCol: idProtocolo,
      observacaoCol: observacao,
      tipoVisualizacaoCol: tipoVisualizacao,
      idUsuarioCol: idUsuario,
      dataAlteracaoCol: dataAlteracao,
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idAcompanhamentoCol);
    return mapa;
  }
}
