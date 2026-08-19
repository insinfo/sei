import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Acesso a dados de `orgao`, incluindo o cadastro completo (leitura e
/// escrita) e as consultas reaproveitadas pelo login (resolver órgão por
/// sigla, listar órgãos ativos para o seletor de login).
class OrgaoRepository {
  OrgaoRepository(this._connection);

  final Connection _connection;

  /// Próximo identificador livre de `orgao`.
  ///
  /// `id_orgao` não tem sequência no banco (achado confirmado por
  /// `information_schema.columns`); o próximo valor é calculado por
  /// `MAX(id_orgao) + 1` dentro da mesma transação do insert. Sem lock
  /// explícito: duas escritas concorrentes podem colidir, limitação
  /// conhecida registrada no roteiro mestre.
  Future<int> proximoId({Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    final num? maximo = await conexao.table(Orgao.fqtn).max(Orgao.idOrgaoCol);
    return (maximo?.toInt() ?? 0) + 1;
  }

  Future<void> inserir(Orgao orgao, {Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    await conexao.table(Orgao.fqtn).insert(orgao.toInsertMap());
  }

  Future<void> atualizar(
    int idOrgao,
    Orgao dadosCadastrais, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    await conexao
        .table(Orgao.fqtn)
        .where(Orgao.idOrgaoCol, '=', idOrgao)
        .update(dadosCadastrais.toUpdateMap());
  }

  Future<Orgao?> buscarPorId(int idOrgao, {Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    final Map<String, dynamic>? linha = await conexao
        .table(Orgao.fqtn)
        .where(Orgao.idOrgaoCol, '=', idOrgao)
        .first();
    return linha == null ? null : Orgao.fromMap(linha);
  }

  Future<Orgao?> buscarPorSigla(String sigla, {Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    final Map<String, dynamic>? linha = await conexao
        .table(Orgao.fqtn)
        .where(Orgao.siglaCol, '=', sigla)
        .first();
    return linha == null ? null : Orgao.fromMap(linha);
  }

  /// Órgãos ativos para o seletor da tela de login.
  ///
  /// Projeção estreita ([OrgaoLoginResumo]): esta rota não exige
  /// autenticação, então não deve devolver o cadastro completo do órgão.
  Future<List<OrgaoLoginResumo>> listarAtivosParaLogin({
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    final rows = await conexao
        .table(Orgao.fqtn)
        .select(const <String>[
          Orgao.idOrgaoCol,
          Orgao.siglaCol,
          Orgao.descricaoCol,
        ])
        .where(Orgao.ativoCol, '=', SeiCoreUtils.boolParaSimNao(true))
        .orderBy(Orgao.siglaCol, 'asc')
        .get();
    return rows
        .map((Map<String, dynamic> row) => OrgaoLoginResumo.fromMap(row))
        .toList(growable: false);
  }

  Future<PaginaOrgaos> listar(OrgaoFiltro filtro,
      {Connection? connection}) async {
    final Connection conexao = connection ?? _connection;

    QueryBuilder construirBase() {
      final QueryBuilder query = conexao.table(Orgao.fqtn);
      if (filtro.sigla != null) {
        query.where(Orgao.siglaCol, 'ilike', '%${filtro.sigla}%');
      }
      if (filtro.ativo != null) {
        query.where(
          Orgao.ativoCol,
          '=',
          SeiCoreUtils.boolParaSimNao(filtro.ativo!),
        );
      }
      return query;
    }

    final int total = await construirBase().count();
    final rows = await construirBase()
        .orderBy(Orgao.siglaCol, 'asc')
        .limit(filtro.limite)
        .offset(filtro.deslocamento)
        .get();

    return PaginaOrgaos(
      itens: rows
          .map((Map<String, dynamic> row) => Orgao.fromMap(row))
          .toList(growable: false),
      total: total,
      limite: filtro.limite,
      deslocamento: filtro.deslocamento,
    );
  }
}
