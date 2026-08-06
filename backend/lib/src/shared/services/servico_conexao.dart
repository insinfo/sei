import 'package:eloquent/eloquent.dart';

/// Contrato comum para criar conexões no escopo de uma requisição.
///
/// O middleware registra a conexão criada no contêiner filho do Angel. Assim,
/// cada repositório resolvido por `request.make<T>()` usa exclusivamente a
/// conexão daquela requisição, sem estado mutável compartilhado.
abstract interface class ServicoConexao {
  Future<Connection> conectar();

  bool get usaPool;

  Future<void> dispose();
}
