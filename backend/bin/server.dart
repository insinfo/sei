import 'dart:io';

import 'package:angel3_framework/src/http/angel_http.dart';
import 'package:sei_backend/sei_backend.dart';

Future<void> main() async {
  final config = SeiAppConfig.carregar();
  final app = criarAplicacao(config);
  await AngelHttp(app).startServer(config.serverHost, config.serverPort);
  stdout.writeln(
    'API SEI Dart disponível em http://${config.serverHost}:${config.serverPort}.',
  );
}
