/// Utilitários de conversão reutilizáveis nos limites de dados do SEI.
final class SeiCoreUtils {
  const SeiCoreUtils._();

  /// Converte os valores de domínio `S` e `N` persistidos pelo SEI em booleano.
  static bool simNaoParaBool(
    String valor, {
    required String nomeCampo,
  }) {
    switch (valor) {
      case 'S':
        return true;
      case 'N':
        return false;
      default:
        throw FormatException(
          'O campo $nomeCampo deve conter S ou N, mas recebeu $valor.',
        );
    }
  }

  /// Converte um booleano para o domínio `S` e `N` usado pelo banco SEI.
  static String boolParaSimNao(bool valor) => valor ? 'S' : 'N';

  /// Lê um inteiro recebido em JSON, query string ou linha tipada do banco.
  static int inteiro(Object? valor, {required String nomeCampo}) {
    if (valor is int) {
      return valor;
    }
    if (valor is String) {
      final inteiro = int.tryParse(valor);
      if (inteiro != null) {
        return inteiro;
      }
    }
    throw FormatException('O campo $nomeCampo deve conter um número inteiro.');
  }

  /// Serializa identificadores sem perder precisão na fronteira com o navegador.
  static String identificadorParaString(
    Object? valor, {
    required String nomeCampo,
  }) {
    if (valor is int) {
      return valor.toString();
    }
    if (valor is String && RegExp(r'^-?[0-9]+$').hasMatch(valor)) {
      return valor;
    }
    throw FormatException('O campo $nomeCampo deve conter um identificador.');
  }

  /// Lê data e hora civil sem aplicar conversão implícita de fuso horário.
  static DateTime dataHoraLocal(Object? valor, {required String nomeCampo}) {
    if (valor is DateTime) {
      return valor;
    }
    if (valor is String) {
      final dataHora = DateTime.tryParse(valor);
      if (dataHora != null) {
        return dataHora;
      }
    }
    throw FormatException('O campo $nomeCampo deve conter uma data e hora.');
  }
}
