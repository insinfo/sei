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

  /// Segredo simétrico usado para assinar e verificar o JWT de sessão.
  ///
  /// Tem um valor padrão de desenvolvimento para não travar o ambiente
  /// local, mas deve ser sobrescrito por `jwt_secret` em qualquer ambiente
  /// que não seja a máquina de desenvolvimento.
  String get jwtSecret => _env['jwt_secret']?.trim().isNotEmpty == true
      ? _env['jwt_secret']!.trim()
      : 'chave-dev-sei-dart-nao-usar-em-producao';

  /// Duração de validade do JWT de sessão emitido pelo login.
  Duration get jwtDuracao =>
      Duration(hours: _inteiro('jwt_duracao_horas', padrao: 8));

  /// URL pública (`iss`) do provider OIDC deste backend. Base para montar
  /// `authorization_endpoint`, `token_endpoint` etc. no discovery document.
  String get oidcIssuerUrl => _env['oidc_issuer_url']?.trim().isNotEmpty == true
      ? _env['oidc_issuer_url']!.trim()
      : 'http://localhost:$serverPort';

  /// Caminho do arquivo com a chave privada RSA (JWK) usada para assinar
  /// `id_token`/`access_token` do provider OIDC. Gerado por
  /// `backend/scripts/gera_chave_oidc.dart`, nunca commitado
  /// (`.certificates/` está no `.gitignore`).
  String get oidcChavePrivadaCaminho =>
      _env['oidc_chave_privada_caminho']?.trim().isNotEmpty == true
          ? _env['oidc_chave_privada_caminho']!.trim()
          : '.certificates/sei_idp_private_key.json';

  /// Caminho do arquivo com a chave pública RSA (JWK) correspondente,
  /// publicada em `GET /oauth2/jwks`.
  String get oidcChavePublicaCaminho =>
      _env['oidc_chave_publica_caminho']?.trim().isNotEmpty == true
          ? _env['oidc_chave_publica_caminho']!.trim()
          : '.certificates/sei_idp_public_key.json';

  /// Validade do `access_token` emitido pelo provider OIDC.
  Duration get oidcAccessTokenDuracao => Duration(
        minutes: _inteiro('oidc_access_token_duracao_minutos', padrao: 60),
      );

  /// Validade do `id_token` emitido pelo provider OIDC.
  Duration get oidcIdTokenDuracao => Duration(
        minutes: _inteiro('oidc_id_token_duracao_minutos', padrao: 60),
      );

  /// Validade do código de autorização de uso único (`authorize` →
  /// `token`). Curta por definição — só precisa sobreviver ao redirecionamento
  /// do navegador entre os dois passos.
  Duration get oidcCodigoAutorizacaoDuracao => Duration(
        minutes: _inteiro('oidc_codigo_autorizacao_duracao_minutos', padrao: 5),
      );

  /// Validade do `refresh_token` emitido quando o escopo concedido inclui
  /// `offline_access`.
  Duration get oidcRefreshTokenDuracao => Duration(
        days: _inteiro('oidc_refresh_token_duracao_dias', padrao: 30),
      );

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
