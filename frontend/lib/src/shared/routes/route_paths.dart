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

  /// Ponto de entrada do login: dispara o redirect OIDC (Authorization Code
  /// + PKCE) para `GET /oauth2/authorize` no backend.
  static final RoutePath login = RoutePath(path: 'login');

  /// Callback do fluxo OIDC: recebe `code`/`state` de volta de
  /// `GET /oauth2/authorize` (via tela de login do backend) e troca o
  /// código por tokens em `POST /oauth2/token`. Caminho fixo `callback`
  /// porque precisa bater exatamente com o `redirect_uri` cadastrado em
  /// `oidc_cliente.uris_redirecionamento`
  /// (`backend/scripts/migrations/0002_oidc_seed_cliente_frontend.sql`).
  static final RoutePath oidcCallback = RoutePath(path: 'callback');

  /// Administração de usuários: listagem e detalhe somente leitura.
  static final RoutePath usuarios = RoutePath(
    path: 'administracao/usuarios',
  );

  /// Administração de unidades: listagem e detalhe somente leitura.
  static final RoutePath unidades = RoutePath(
    path: 'administracao/unidades',
  );

  /// Administração de órgãos: listagem e detalhe somente leitura.
  static final RoutePath orgaos = RoutePath(
    path: 'administracao/orgaos',
  );
}
