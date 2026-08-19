import 'package:ngdart/angular.dart';

/// Guarda a unidade de desenvolvimento atualmente selecionada, compartilhada
/// entre páginas que não têm relação direta de pai/filho no template.
///
/// Antes do roteamento com `ngrouter`, `AppComponent` alternava entre a tela
/// de catálogos e `ProcessoDetalhePage` com `*ngIf`, e por isso conseguia
/// passar `idUnidadeSelecionada` como `@Input()` direto. Com rota própria
/// (`/processos/:idProcesso`), o router instancia `ProcessoDetalhePage` sem
/// passar por esse binding — por isso a unidade selecionada precisa de um
/// serviço singleton, provido na raiz da aplicação junto de
/// `routerProviders`, em vez de um `@Input()`.
@Injectable()
class SessaoUnidadeService {
  /// Unidade de desenvolvimento selecionada no momento, ou `null` quando o
  /// contexto de desenvolvimento ainda não foi carregado.
  int? idUnidadeSelecionada;
}
