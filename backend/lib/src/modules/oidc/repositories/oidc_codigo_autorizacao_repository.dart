import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Grava, resolve e revoga códigos de autorização de uso único.
class OidcCodigoAutorizacaoRepository {
  OidcCodigoAutorizacaoRepository(this._connection);

  final Connection _connection;

  Future<void> salvar(
    OidcCodigoAutorizacao codigo, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    await conexao
        .table(OidcCodigoAutorizacao.fqtn)
        .insert(codigo.toInsertMap());
  }

  /// Busca o código pelo valor. Um código expirado é revogado na hora e
  /// tratado como inexistente — nunca é trocado por token.
  Future<OidcCodigoAutorizacao?> buscarPorValor(
    String valorCodigo, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    final Map<String, dynamic>? linha = await conexao
        .table(OidcCodigoAutorizacao.fqtn)
        .where(OidcCodigoAutorizacao.valorCodigoCol, '=', valorCodigo)
        .first();

    if (linha == null) {
      return null;
    }

    final OidcCodigoAutorizacao codigo = OidcCodigoAutorizacao.fromMap(linha);
    if (codigo.expirado) {
      await revogar(valorCodigo, connection: conexao);
      return null;
    }
    return codigo;
  }

  /// Apaga o código — é assim que o uso único é garantido: uma segunda
  /// troca com o mesmo valor não encontra mais a linha.
  Future<void> revogar(String valorCodigo, {Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    await conexao
        .table(OidcCodigoAutorizacao.fqtn)
        .where(OidcCodigoAutorizacao.valorCodigoCol, '=', valorCodigo)
        .delete();
  }
}
