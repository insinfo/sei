import 'package:sei_core/sei_core.dart';

/// Converte parâmetros HTTP primitivos sem espalhar validação entre rotas.
final class ParametrosHttp {
  const ParametrosHttp._();

  /// Lê um identificador inteiro positivo recebido em parâmetro de rota.
  static int identificadorPositivo(
    Object? valor, {
    required String nomeCampo,
  }) {
    if (valor == null || valor.toString().trim().isEmpty) {
      throw FormatException('O identificador $nomeCampo é obrigatório.');
    }
    final identificador = SeiCoreUtils.inteiro(valor, nomeCampo: nomeCampo);
    if (identificador <= 0) {
      throw FormatException('O identificador $nomeCampo é inválido.');
    }
    return identificador;
  }
}
