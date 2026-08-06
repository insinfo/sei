import 'package:angel3_container/mirrors.dart';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/app/sei_app_config.dart';
import 'package:sei_backend/src/di/sei_dependency_injector.dart';
import 'package:sei_backend/src/routes/sei_routes.dart';

/// Cria a aplicação Angel com as rotas públicas somente leitura iniciais.
Angel criarAplicacao(SeiAppConfig config) {
  final app = Angel(reflector: const MirrorsReflector());
  SeiDependencyInjector.configurar(app, config);
  registrarRotasSei(app);
  return app;
}
