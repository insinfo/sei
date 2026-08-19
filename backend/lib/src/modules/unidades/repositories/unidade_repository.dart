import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Acesso a dados de `unidade`: cadastro completo (leitura e escrita).
class UnidadeRepository {
  UnidadeRepository(this._connection);

  final Connection _connection;

  /// Próximo identificador livre de `unidade`.
  ///
  /// `id_unidade` não tem sequência no banco (achado confirmado por
  /// `information_schema.columns`); o próximo valor é calculado por
  /// `MAX(id_unidade) + 1` dentro da mesma transação do insert. Sem lock
  /// explícito: duas escritas concorrentes podem colidir, limitação
  /// conhecida registrada no roteiro mestre.
  Future<int> proximoId({Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    final num? maximo =
        await conexao.table(Unidade.fqtn).max(Unidade.idUnidadeCol);
    return (maximo?.toInt() ?? 0) + 1;
  }

  Future<void> inserir(Unidade unidade, {Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    await conexao.table(Unidade.fqtn).insert(unidade.toInsertMap());
  }

  Future<void> atualizar(
    int idUnidade,
    Unidade dadosCadastrais, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    await conexao
        .table(Unidade.fqtn)
        .where(Unidade.idUnidadeCol, '=', idUnidade)
        .update(dadosCadastrais.toUpdateMap());
  }

  Future<Unidade?> buscarPorId(
    int idUnidade, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    final Map<String, dynamic>? linha = await conexao
        .table(Unidade.fqtn)
        .where(Unidade.idUnidadeCol, '=', idUnidade)
        .first();
    return linha == null ? null : Unidade.fromMap(linha);
  }

  Future<PaginaUnidades> listar(
    UnidadeFiltro filtro, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;

    QueryBuilder construirBase() {
      final QueryBuilder query = conexao.table(Unidade.fqtn);
      if (filtro.idOrgao != null) {
        query.where(Unidade.idOrgaoCol, '=', filtro.idOrgao);
      }
      if (filtro.sigla != null) {
        query.where(Unidade.siglaCol, 'ilike', '%${filtro.sigla}%');
      }
      if (filtro.ativo != null) {
        query.where(
          Unidade.ativoCol,
          '=',
          SeiCoreUtils.boolParaSimNao(filtro.ativo!),
        );
      }
      return query;
    }

    final int total = await construirBase().count();
    final rows = await construirBase()
        .orderBy(Unidade.siglaCol, 'asc')
        .limit(filtro.limite)
        .offset(filtro.deslocamento)
        .get();

    return PaginaUnidades(
      itens: rows
          .map((Map<String, dynamic> row) => Unidade.fromMap(row))
          .toList(growable: false),
      total: total,
      limite: filtro.limite,
      deslocamento: filtro.deslocamento,
    );
  }
}
