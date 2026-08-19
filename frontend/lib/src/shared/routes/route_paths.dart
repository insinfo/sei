import 'package:ngrouter/ngrouter.dart';

/// Caminhos de rota da aplicação, no mesmo padrão de `new_sali/frontend`
/// (`lib/src/shared/routes/route_paths.dart`): centralizados aqui para que
/// `AppRoutes` monte as `RouteDefinition`s e para que qualquer componente
/// gere URLs com `RoutePaths.<rota>.toUrl(...)` sem depender de string
/// literal solta.
class RoutePaths {
  /// Tela de catálogos e controle de processos, sem processo aberto.
  static final RoutePath raiz = RoutePath(path: '', useAsDefault: true);

  /// Detalhe somente leitura de um processo, com `idProcesso` vindo da URL.
  static final RoutePath processoDetalhe = RoutePath(
    path: 'processos/:idProcesso',
  );
}
