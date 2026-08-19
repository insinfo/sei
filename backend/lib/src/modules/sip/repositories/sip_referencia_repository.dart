import 'package:eloquent/eloquent.dart';
import 'package:sei_core/sei_core.dart';

/// Consulta cadastros públicos de referência do SIP e resolve autorização.
///
/// **Não trata autenticação.** A Base de Referência não guarda senha nem
/// hash de usuário algum: a verificação de identidade é delegada a um
/// LDAP/AD externo por órgão (`servidor_autenticacao.sta_tipo = 'AD'`), que
/// não existe neste laboratório local. Este repositório recebe `idUsuario` e
/// `idUnidade` já resolvidos por outro mecanismo e responde só a metade de
/// autorização: quais perfis estão vigentes e quais recursos eles liberam.
/// Ver `AutorizacaoUsuario` e `backend/docs/evidencias_processo_detalhe.md`.
class SipReferenciaRepository {
  SipReferenciaRepository(this._connection);

  final Connection _connection;

  Future<List<SistemaSipResumo>> listarSistemasAtivos() async {
    final rows = await _connection
        .table(SistemaSipResumo.fqtn)
        .select(const <String>[
          SistemaSipResumo.idSistemaCol,
          SistemaSipResumo.siglaCol,
          SistemaSipResumo.descricaoCol,
          SistemaSipResumo.ativoCol,
        ])
        .where(
          SistemaSipResumo.ativoCol,
          '=',
          SeiCoreUtils.boolParaSimNao(true),
        )
        .orderBy(SistemaSipResumo.idSistemaCol, 'asc')
        .get();
    return rows
        .map((Map<String, dynamic> row) => SistemaSipResumo.fromMap(row))
        .toList(growable: false);
  }

  /// Resolve os perfis vigentes e os recursos liberados por eles para um
  /// usuário em uma unidade.
  ///
  /// "Vigente" segue só a janela `dta_inicio`/`dta_fim` de `permissao`: uma
  /// concessão vale quando `dta_inicio` já passou e (`dta_fim` é nulo ou
  /// ainda não passou). Quando `idSistema` é informado, a resolução fica
  /// restrita àquele sistema (por exemplo, só SEI); sem ele, perfis e
  /// recursos de todos os sistemas do usuário na unidade são combinados.
  ///
  /// As duas consultas são únicas cada uma (sem N+1 por perfil): a de perfis
  /// junta `permissao` a `perfil`, e a de recursos junta `permissao` a
  /// `perfil`, `rel_perfil_recurso` e `recurso`, deduplicando com
  /// `DISTINCT` porque o mesmo recurso pode ser liberado por mais de um
  /// perfil do usuário.
  Future<AutorizacaoUsuario> resolverAutorizacao(
    int idUsuario,
    int idUnidade, {
    int? idSistema,
  }) async {
    final List<PerfilAtivo> perfis = await _listarPerfisAtivos(
      idUsuario,
      idUnidade,
      idSistema: idSistema,
    );
    final List<RecursoSip> recursos = await _listarRecursosLiberados(
      idUsuario,
      idUnidade,
      idSistema: idSistema,
    );

    return AutorizacaoUsuario(
      idUsuario: idUsuario,
      idUnidade: idUnidade,
      perfis: perfis,
      recursos: recursos,
    );
  }

