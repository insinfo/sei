import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Grava, resolve e revoga refresh tokens do provider OIDC.
class OidcTokenRenovacaoRepository {
  OidcTokenRenovacaoRepository(this._connection);

  final Connection _connection;

  Future<void> salvar(
    OidcTokenRenovacao token, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    await conexao.table(OidcTokenRenovacao.fqtn).insert(token.toInsertMap());
  }

  /// Busca um refresh token válido (não revogado e não expirado) pelo
  /// valor. Um token expirado é revogado na hora e tratado como
  /// inexistente.
  Future<OidcTokenRenovacao?> buscarValidoPorValor(
    String valorToken, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    final Map<String, dynamic>? linha = await conexao
        .table(OidcTokenRenovacao.fqtn)
        .where(OidcTokenRenovacao.valorTokenCol, '=', valorToken)
        .where(OidcTokenRenovacao.revogadoCol, '=', false)
        .first();

    if (linha == null) {
      return null;
    }

    final OidcTokenRenovacao token = OidcTokenRenovacao.fromMap(linha);
    if (token.expirado) {
      await revogar(valorToken, connection: conexao);
      return null;
    }
    return token;
  }

  /// Marca o token como revogado — usado tanto na rotação (o token trocado
  /// nunca mais é aceito) quanto na expiração lida em
  /// [buscarValidoPorValor].
  Future<void> revogar(String valorToken, {Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    await conexao
        .table(OidcTokenRenovacao.fqtn)
        .where(OidcTokenRenovacao.valorTokenCol, '=', valorToken)
        .update(<String, dynamic>{OidcTokenRenovacao.revogadoCol: true});
  }
}
