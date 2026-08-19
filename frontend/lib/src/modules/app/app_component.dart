import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:sei_frontend/src/modules/catalogos/services/catalogos_service.dart';
import 'package:sei_frontend/src/modules/contexto_desenvolvimento/services/contexto_desenvolvimento_service.dart';
import 'package:sei_frontend/src/modules/controle_processos/services/controle_processos_service.dart';
import 'package:sei_frontend/src/shared/routes/app_routes.dart';
import 'package:sei_frontend/src/shared/services/sessao_unidade_service.dart';

/// Casco raiz da aplicação: só o `<router-outlet>` e os provedores
/// compartilhados por toda a árvore roteada.
///
/// Antes do `ngrouter`, este componente também continha a tela de catálogos
/// inteira e alternava para `ProcessoDetalhePage` com um `*ngIf` manual —
/// ver "Estado de execução local em 19 de agosto de 2026 — realinhamento
/// estrutural" no roteiro mestre. Essa tela agora é `CatalogoPage`
/// (`modules/app/pages/catalogo_page`), roteada em [RoutePaths.raiz]; o
/// detalhe do processo é `ProcessoDetalhePage`, roteada em
/// [RoutePaths.processoDetalhe]. `routerProviders` e os serviços que as
/// páginas roteadas precisam ficam aqui, na raiz da árvore de injeção, pois
/// o `RouterOutlet` cria as páginas como filhas deste componente — nunca do
/// template de quem navegou.
@Component(
  selector: 'sei-app',
  templateUrl: 'app_component.html',
  styleUrls: <String>['app_component.css'],
  directives: <Type>[RouterOutlet],
  providers: <Object>[
    routerProviders,
    ClassProvider(CatalogosService),
    ClassProvider(ControleProcessosService),
    ClassProvider(ContextoDesenvolvimentoService),
    ClassProvider(SessaoUnidadeService),
  ],
)
class AppComponent {
  /// Rotas registradas no outlet raiz, expostas como campo estável para o
  /// binding `[routes]` — evita recriar a lista a cada ciclo de checagem.
  final List<RouteDefinition> routes = AppRoutes.all;
}