  Future<List<PerfilAtivo>> _listarPerfisAtivos(
    int idUsuario,
    int idUnidade, {
    int? idSistema,
  }) async {
    final QueryBuilder query = _connection
        .table(PerfilAtivo.fqtn)
        .join(PerfilSip.fqtn, (JoinClause join) {
          join
            ..on(PerfilSip.idPerfilFqCol, '=', PerfilAtivo.idPerfilFqCol)
            ..on(PerfilSip.idSistemaFqCol, '=', PerfilAtivo.idSistemaFqCol);
        })
        .selectRaw('''
          ${PerfilSip.idPerfilFqCol} AS ${PerfilSip.idPerfilCol},
          ${PerfilSip.idSistemaFqCol} AS ${PerfilSip.idSistemaCol},
          ${PerfilSip.nomeFqCol} AS ${PerfilSip.nomeCol},
          ${PerfilSip.descricaoFqCol} AS ${PerfilSip.descricaoCol},
          ${PerfilSip.coordenadoFqCol} AS ${PerfilSip.coordenadoCol},
          ${PerfilSip.ativoFqCol} AS ${PerfilSip.ativoCol},
          ${PerfilSip.doisFatoresFqCol} AS ${PerfilSip.doisFatoresCol},
          ${PerfilAtivo.idTipoPermissaoFqCol} AS ${PerfilAtivo.idTipoPermissaoCol},
          ${PerfilAtivo.dataInicioFqCol} AS ${PerfilAtivo.dataInicioCol},
          ${PerfilAtivo.dataFimFqCol} AS ${PerfilAtivo.dataFimCol},
          ${PerfilAtivo.subunidadesFqCol} AS ${PerfilAtivo.subunidadesCol}
        ''')
        .where(PerfilAtivo.idUsuarioFqCol, '=', idUsuario)
        .where(PerfilAtivo.idUnidadeFqCol, '=', idUnidade)
        .whereRaw('${PerfilAtivo.dataInicioFqCol} <= LOCALTIMESTAMP')
        .whereRaw(
          '(${PerfilAtivo.dataFimFqCol} IS NULL OR '
          '${PerfilAtivo.dataFimFqCol} >= LOCALTIMESTAMP)',
        );

    if (idSistema != null) {
      query.where(PerfilAtivo.idSistemaFqCol, '=', idSistema);
    }

    final rows = await query
        .orderBy(PerfilSip.idSistemaFqCol, 'asc')
        .orderBy(PerfilSip.idPerfilFqCol, 'asc')
        .get();

    return rows
        .map((Map<String, dynamic> row) => PerfilAtivo.fromConsultaRow(row))
        .toList(growable: false);
  }

  Future<List<RecursoSip>> _listarRecursosLiberados(
    int idUsuario,
    int idUnidade, {
    int? idSistema,
  }) async {
    final QueryBuilder query = _connection
        .table(PerfilAtivo.fqtn)
        .join(PerfilSip.fqtn, (JoinClause join) {
          join
            ..on(PerfilSip.idPerfilFqCol, '=', PerfilAtivo.idPerfilFqCol)
            ..on(PerfilSip.idSistemaFqCol, '=', PerfilAtivo.idSistemaFqCol);
        })
        .join(AutorizacaoUsuario.fqtnRelPerfilRecurso, (JoinClause join) {
          join
            ..on(
              AutorizacaoUsuario.relIdPerfilFqCol,
              '=',
              PerfilSip.idPerfilFqCol,
            )
            ..on(
              AutorizacaoUsuario.relIdSistemaFqCol,
              '=',
              PerfilSip.idSistemaFqCol,
            );
        })
        .join(RecursoSip.fqtn, (JoinClause join) {
          join
            ..on(
              RecursoSip.idRecursoFqCol,
              '=',
              AutorizacaoUsuario.relIdRecursoFqCol,
            )
            ..on(
              RecursoSip.idSistemaFqCol,
              '=',
              AutorizacaoUsuario.relIdSistemaFqCol,
            );
        })
        .distinct()
        .selectRaw('''
          ${RecursoSip.idSistemaFqCol} AS ${RecursoSip.idSistemaCol},
          ${RecursoSip.idRecursoFqCol} AS ${RecursoSip.idRecursoCol},
          ${RecursoSip.nomeFqCol} AS ${RecursoSip.nomeCol},
          ${RecursoSip.descricaoFqCol} AS ${RecursoSip.descricaoCol},
          ${RecursoSip.caminhoFqCol} AS ${RecursoSip.caminhoCol},
          ${RecursoSip.ativoFqCol} AS ${RecursoSip.ativoCol}
        ''')
        .where(PerfilAtivo.idUsuarioFqCol, '=', idUsuario)
        .where(PerfilAtivo.idUnidadeFqCol, '=', idUnidade)
        .whereRaw('${PerfilAtivo.dataInicioFqCol} <= LOCALTIMESTAMP')
        .whereRaw(
          '(${PerfilAtivo.dataFimFqCol} IS NULL OR '
          '${PerfilAtivo.dataFimFqCol} >= LOCALTIMESTAMP)',
        );

    if (idSistema != null) {
      query.where(PerfilAtivo.idSistemaFqCol, '=', idSistema);
    }

    final rows = await query
        .orderBy(RecursoSip.idSistemaFqCol, 'asc')
        .orderBy(RecursoSip.idRecursoFqCol, 'asc')
        .get();

    return rows
        .map((Map<String, dynamic> row) => RecursoSip.fromMap(row))
        .toList(growable: false);
  }
}
