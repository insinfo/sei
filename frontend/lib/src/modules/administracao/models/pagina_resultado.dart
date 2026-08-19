/// Envelope de página genérico para as listagens de administração
/// (usuário, unidade e órgão).
///
/// O formato — `itens`/`total`/`limite`/`deslocamento` — é o mesmo já usado
/// por `PaginaProcessosRecebidos` (`core/lib/src/models`) e descrito no
/// contrato combinado com o backend para `GET /usuarios`, `GET /unidades` e
/// `GET /orgaos`. Diferente daquele modelo, este fica no frontend e é
/// genérico em `T` porque os três recursos de administração compartilham a
/// mesma forma de página, mudando apenas o item — evita repetir a mesma
/// classe três vezes só para trocar o tipo da lista.
class PaginaResultado<T> {
  PaginaResultado({
    required this.itens,
    required this.total,
    required this.limite,
    required this.deslocamento,
  });

  /// Decodifica a página a partir do corpo JSON da resposta, delegando a
  /// leitura de cada item para [itemFromMap].
  factory PaginaResultado.fromMap(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic> item) itemFromMap,
  ) {
    final Object? itensBrutos = map['itens'];
    if (itensBrutos is! List<Object?>) {
      throw const FormatException('O campo itens deve conter uma lista.');
    }

    final List<T> itens = <T>[];
    for (final Object? itemBruto in itensBrutos) {
      if (itemBruto is! Map<String, dynamic>) {
        throw const FormatException('Cada item de itens deve ser um objeto.');
      }
      itens.add(itemFromMap(itemBruto));
    }

    return PaginaResultado<T>(
      itens: itens,
      total: _inteiro(map['total'], nomeCampo: 'total'),
      limite: _inteiro(map['limite'], nomeCampo: 'limite'),
      deslocamento: _inteiro(map['deslocamento'], nomeCampo: 'deslocamento'),
    );
  }

  final List<T> itens;
  final int total;
  final int limite;
  final int deslocamento;

  static int _inteiro(Object? valor, {required String nomeCampo}) {
    if (valor is int) {
      return valor;
    }
    if (valor is String) {
      final int? convertido = int.tryParse(valor);
      if (convertido != null) {
        return convertido;
      }
    }
    throw FormatException('O campo $nomeCampo deve conter um número inteiro.');
  }
}
