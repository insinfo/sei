import 'package:eloquent/eloquent.dart';
import 'package:sei_backend/src/modules/orgaos/repositories/orgao_repository.dart';
import 'package:sei_backend/src/shared/repositories/contato_repository.dart';
import 'package:sei_core/sei_core.dart';

/// Orquestra a criação e a atualização de órgão: geração de próximo id e o
/// `contato` associado.
///
/// O contato do órgão referencia a si mesmo
/// (`id_contato_associado = id_contato`, confirmado no cadastro local —
/// ver Dartdoc de [TipoContato]), diferente do contato de usuário/unidade,
/// que referencia o contato do órgão dono.
///
/// O órgão é sempre criado com `id_unidade` nulo (sem unidade raiz ainda):
/// a coluna é opcional na Base de Referência e vincular uma unidade como
/// raiz é uma operação futura, fora do escopo desta rodada (ver Dartdoc de
/// [Orgao]).
///
/// Mesma estratégia de transação de `UsuarioService`/`UnidadeService`.
class OrgaoService {
  OrgaoService(
      this._connection, this._orgaoRepository, this._contatoRepository);

  final Connection _connection;
  final OrgaoRepository _orgaoRepository;
  final ContatoRepository _contatoRepository;

  Future<Orgao> criar({
    required String sigla,
    required String descricao,
    bool ativo = true,
    String? codigoSei,
    Connection? connection,
  }) async {
    if (connection != null) {
      return _criarComConexao(
        sigla: sigla,
        descricao: descricao,
        ativo: ativo,
        codigoSei: codigoSei,
        conexao: connection,
      );
    }
    final dynamic resultado = await _connection.transaction(
      (Connection ctx) => _criarComConexao(
        sigla: sigla,
        descricao: descricao,
        ativo: ativo,
        codigoSei: codigoSei,
        conexao: ctx,
      ),
    );
    return resultado as Orgao;
  }

  Future<Orgao> _criarComConexao({
    required String sigla,
    required String descricao,
    required bool ativo,
    required String? codigoSei,
    required Connection conexao,
  }) async {
    final int idContato = await _contatoRepository.proximoId(
      connection: conexao,
    );
    final Contato contato = Contato(
      idContato: idContato,
      idContatoAssociado: idContato,
      tipoContato: TipoContato.orgaos,
      nome: descricao,
      natureza: NaturezaContato.juridica,
      ativo: ativo,
      sigla: sigla,
    );
    await _contatoRepository.inserir(contato, connection: conexao);

    final int idOrgao = await _orgaoRepository.proximoId(connection: conexao);
    final Orgao orgao = Orgao(
      idOrgao: idOrgao,
      idContato: idContato,
      sigla: sigla,
      descricao: descricao,
      ativo: ativo,
      codigoSei: codigoSei,
    );
    await _orgaoRepository.inserir(orgao, connection: conexao);

    return orgao;
  }

  Future<void> atualizarDadosCadastrais({
    required int idOrgao,
    required String sigla,
    required String descricao,
    required bool ativo,
    Connection? connection,
  }) async {
    // idContato é obrigatório no construtor, mas irrelevante aqui:
    // Orgao.toUpdateMap() não o inclui (ver Dartdoc do model).
    final Orgao dadosCadastrais = Orgao(
      idOrgao: idOrgao,
      idContato: 0,
      sigla: sigla,
      descricao: descricao,
      ativo: ativo,
    );
    await _orgaoRepository.atualizar(
      idOrgao,
      dadosCadastrais,
      connection: connection,
    );
  }
}
