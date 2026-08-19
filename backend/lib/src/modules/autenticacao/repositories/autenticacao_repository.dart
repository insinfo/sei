import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Consulta usada exclusivamente para validar login: usuário ativo, do
/// órgão informado, com o próprio órgão também ativo.
///
/// É uma consulta própria (não reaproveita `UsuarioRepository`) porque o
/// login precisa das duas condições de ativação (`usuario.sin_ativo` e
/// `orgao.sin_ativo`) resolvidas em uma única ida ao banco, e porque a
/// seleção explícita evita a ambiguidade de `usuario` e `orgao`
/// compartilharem uma coluna `id_contato` com o mesmo nome.
class AutenticacaoRepository {
  AutenticacaoRepository(this._connection);

  final Connection _connection;

  /// Busca o usuário para validação de login: sigla + órgão, ambos ativos.
  ///
  /// O retorno inclui [Usuario.senhaHash]; quem chama este método verifica a
  /// senha com bcrypt e nunca devolve o hash em uma resposta HTTP.
  Future<Usuario?> buscarUsuarioParaLogin(
    String siglaUsuario,
    int idOrgao, {
    Connection? connection,
  }) async {
    final Connection conexao = connection ?? _connection;

    final Map<String, dynamic>? linha = await conexao
        .table(Usuario.fqtn)
        .join(
          Orgao.fqtn,
          Orgao.idOrgaoFqCol,
          '=',
          Usuario.idOrgaoFqCol,
        )
        .selectRaw('''
          ${Usuario.idUsuarioFqCol} AS ${Usuario.idUsuarioCol},
          ${Usuario.idContatoFqCol} AS ${Usuario.idContatoCol},
          ${Usuario.idOrgaoFqCol} AS ${Usuario.idOrgaoCol},
          ${Usuario.idOrigemFqCol} AS ${Usuario.idOrigemCol},
          ${Usuario.ativoFqCol} AS ${Usuario.ativoCol},
          ${Usuario.siglaFqCol} AS ${Usuario.siglaCol},
          ${Usuario.nomeFqCol} AS ${Usuario.nomeCol},
          ${Usuario.idxUsuarioFqCol} AS ${Usuario.idxUsuarioCol},
          ${Usuario.staTipoFqCol} AS ${Usuario.staTipoCol},
          ${Usuario.senhaFqCol} AS ${Usuario.senhaCol},
          ${Usuario.nomeRegistroCivilFqCol} AS ${Usuario.nomeRegistroCivilCol},
          ${Usuario.nomeSocialFqCol} AS ${Usuario.nomeSocialCol},
          ${Usuario.idUsuarioFederacaoFqCol} AS ${Usuario.idUsuarioFederacaoCol},
          ${Usuario.sinGovBrFqCol} AS ${Usuario.sinGovBrCol},
          ${Usuario.dthTermoUsoFqCol} AS ${Usuario.dthTermoUsoCol},
          ${Usuario.dthPoliticaPrivacidadeFqCol} AS ${Usuario.dthPoliticaPrivacidadeCol}
        ''')
        .where(Usuario.siglaFqCol, '=', siglaUsuario)
        .where(Usuario.idOrgaoFqCol, '=', idOrgao)
        .where(Usuario.ativoFqCol, '=', SeiCoreUtils.boolParaSimNao(true))
        .where(Orgao.ativoFqCol, '=', SeiCoreUtils.boolParaSimNao(true))
        .first();

    return linha == null ? null : Usuario.fromMap(linha);
  }
}
