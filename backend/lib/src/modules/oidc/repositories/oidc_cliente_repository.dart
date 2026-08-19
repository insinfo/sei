import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Consulta os clientes (Relying Parties) registrados no provider OIDC.
///
/// Cadastro de cliente novo é feito por script/migration nesta rodada (ver
/// `backend/scripts/migrations/0002_oidc_seed_cliente_frontend.sql`), não
/// por rota HTTP — não há tela administrativa de clientes OIDC ainda.
class OidcClienteRepository {
  OidcClienteRepository(this._connection);

  final Connection _connection;

  /// Grava um cliente novo. Usado hoje pelo script de seed do primeiro
  /// cliente (o frontend do SEI) e por fixtures de teste — não há rota
  /// HTTP de cadastro de cliente OIDC nesta rodada.
  Future<void> inserir(OidcCliente cliente, {Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    await conexao.table(OidcCliente.fqtn).insert(cliente.toInsertMap());
  }

  /// Busca um cliente ativo pelo `id_cliente`. Cliente inativo ou
  /// inexistente é tratado como desconhecido pelo provider.
  Future<OidcCliente?> buscarAtivoPorId(
    String idCliente, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    final Map<String, dynamic>? linha = await conexao
        .table(OidcCliente.fqtn)
        .where(OidcCliente.idClienteCol, '=', idCliente)
        .where(OidcCliente.ativoCol, '=', true)
        .first();

    return linha == null ? null : OidcCliente.fromMap(linha);
  }
}
