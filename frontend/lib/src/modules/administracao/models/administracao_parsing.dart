/// Conversões tolerantes usadas pelos DTOs de leitura do módulo de
/// administração (usuário, unidade e órgão).
///
/// O contrato exato de serialização desses campos (`sin_ativo` como `S`/`N`,
/// booleano JSON ou ausente) ainda está sendo fechado pelo backend em
/// paralelo a este frontend. Em vez de usar `SeiCoreUtils.simNaoParaBool`
/// (que lança `FormatException` fora do domínio estrito `S`/`N`), este
/// utilitário aceita as formas mais prováveis do valor e cai em um padrão
/// controlado quando o campo não vier no formato esperado, para que uma
/// divergência de contrato não derrube a tela inteira de listagem.
final class AdministracaoParsing {
  const AdministracaoParsing._();

  /// Lê um indicador de "ativo" aceitando booleano, `S`/`N`, `true`/`false`
  /// textual ou número. Retorna `null` quando o valor não pôde ser
  /// interpretado, para que o chamador decida o padrão adequado ao contexto.
  static bool? ativoOpcional(Object? valor) {
    if (valor == null) {
      return null;
    }
    if (valor is bool) {
      return valor;
    }
    if (valor is num) {
      return valor != 0;
    }
    if (valor is String) {
      final String normalizado = valor.trim().toUpperCase();
      if (normalizado == 'S' || normalizado == 'TRUE' || normalizado == '1') {
        return true;
      }
      if (normalizado == 'N' || normalizado == 'FALSE' || normalizado == '0') {
        return false;
      }
    }
    return null;
  }

  /// Igual a [ativoOpcional], mas retorna `true` quando o valor não pôde ser
  /// interpretado — usado nos campos obrigatórios de listagem, para que um
  /// registro não pareça inativo por causa de uma divergência de contrato.
  static bool ativo(Object? valor) => ativoOpcional(valor) ?? true;

  /// Lê um inteiro opcional, tolerando `int`, `String` numérica ou `null`.
  static int? inteiroOpcional(Object? valor) {
    if (valor == null) {
      return null;
    }
    if (valor is int) {
      return valor;
    }
    if (valor is String) {
      return int.tryParse(valor);
    }
    return null;
  }

  /// Lê uma `String` opcional, tratando string vazia como ausente.
  static String? textoOpcional(Object? valor) {
    if (valor is! String) {
      return null;
    }
    final String texto = valor.trim();
    return texto.isEmpty ? null : texto;
  }
}
