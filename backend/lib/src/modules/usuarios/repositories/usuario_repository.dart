import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Acesso a dados de `usuario`: cadastro (leitura e escrita) e a busca por
/// sigla/órgão reaproveitada pelo login.
class UsuarioRepository {
  UsuarioRepository(this._connection);

  final Connection _connection;

  /// Próximo identificador livre de `usuario`.
  ///
  /// `id_usuario` não tem sequência no banco (achado confirmado por
  /// `information_schema.columns`); o próximo valor é calculado por
  /// `MAX(id_usuario) + 1` dentro da mesma transação do insert. Sem lock
  /// explícito: duas escritas concorrentes podem colidir, limitação
  /// conhecida registrada no roteiro mestre.
  Future<int> proximoId({Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    final num? maximo =
        await conexao.table(Usuario.fqtn).max(Usuario.idUsuarioCol);
    return (maximo?.toInt() ?? 0) + 1;
  }

  Future<void> inserir(Usuario usuario, {Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    await conexao.table(Usuario.fqtn).insert(usuario.toInsertMap());
  }

  /// Atualiza os dados cadastrais (nome, sigla, ativação). Nunca a senha.
  Future<void> atualizar(
    int idUsuario,
    Usuario dadosCadastrais, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    await conexao
        .table(Usuario.fqtn)
        .where(Usuario.idUsuarioCol, '=', idUsuario)
        .update(dadosCadastrais.toUpdateMap());
  }

  /// Único ponto de escrita da coluna `senha` fora da criação do usuário.
  Future<void> atualizarSenha(
    int idUsuario,
    String hashBcrypt, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    await conexao
        .table(Usuario.fqtn)
        .where(Usuario.idUsuarioCol, '=', idUsuario)
        .update(Usuario.mapaAtualizacaoSenha(hashBcrypt));
  }

  Future<Usuario?> buscarPorId(int idUsuario, {Connection? connection}) async {
    final Connection conexao = connection ?? _connection;
    final Map<String, dynamic>? linha = await conexao
        .table(Usuario.fqtn)
        .where(Usuario.idUsuarioCol, '=', idUsuario)
        .first();
    return linha == null ? null : Usuario.fromMap(linha);
  }

  /// Busca o usuário ativo por sigla dentro de um órgão, para o login.
  ///
  /// Inclui o hash de senha ([Usuario.senhaHash]); o repositório de
  /// autenticação usa esse valor só internamente e nunca o repassa em uma
  /// resposta HTTP.
  Future<Usuario?> buscarAtivoPorSiglaEOrgao(
    String sigla,
    int idOrgao, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;
    final Map<String, dynamic>? linha = await conexao
        .table(Usuario.fqtn)
        .where(Usuario.siglaCol, '=', sigla)
        .where(Usuario.idOrgaoCol, '=', idOrgao)
        .where(Usuario.ativoCol, '=', SeiCoreUtils.boolParaSimNao(true))
        .first();
    return linha == null ? null : Usuario.fromMap(linha);
  }

  Future<PaginaUsuarios> listar(
    UsuarioFiltro filtro, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;

    QueryBuilder construirBase() {
      final QueryBuilder query = conexao.table(Usuario.fqtn);
      if (filtro.idOrgao != null) {
        query.where(Usuario.idOrgaoCol, '=', filtro.idOrgao);
      }
      if (filtro.sigla != null) {
        query.where(Usuario.siglaCol, 'ilike', '%${filtro.sigla}%');
      }
      if (filtro.nome != null) {
        query.where(Usuario.nomeCol, 'ilike', '%${filtro.nome}%');
      }
      if (filtro.ativo != null) {
        query.where(
          Usuario.ativoCol,
          '=',
          SeiCoreUtils.boolParaSimNao(filtro.ativo!),
        );
      }
      return query;
    }

    final int total = await construirBase().count();
    final rows = await construirBase()
        .orderBy(Usuario.nomeCol, 'asc')
        .limit(filtro.limite)
        .offset(filtro.deslocamento)
        .get();

    return PaginaUsuarios(
      itens: rows
          .map((Map<String, dynamic> row) => Usuario.fromMap(row))
          .toList(growable: false),
      total: total,
      limite: filtro.limite,
      deslocamento: filtro.deslocamento,
    );
  }
}
