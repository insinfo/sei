import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Filtro paginado da listagem de órgãos (`GET /api/v1/orgaos`).
class OrgaoFiltro extends BaseModel {
  static const String siglaCol = 'sigla';
  static const String ativoCol = 'sin_ativo';
  static const String limiteCol = 'limite';
  static const String deslocamentoCol = 'deslocamento';
  static const int limitePadrao = 50;
  static const int limiteMaximo = 100;

  OrgaoFiltro({
    this.sigla,
    this.ativo,
    this.limite = limitePadrao,
    this.deslocamento = 0,
  }) {
    if (limite <= 0 || limite > limiteMaximo) {
      throw ArgumentError.value(
        limite,
        limiteCol,
        'O limite deve estar entre 1 e $limiteMaximo.',
      );
    }
    if (deslocamento < 0) {
      throw ArgumentError.value(
        deslocamento,
        deslocamentoCol,
        'O deslocamento não pode ser negativo.',
      );
    }
  }

  factory OrgaoFiltro.fromMap(Map<String, dynamic> map) {
    final Object? ativoBruto = map[ativoCol];

    return OrgaoFiltro(
      sigla: (map[siglaCol] as String?)?.trim().isEmpty ?? true
          ? null
          : (map[siglaCol] as String).trim(),
      ativo: ativoBruto == null || ativoBruto.toString().trim().isEmpty
          ? null
          : SeiCoreUtils.simNaoParaBool(
              ativoBruto.toString().trim(),
              nomeCampo: ativoCol,
            ),
      limite: map[limiteCol] == null
          ? limitePadrao
          : SeiCoreUtils.inteiro(map[limiteCol], nomeCampo: limiteCol),
      deslocamento: map[deslocamentoCol] == null
          ? 0
          : SeiCoreUtils.inteiro(
              map[deslocamentoCol],
              nomeCampo: deslocamentoCol,
            ),
    );
  }

  final String? sigla;
  final bool? ativo;
  final int limite;
  final int deslocamento;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      siglaCol: sigla,
      ativoCol: ativo == null ? null : SeiCoreUtils.boolParaSimNao(ativo!),
      limiteCol: limite,
      deslocamentoCol: deslocamento,
    };
  }
}
