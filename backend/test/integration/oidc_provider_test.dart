import 'dart:convert';

import 'package:angel3_container/angel3_container.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:jose/jose.dart';
import 'package:sei_backend/sei_backend.dart';
import 'package:test/test.dart';

import '../support/escopo_repositorio_teste.dart';
import '../support/oidc_test_harness.dart';

void main() {
  group('provider oidc', () {
    late EscopoRepositorioTeste escopo;

    setUpAll(() async {
      escopo = await EscopoRepositorioTeste.criarSei();
    });

    tearDownAll(() async {
      await escopo.dispose();
    });

    /// Cria um órgão e um usuário de teste com senha conhecida, dentro da
    /// transação revertida — mesmo helper de `autenticacao_test.dart`.
    Future<
        ({
          int idOrgao,
          String siglaOrgao,
          int idUsuario,
          String siglaUsuario,
          String nomeUsuario,
        })> criarUsuario(
      Container container,
      Connection conexao,
    ) async {
      final OrgaoService orgaoService = container.make<OrgaoService>();
      final Orgao orgao = await orgaoService.criar(
        sigla: 'ORGOIDC${DateTime.now().microsecondsSinceEpoch}',
        descricao: 'Órgão de teste do provider OIDC',
        ativo: true,
        connection: conexao,
      );

      final UsuarioService usuarioService = container.make<UsuarioService>();
      final UsuarioRepository usuarioRepository =
          container.make<UsuarioRepository>();
      final Usuario usuario = await usuarioService.criar(
        idOrgao: orgao.idOrgao,
        sigla: 'usuoidc',
        nome: 'Usuário de Teste OIDC',
        senha: 'senhaTemporaria',
        ativo: true,
        connection: conexao,
      );
      final String hash = BCrypt.hashpw('senhaDeTeste123', BCrypt.gensalt());
      await usuarioRepository.atualizarSenha(
        usuario.idUsuario,
        hash,
        connection: conexao,
      );

      return (
        idOrgao: orgao.idOrgao,
        siglaOrgao: orgao.sigla,
        idUsuario: usuario.idUsuario,
        siglaUsuario: usuario.sigla,
        nomeUsuario: usuario.nome,
      );
    }

    /// Cria um cliente OIDC de teste (Relying Party fictício), independente
    /// do cliente real do frontend semeado pela migration 0002.
    Future<OidcCliente> criarCliente(
      Container container,
      Connection conexao, {
      List<String> escoposPermitidos = const <String>['openid', 'profile'],
      String uriRedirecionamento = 'https://cliente-teste.exemplo/callback',
    }) async {
      final OidcCliente cliente = OidcCliente(
        idCliente: OidcCliente.gerarIdCliente(),
        nome: 'Cliente de teste',
        urisRedirecionamento: <String>[uriRedirecionamento],
        escoposPermitidos: escoposPermitidos,
        tipoAplicacao: TipoAplicacaoOidc.webSpa,
        dataCadastro: DateTime.now(),
      );
      await container
          .make<OidcClienteRepository>()
          .inserir(cliente, connection: conexao);
      return cliente;
    }

    String calcularCodeChallenge(String codeVerifier) {
      final List<int> digest = sha256.convert(utf8.encode(codeVerifier)).bytes;
      return base64Url.encode(digest).replaceAll('=', '');
    }

    test('discovery document tem os campos esperados', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final OidcTestHarness harness = OidcTestHarness(escopo.app, conexao);
        final OidcController controller = container.make<OidcController>();

        final resposta = await harness.get(
          '/.well-known/openid-configuration',
          controller.discovery,
        );

        expect(resposta.statusCode, 200);
        final Map<String, dynamic> corpo =
            await OidcTestHarness.corpoJsonDe(resposta);
        final String issuer = corpo['issuer'] as String;

        expect(issuer, isNotEmpty);
        expect(corpo['authorization_endpoint'], '$issuer/oauth2/authorize');
        expect(corpo['token_endpoint'], '$issuer/oauth2/token');
        expect(corpo['userinfo_endpoint'], '$issuer/oauth2/userinfo');
        expect(corpo['jwks_uri'], '$issuer/oauth2/jwks');
        expect(corpo['end_session_endpoint'], '$issuer/oauth2/logout');
        expect(corpo['response_types_supported'], contains('code'));
        expect(
            corpo['id_token_signing_alg_values_supported'], contains('RS256'));
        expect(corpo['code_challenge_methods_supported'], contains('S256'));
        expect(corpo['scopes_supported'],
            containsAll(<String>['openid', 'profile']));
        expect(
          corpo['grant_types_supported'],
          containsAll(<String>['authorization_code', 'refresh_token']),
        );
      });
    });

    test('jwks retorna a chave publica RSA', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final OidcTestHarness harness = OidcTestHarness(escopo.app, conexao);
        final OidcController controller = container.make<OidcController>();

        final resposta = await harness.get('/oauth2/jwks', controller.jwks);

        expect(resposta.statusCode, 200);
        final Map<String, dynamic> corpo =
            await OidcTestHarness.corpoJsonDe(resposta);
        final List<dynamic> chaves = corpo['keys'] as List<dynamic>;

        expect(chaves, hasLength(1));
        final Map<String, dynamic> chave = chaves.first as Map<String, dynamic>;
        expect(chave['kty'], 'RSA');
        expect(chave['alg'], 'RS256');
        expect(chave['n'], isNotEmpty);
        expect(chave['e'], isNotEmpty);
        // Chave privada nunca é publicada.
        expect(chave.containsKey('d'), isFalse);
      });
    });

    test('authorize rejeita client_id desconhecido', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final OidcTestHarness harness = OidcTestHarness(escopo.app, conexao);
        final OidcController controller = container.make<OidcController>();

        final resposta = await harness.get(
          Uri(path: '/oauth2/authorize', queryParameters: <String, String>{
            'response_type': 'code',
            'client_id': 'cliente-que-nao-existe',
            'redirect_uri': 'https://qualquer.exemplo/callback',
          }).toString(),
          controller.authorize,
        );

        expect(resposta.statusCode, 400);
      });
    });

    test('authorize rejeita redirect_uri nao cadastrada para o cliente',
        () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final OidcCliente cliente = await criarCliente(container, conexao);
        final OidcTestHarness harness = OidcTestHarness(escopo.app, conexao);
        final OidcController controller = container.make<OidcController>();

        final resposta = await harness.get(
          Uri(path: '/oauth2/authorize', queryParameters: <String, String>{
            'response_type': 'code',
            'client_id': cliente.idCliente,
            'redirect_uri': 'https://outra-uri.exemplo/callback',
          }).toString(),
          controller.authorize,
        );

        expect(resposta.statusCode, 400);
      });
    });

    test(
      'fluxo completo authorize, login, token com pkce emite tokens rs256 validos',
      () async {
        await escopo.emTransacaoRevertida((
          Container container,
          Connection conexao,
        ) async {
          final cenario = await criarUsuario(container, conexao);
          final OidcCliente cliente = await criarCliente(container, conexao);

          final OidcTestHarness harness = OidcTestHarness(escopo.app, conexao);
          final OidcController oidcController =
              container.make<OidcController>();
          final OidcLoginController loginController =
              container.make<OidcLoginController>();
          final OidcService oidcService = container.make<OidcService>();

          const String codeVerifier =
              'verificador-de-teste-com-entropia-suficiente-1234567890';
          final String codeChallenge = calcularCodeChallenge(codeVerifier);

          Future<String> autorizarELogar({
            required String codeChallengeUsado,
            String senha = 'senhaDeTeste123',
          }) async {
            final respostaAuthorize = await harness.get(
              Uri(path: '/oauth2/authorize', queryParameters: <String, String>{
                'response_type': 'code',
                'client_id': cliente.idCliente,
                'redirect_uri': cliente.urisRedirecionamento.first,
                'scope': 'openid profile',
                'state': 'estado-abc',
                'nonce': 'nonce-abc',
                'code_challenge': codeChallengeUsado,
                'code_challenge_method': 'S256',
              }).toString(),
              oidcController.authorize,
            );
            expect(respostaAuthorize.statusCode, 302);
            final String? destinoLogin = respostaAuthorize.headers['location'];
            expect(destinoLogin, startsWith('/login'));

            final respostaLogin = await harness.postForm(
              destinoLogin!,
              <String, String>{
                'usuario': cenario.siglaUsuario,
                'senha': senha,
                'sigla_orgao': cenario.siglaOrgao,
              },
              loginController.autenticar,
            );
            expect(respostaLogin.statusCode, 302);
            final Uri destinoFinal =
                Uri.parse(respostaLogin.headers['location']!);
            expect(destinoFinal.queryParameters['state'], 'estado-abc');
            final String? codigo = destinoFinal.queryParameters['code'];
            expect(codigo, isNotNull);
            return codigo!;
          }

          // PKCE: code_verifier errado é rejeitado — e, por ser de uso
          // único, o código já é consumido nessa tentativa (ver comentário
          // em OidcController._trocarCodigoPorToken).
          final String codigoParaFalhaPkce =
              await autorizarELogar(codeChallengeUsado: codeChallenge);
          final respostaPkceErrada = await harness.postForm(
            '/oauth2/token',
            <String, String>{
              'grant_type': 'authorization_code',
              'code': codigoParaFalhaPkce,
              'redirect_uri': cliente.urisRedirecionamento.first,
              'client_id': cliente.idCliente,
              'code_verifier': 'verificador-completamente-errado',
            },
            oidcController.token,
          );
          expect(respostaPkceErrada.statusCode, 400);

          // Reusar o mesmo codigo (mesmo com o verifier certo agora) falha:
          // uso unico, o codigo ja foi consumido na tentativa acima.
          final respostaReuso = await harness.postForm(
            '/oauth2/token',
            <String, String>{
              'grant_type': 'authorization_code',
              'code': codigoParaFalhaPkce,
              'redirect_uri': cliente.urisRedirecionamento.first,
              'client_id': cliente.idCliente,
              'code_verifier': codeVerifier,
            },
            oidcController.token,
          );
          expect(respostaReuso.statusCode, 400);

          // Fluxo de sucesso: novo authorize+login, novo codigo, verifier certo.
          final String codigoValido =
              await autorizarELogar(codeChallengeUsado: codeChallenge);
          final respostaToken = await harness.postForm(
            '/oauth2/token',
            <String, String>{
              'grant_type': 'authorization_code',
              'code': codigoValido,
              'redirect_uri': cliente.urisRedirecionamento.first,
              'client_id': cliente.idCliente,
              'code_verifier': codeVerifier,
            },
            oidcController.token,
          );
          expect(respostaToken.statusCode, 200);
          final Map<String, dynamic> corpoToken =
              await OidcTestHarness.corpoJsonDe(respostaToken);

          expect(corpoToken['access_token'], isNotEmpty);
          expect(corpoToken['id_token'], isNotEmpty);
          expect(corpoToken['token_type'], 'Bearer');
          expect(corpoToken['scope'], 'openid profile');
          // Escopo concedido nao incluiu offline_access.
          expect(corpoToken.containsKey('refresh_token'), isFalse);

          final JsonWebKeyStore keyStore = JsonWebKeyStore()
            ..addKeySet(oidcService.jwks);

          final JsonWebToken idTokenVerificado =
              await JsonWebToken.decodeAndVerify(
            corpoToken['id_token'] as String,
            keyStore,
            allowedArguments: <String>['RS256'],
          );
          final Map<String, dynamic> claimsIdToken =
              idTokenVerificado.claims.toJson();
          expect(claimsIdToken['iss'], oidcService.discoveryDocument['issuer']);
          expect(claimsIdToken['sub'], cenario.idUsuario.toString());
          expect(claimsIdToken['aud'], cliente.idCliente);
          expect(claimsIdToken['nonce'], 'nonce-abc');
          expect(claimsIdToken['name'], cenario.nomeUsuario);
          expect(claimsIdToken['preferred_username'], cenario.siglaUsuario);
          expect(claimsIdToken['exp'], isNotNull);

          final JsonWebToken accessTokenVerificado =
              await JsonWebToken.decodeAndVerify(
            corpoToken['access_token'] as String,
            keyStore,
            allowedArguments: <String>['RS256'],
          );
          final Map<String, dynamic> claimsAccessToken =
              accessTokenVerificado.claims.toJson();
          expect(claimsAccessToken['sub'], cenario.idUsuario.toString());
          expect(claimsAccessToken['client_id'], cliente.idCliente);
          expect(claimsAccessToken['scope'], 'openid profile');

          // userinfo com o access_token emitido.
          final respostaUserinfo = await harness.get(
            '/oauth2/userinfo',
            oidcController.userinfo,
            headers: <String, String>{
              'authorization': 'Bearer ${corpoToken['access_token']}',
            },
          );
          expect(respostaUserinfo.statusCode, 200);
          final Map<String, dynamic> corpoUserinfo =
              await OidcTestHarness.corpoJsonDe(respostaUserinfo);
          expect(corpoUserinfo['sub'], cenario.idUsuario.toString());
          expect(corpoUserinfo['name'], cenario.nomeUsuario);
          expect(corpoUserinfo['preferred_username'], cenario.siglaUsuario);
        });
      },
    );

    test('token com refresh_token emite novo access_token e revoga o antigo',
        () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final cenario = await criarUsuario(container, conexao);
        final OidcCliente cliente = await criarCliente(
          container,
          conexao,
          escoposPermitidos: const <String>[
            'openid',
            'profile',
            'offline_access'
          ],
        );

        final OidcTestHarness harness = OidcTestHarness(escopo.app, conexao);
        final OidcController oidcController = container.make<OidcController>();
        final OidcLoginController loginController =
            container.make<OidcLoginController>();

        final respostaAuthorize = await harness.get(
          Uri(path: '/oauth2/authorize', queryParameters: <String, String>{
            'response_type': 'code',
            'client_id': cliente.idCliente,
            'redirect_uri': cliente.urisRedirecionamento.first,
            'scope': 'openid profile offline_access',
          }).toString(),
          oidcController.authorize,
        );
        final String destinoLogin = respostaAuthorize.headers['location']!;

        final respostaLogin = await harness.postForm(
          destinoLogin,
          <String, String>{
            'usuario': cenario.siglaUsuario,
            'senha': 'senhaDeTeste123',
            'sigla_orgao': cenario.siglaOrgao,
          },
          loginController.autenticar,
        );
        final Uri destinoFinal = Uri.parse(respostaLogin.headers['location']!);
        final String codigo = destinoFinal.queryParameters['code']!;

        final respostaToken = await harness.postForm(
          '/oauth2/token',
          <String, String>{
            'grant_type': 'authorization_code',
            'code': codigo,
            'redirect_uri': cliente.urisRedirecionamento.first,
            'client_id': cliente.idCliente,
          },
          oidcController.token,
        );
        expect(respostaToken.statusCode, 200);
        final Map<String, dynamic> corpoToken =
            await OidcTestHarness.corpoJsonDe(respostaToken);
        final String refreshTokenOriginal =
            corpoToken['refresh_token'] as String;
        expect(refreshTokenOriginal, isNotEmpty);

        final respostaRenovacao = await harness.postForm(
          '/oauth2/token',
          <String, String>{
            'grant_type': 'refresh_token',
            'refresh_token': refreshTokenOriginal,
          },
          oidcController.token,
        );
        expect(respostaRenovacao.statusCode, 200);
        final Map<String, dynamic> corpoRenovacao =
            await OidcTestHarness.corpoJsonDe(respostaRenovacao);
        expect(corpoRenovacao['access_token'], isNotEmpty);
        expect(
            corpoRenovacao['access_token'], isNot(corpoToken['access_token']));
        final String novoRefreshToken =
            corpoRenovacao['refresh_token'] as String;
        expect(novoRefreshToken, isNot(refreshTokenOriginal));

        // Token antigo, ja rotacionado, nao pode ser usado de novo.
        final respostaReusoRefresh = await harness.postForm(
          '/oauth2/token',
          <String, String>{
            'grant_type': 'refresh_token',
            'refresh_token': refreshTokenOriginal,
          },
          oidcController.token,
        );
        expect(respostaReusoRefresh.statusCode, 401);

        // O novo token de renovacao continua valido.
        final respostaSegundaRenovacao = await harness.postForm(
          '/oauth2/token',
          <String, String>{
            'grant_type': 'refresh_token',
            'refresh_token': novoRefreshToken,
          },
          oidcController.token,
        );
        expect(respostaSegundaRenovacao.statusCode, 200);
      });
    });

    test('login com senha incorreta nao emite codigo e volta para o login',
        () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final cenario = await criarUsuario(container, conexao);
        final OidcCliente cliente = await criarCliente(container, conexao);

        final OidcTestHarness harness = OidcTestHarness(escopo.app, conexao);
        final OidcController oidcController = container.make<OidcController>();
        final OidcLoginController loginController =
            container.make<OidcLoginController>();

        final respostaAuthorize = await harness.get(
          Uri(path: '/oauth2/authorize', queryParameters: <String, String>{
            'response_type': 'code',
            'client_id': cliente.idCliente,
            'redirect_uri': cliente.urisRedirecionamento.first,
            'scope': 'openid',
          }).toString(),
          oidcController.authorize,
        );
        final String destinoLogin = respostaAuthorize.headers['location']!;

        final respostaLogin = await harness.postForm(
          destinoLogin,
          <String, String>{
            'usuario': cenario.siglaUsuario,
            'senha': 'senhaErrada',
            'sigla_orgao': cenario.siglaOrgao,
          },
          loginController.autenticar,
        );

        expect(respostaLogin.statusCode, 302);
        final Uri destinoErro = Uri.parse(respostaLogin.headers['location']!);
        expect(destinoErro.path, '/login');
        expect(destinoErro.queryParameters['erro'], 'credenciais_invalidas');
      });
    });

    test(
        'logout redireciona para post_logout_redirect_uri quando o id_token_hint é válido',
        () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final cenario = await criarUsuario(container, conexao);
        final OidcCliente cliente = OidcCliente(
          idCliente: OidcCliente.gerarIdCliente(),
          nome: 'Cliente de teste de logout',
          urisRedirecionamento: const <String>[
            'https://cliente-logout.exemplo/callback'
          ],
          escoposPermitidos: const <String>['openid'],
          tipoAplicacao: TipoAplicacaoOidc.webSpa,
          dataCadastro: DateTime.now(),
          urisRedirecionamentoPosLogout: const <String>[
            'https://cliente-logout.exemplo/pos-logout',
          ],
        );
        await container
            .make<OidcClienteRepository>()
            .inserir(cliente, connection: conexao);

        final OidcService oidcService = container.make<OidcService>();
        final String idTokenHint = oidcService.criarIdToken(
          idUsuario: cenario.idUsuario,
          cliente: cliente,
          escopos: const <String>['openid'],
          authTime: DateTime.now(),
        );

        final OidcTestHarness harness = OidcTestHarness(escopo.app, conexao);
        final OidcController oidcController = container.make<OidcController>();

        final resposta = await harness.get(
          Uri(path: '/oauth2/logout', queryParameters: <String, String>{
            'post_logout_redirect_uri':
                'https://cliente-logout.exemplo/pos-logout',
            'id_token_hint': idTokenHint,
            'state': 'estado-logout',
          }).toString(),
          oidcController.logout,
        );

        expect(resposta.statusCode, 302);
        final Uri destino = Uri.parse(resposta.headers['location']!);
        expect(destino.toString(),
            startsWith('https://cliente-logout.exemplo/pos-logout'));
        expect(destino.queryParameters['state'], 'estado-logout');
      });
    });

    test('logout sem id_token_hint valido cai no fallback de login', () async {
      await escopo.emTransacaoRevertida((
        Container container,
        Connection conexao,
      ) async {
        final OidcTestHarness harness = OidcTestHarness(escopo.app, conexao);
        final OidcController oidcController = container.make<OidcController>();

        final resposta = await harness.get(
          Uri(path: '/oauth2/logout', queryParameters: <String, String>{
            'post_logout_redirect_uri':
                'https://qualquer.exemplo/nao-cadastrada',
          }).toString(),
          oidcController.logout,
        );

        expect(resposta.statusCode, 302);
        expect(resposta.headers['location'], '/login');
      });
    });
  });
}
