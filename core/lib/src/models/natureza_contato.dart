/// Natureza jurídica do contato, persistida em `contato.sta_natureza`.
///
/// Código-padrão de cadastros públicos brasileiros (pessoa física/pessoa
/// jurídica), confirmado pelos dois únicos valores presentes na Base de
/// Referência local (`SELECT DISTINCT sta_natureza FROM contato`).
enum NaturezaContato {
  /// Pessoa física.
  fisica('F'),

  /// Pessoa jurídica.
  juridica('J');

  const NaturezaContato(this.valor);

  /// Valor persistido em `contato.sta_natureza`.
  final String valor;

  /// Converte o código do banco na natureza conhecida correspondente.
  static NaturezaContato fromValue(String valor) {
    for (final NaturezaContato natureza in values) {
      if (natureza.valor == valor) {
        return natureza;
      }
    }
    throw FormatException(
      'sta_natureza "$valor" não corresponde a uma natureza conhecida.',
    );
  }
}
