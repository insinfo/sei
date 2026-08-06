import 'package:dotenv/dotenv.dart';

/// Configurações de execução da API Dart do SEI.
class SeiAppConfig {
  SeiAppConfig._(this._env);

  factory SeiAppConfig.carregar() {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    return SeiAppConfig._(env);
  }

  final DotEnv _env;

  String get serverHost => _env['server_host'] ?? '127.0.0.1';
  int get serverPort => _inteiro('server_port', padrao: 3350);

  String get dbName => _obrigatorio('db_name');
  String get dbHost => _env['db_host'] ?? '127.0.0.1';
  int get dbPort => _inteiro('db_port', padrao: 5432);
  String get dbUser => _obrigatorio('db_user');
  String get dbPass => _obrigatorio('db_pass');
  String get dbCharset => _env['db_charset'] ?? 'utf8';
  bool get dbUsePool => _booleano('db_pool', padrao: true);
  int get dbPoolSize => _inteiro('db_poolsize', padrao: 2);
  String get desenvolvimentoUsuarioSigla =>
      _env['desenvolvimento_usuario_sigla']?.trim() ?? 'teste';

  String get sipDbName => _env['sip_db_name'] ?? 'sip_5_0_0';
  String get sipDbHost => _env['sip_db_host'] ?? dbHost;
  int get sipDbPort => _inteiro('sip_db_port', padrao: dbPort);
  String get sipDbUser => _env['sip_db_user'] ?? dbUser;
  String get sipDbPass => _env['sip_db_pass'] ?? dbPass;
  String get sipDbCharset => _env['sip_db_charset'] ?? dbCharset;
  bool get sipDbUsePool => _booleano('sip_db_pool', padrao: dbUsePool);
  int get sipDbPoolSize => _inteiro('sip_db_poolsize', padrao: dbPoolSize);
  String get sipApplicationName => '${applicationName}_sip';
  String get applicationName => 'sei_dart';

  List<String> get dbSchemas {
    final schemas = (_env['db_schemes'] ?? 'public')
        .split(',')
        .map((String schema) => schema.trim())
        .where((String schema) => schema.isNotEmpty)
        .toList(growable: false);
    if (schemas.isEmpty) {
      throw StateError('A configuração db_schemes não pode estar vazia.');
    }
    return schemas;
  }

  String _obrigatorio(String chave) {
    final valor = _env[chave]?.trim();
    if (valor == null || valor.isEmpty) {
      throw StateError('A configuração obrigatória $chave não foi informada.');
    }
    return valor;
  }

  int _inteiro(String chave, {required int padrao}) {
    final valor = _env[chave]?.trim();
    if (valor == null || valor.isEmpty) {
      return padrao;
    }
    final inteiro = int.tryParse(valor);
    if (inteiro == null) {
      throw StateError('A configuração $chave deve ser um número inteiro.');
    }
    return inteiro;
  }

  bool _booleano(String chave, {required bool padrao}) {
    final valor = _env[chave]?.trim().toLowerCase();
    if (valor == null || valor.isEmpty) {
      return padrao;
    }
    switch (valor) {
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        throw StateError('A configuração $chave deve ser true ou false.');
    }
  }
}
