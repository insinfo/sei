import 'package:ngrouter/ngrouter.dart';
import 'package:sei_frontend/src/modules/app/pages/catalogo_page/catalogo_page.template.dart'
    as catalogo_page_template;
import 'package:sei_frontend/src/modules/processos/pages/processo_detalhe/processo_detalhe_page.template.dart'
    as processo_detalhe_page_template;
import 'package:sei_frontend/src/shared/routes/route_paths.dart';

/// Definições de rota da aplicação, registradas no `<router-outlet>` de
/// `AppComponent`.
///
/// Segue o mesmo padrão de `new_sali/frontend`
/// (`lib/src/shared/routes/my_routes.dart`): cada `RouteDefinition` associa
/// um [RoutePaths] à fábrica gerada (`...NgFactory`) do componente de
/// página correspondente.
class AppRoutes {
  static final RouteDefinition raiz = RouteDefinition(
    routePath: RoutePaths.raiz,
    component: catalogo_page_template.CatalogoPageNgFactory,
  );

  static final RouteDefinition processoDetalhe = RouteDefinition(
    routePath: RoutePaths.processoDetalhe,
    component: processo_detalhe_page_template.ProcessoDetalhePageNgFactory,
  );

  /// Todas as rotas registradas no outlet raiz da aplicação.
  ///
  /// [raiz] fica por último porque casa com qualquer prefixo não reconhecido
  /// enquanto [useAsDefault] estiver ativo — a mesma recomendação do
  /// `ngrouter` seguida pelo `new_sali` de sempre colocar a rota de `/` no
  /// fim da lista.
  static final List<RouteDefinition> all = <RouteDefinition>[
    processoDetalhe,
    raiz,
  ];
}
