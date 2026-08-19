// Gera o par de chaves RSA 2048 bits (JWK, RS256) usado pelo provider OIDC
// do SEI para assinar `id_token`/`access_token` e publicar `jwks`.
//
// Rode a partir da raiz do `backend`:
//   dart run scripts/gera_chave_oidc.dart
//
// Grava `.certificates/sei_idp_private_key.json` (nunca comitada —
// `.certificates/` está no `.gitignore` da raiz do repositório) e
// `.certificates/sei_idp_public_key.json`. Rodar de novo gera um par novo
// com um `kid` novo, invalidando tokens já emitidos com o par antigo — não
// rode em produção sem um plano de rotação de chave.
import 'dart:convert';
import 'dart:io';

import 'package:crypto_keys/crypto_keys.dart' as ck;
import 'package:jose/jose.dart';

void main() {
  JsonWebKey chavePrivada = JsonWebKey.generate('RS256', keyBitLength: 2048);

  final String kid = 'sei-idp-key-${DateTime.now().millisecondsSinceEpoch}';
  chavePrivada = JsonWebKey.fromJson(<String, dynamic>{
    ...chavePrivada.toJson(),
    'kid': kid,
    'alg': 'RS256',
    'use': 'sig',
  });

  final ck.PublicKey? chavePublicaCrypto = chavePrivada.cryptoKeyPair.publicKey;
  if (chavePublicaCrypto is! ck.RsaPublicKey) {
    throw StateError(
      'Tipo de chave pública inesperado: ${chavePublicaCrypto.runtimeType}.',
    );
  }

  JsonWebKey chavePublica = JsonWebKey.rsa(
    modulus: chavePublicaCrypto.modulus,
    exponent: chavePublicaCrypto.exponent,
    keyId: chavePrivada.keyId,
    algorithm: chavePrivada.algorithm,
  );
  chavePublica = JsonWebKey.fromJson(<String, dynamic>{
    ...chavePublica.toJson(),
    'use': 'sig',
  });

  final Directory diretorio = Directory('.certificates');
  if (!diretorio.existsSync()) {
    diretorio.createSync(recursive: true);
  }

  final Map<String, dynamic> jsonPrivado = chavePrivada.toJson();
  final Map<String, dynamic> jsonPublico = chavePublica.toJson();

  File('.certificates/sei_idp_private_key.json')
      .writeAsStringSync(jsonEncode(jsonPrivado));
  File('.certificates/sei_idp_public_key.json')
      .writeAsStringSync(jsonEncode(jsonPublico));

  stdout.writeln('Par de chaves do provider OIDC gerado com sucesso.');
  stdout.writeln('kid: $kid');
  stdout.writeln('Arquivos gravados em .certificates/sei_idp_private_key.json '
      'e .certificates/sei_idp_public_key.json.');
}
