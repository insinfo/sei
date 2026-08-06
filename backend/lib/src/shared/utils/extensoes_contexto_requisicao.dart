import 'package:angel3_framework/angel3_framework.dart';

/// Atalhos tipados para dependências do contêiner da requisição Angel.
extension ExtensoesContextoRequisicao on RequestContext {
  /// Obtém uma dependência registrada para a requisição em processamento.
  ///
  /// Repositórios são fábricas registradas no contêiner da aplicação e recebem
  /// a conexão registrada pelo middleware da rota atual.
  T make<T>([Type? type]) {
    final container = this.container;
    if (container == null) {
      throw StateError('O contêiner da requisição não está disponível.');
    }
    return container.make<T>(type);
  }
}
