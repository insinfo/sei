import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Grava o `contato` mínimo exigido por `usuario`, `orgao` e `unidade`.
///
/// Compartilhado entre os módulos de cadastro (`usuarios`, `unidades`,
/// `orgaos`) porque as três entidades exigem `id_contato NOT NULL` e o
/// contato não pertence a nenhuma delas isoladamente.
class ContatoRepository {
  ContatoRepository(this._connection);

  final Connection _connection;

  /// Próximo identificador livre de `contato`.
  ///
  /// `id_contato` não tem sequência no banco (achado confirmado por
  /// `information_schema.columns`); o próximo valor é calculado por
  /// `MAX(id_contato) + 1` dentro da mesma transação do insert. Sem lock
  /// explícito: duas escritas concorrentes podem colidir, limitação
  /// conhecida registrada no roteiro mestre.
  Future<int> proximoId({Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    final num? maximo =
        await conexao.table(Contato.fqtn).max(Contato.idContatoCol);
    return (maximo?.toInt() ?? 0) + 1;
  }

  Future<void> inserir(Contato contato, {Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    await conexao.table(Contato.fqtn).insert(contato.toInsertMap());
  }
}
