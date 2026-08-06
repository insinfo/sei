import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Lê o contexto local da referência sem simular uma autenticação SIP.
class ContextoDesenvolvimentoRepository {
  ContextoDesenvolvimentoRepository(this._connection);

  final Connection _connection;

  Future<ContextoDesenvolvimento> obterPorSiglaUsuario(
    String siglaUsuario,
  ) async {
    final usuario = await _connection
        .table(ContextoDesenvolvimento.fqtn)
        .selectRaw('''
          ${ContextoDesenvolvimento.idUsuarioFqCol} AS ${ContextoDesenvolvimento.idUsuarioCol},
          ${ContextoDesenvolvimento.idOrgaoFqCol} AS ${ContextoDesenvolvimento.idOrgaoCol},
          ${ContextoDesenvolvimento.usuarioSiglaFqCol} AS ${ContextoDesenvolvimento.siglaUsuarioCol},
          ${ContextoDesenvolvimento.usuarioNomeFqCol} AS ${ContextoDesenvolvimento.nomeUsuarioCol}
        ''')
        .where(
          ContextoDesenvolvimento.usuarioSiglaFqCol,
          '=',
          siglaUsuario,
        )
        .where(
          ContextoDesenvolvimento.usuarioAtivoFqCol,
          '=',
          SeiCoreUtils.boolParaSimNao(true),
        )
        .first();

    if (usuario == null) {
      throw StateError(
        'Não foi encontrado usuário ativo para o contexto de desenvolvimento.',
      );
    }

    final idOrgao = usuario[ContextoDesenvolvimento.idOrgaoCol] as int;
    final unidadesRows = await _connection
        .table(UnidadeResumo.fqtn)
        .select(const <String>[
          UnidadeResumo.idUnidadeFqCol,
          UnidadeResumo.idOrgaoFqCol,
          UnidadeResumo.siglaFqCol,
          UnidadeResumo.descricaoFqCol,
          UnidadeResumo.ativoFqCol,
        ])
        .where(UnidadeResumo.idOrgaoFqCol, '=', idOrgao)
        .where(
          UnidadeResumo.ativoFqCol,
          '=',
          SeiCoreUtils.boolParaSimNao(true),
        )
        .orderBy(UnidadeResumo.siglaFqCol, 'asc')
        .orderBy(UnidadeResumo.idUnidadeFqCol, 'asc')
        .get();
    final unidades = unidadesRows
        .map((Map<String, dynamic> row) => UnidadeResumo.fromMap(row))
        .toList(growable: false);

    if (unidades.isEmpty) {
      throw StateError(
        'Não há unidades ativas para o órgão do contexto de desenvolvimento.',
      );
    }

    return ContextoDesenvolvimento(
      idUsuario: usuario[ContextoDesenvolvimento.idUsuarioCol] as int,
      idOrgao: idOrgao,
      siglaUsuario: usuario[ContextoDesenvolvimento.siglaUsuarioCol] as String,
      nomeUsuario: usuario[ContextoDesenvolvimento.nomeUsuarioCol] as String,
      unidades: unidades,
      idUnidadeInicial: unidades.first.idUnidade,
    );
  }
}
