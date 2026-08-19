import 'dart:convert';

import 'package:jose/jose.dart';

/// Emite e verifica o JWT stateless de sessão do SEI em Dart.
///
/// Assinatura simétrica (HS256): não há sessão gravada em tabela nenhuma —
/// nem no SEI (`sei_5_0_0`) nem no SIP (`sip_5_0_0.login`, tabela de
/// auditoria de login) — porque escrever ali mutaria uma Base de Referência
/// tratada como somente leitura fora dos testes. Essa fronteira está
/// documentada no roteiro mestre como pendência futura.
class AutenticacaoTokenService {
  AutenticacaoTokenService(String segredo, {required this.duracao})
      : _chave = JsonWebKey.symmetric(
          key: _bytesParaBigInt(utf8.encode(segredo)),
        );

  static const String algoritmo = 'HS256';
  static const String _claimExpiracao = 'exp';
  static const String _claimEmissao = 'iat';

  final JsonWebKey _chave;

  /// Duração de validade do token a partir do momento da emissão.
  final Duration duracao;

  /// Emite um JWT compacto assinado com as [claims] informadas mais `iat`
  /// (emissão) e `exp` (expiração), calculado a partir de [duracao].
  String emitir(Map<String, dynamic> claims) {
    final DateTime agora = DateTime.now();
    final DateTime expiracao = agora.add(duracao);

    final JsonWebSignatureBuilder builder = JsonWebSignatureBuilder()
      ..jsonContent = <String, dynamic>{
        ...claims,
        _claimEmissao: agora.millisecondsSinceEpoch ~/ 1000,
        _claimExpiracao: expiracao.millisecondsSinceEpoch ~/ 1000,
      }
      ..addRecipient(_chave, algorithm: algoritmo);

    return builder.build().toCompactSerialization();
  }

  /// Verifica assinatura e expiração de [token].
  ///
  /// Retorna as claims em caso de sucesso, ou `null` quando o token é
  /// inválido, foi adulterado ou está expirado. Nunca lança exceção: quem
  /// chama trata `null` como "não autenticado".
  Future<Map<String, dynamic>?> verificar(String token) async {
    try {
      final JsonWebKeyStore keyStore = JsonWebKeyStore()..addKey(_chave);
      final JsonWebToken jwt = await JsonWebToken.decodeAndVerify(
        token,
        keyStore,
        allowedArguments: <String>[algoritmo],
      );

      final DateTime? expiracao = jwt.claims.expiry;
      if (expiracao == null || DateTime.now().isAfter(expiracao)) {
        return null;
      }

      return jwt.claims.toJson();
    } catch (_) {
      return null;
    }
  }

  static BigInt _bytesParaBigInt(List<int> bytes) {
    BigInt resultado = BigInt.zero;
    for (final int byte in bytes) {
      resultado = (resultado << 8) | BigInt.from(byte);
    }
    return resultado;
  }
}
