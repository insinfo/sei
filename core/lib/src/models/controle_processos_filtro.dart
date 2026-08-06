import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/controle_processos_modo.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Filtro paginado para atividades abertas da unidade selecionada.
class ControleProcessosFiltro extends BaseModel {
  static const String idUnidadeCol = 'id_unidade';
  static const String limiteCol = 'limite';
  static const String deslocamentoCol = 'deslocamento';
  static const String modoCol = 'modo';
  static const int limitePadrao = 50;
  static const int limiteMaximo = 100;

  ControleProcessosFiltro({
    required this.idUnidade,
    this.modo = ControleProcessosModo.recebidos,
    this.limite = limitePadrao,
    this.deslocamento = 0,
  }) {
    if (idUnidade <= 0) {
      throw ArgumentError.value(
        idUnidade,
        idUnidadeCol,
        'O identificador da unidade deve ser positivo.',
      );
    }
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

  factory ControleProcessosFiltro.fromMap(
    Map<String, dynamic> map, {
    ControleProcessosModo modo = ControleProcessosModo.recebidos,
  }) {
    final Object? idUnidade = map[idUnidadeCol];
    if (idUnidade == null || idUnidade.toString().trim().isEmpty) {
      throw FormatException('O parâmetro $idUnidadeCol é obrigatório.');
    }

    return ControleProcessosFiltro(
      idUnidade: SeiCoreUtils.inteiro(
        idUnidade,
        nomeCampo: idUnidadeCol,
      ),
      modo: modo,
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

  final int idUnidade;
  final ControleProcessosModo modo;
  final int limite;
  final int deslocamento;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idUnidadeCol: idUnidade,
      modoCol: modo.valor,
      limiteCol: limite,
      deslocamentoCol: deslocamento,
    };
  }
}
