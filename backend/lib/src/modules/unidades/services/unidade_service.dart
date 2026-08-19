import 'package:eloquent/eloquent.dart';
import 'package:sei_backend/src/modules/orgaos/repositories/orgao_repository.dart';
import 'package:sei_backend/src/modules/unidades/repositories/unidade_repository.dart';
import 'package:sei_backend/src/shared/repositories/contato_repository.dart';
import 'package:sei_core/sei_core.dart';

/// Orquestra a criação e a atualização de unidade: geração de próximo id e
/// o `contato` associado.
///
/// Mesma estratégia de transação de `UsuarioService`: quando chamado sem
/// [Connection] explícita, abre a própria transação; quando chamado com uma
/// conexão já em transação (testes), participa dela.
class UnidadeService {
  UnidadeService(
    this._connection,
    this._unidadeRepository,
    this._contatoRepository,
    this._orgaoRepository,
  );

  final Connection _connection;
  final UnidadeRepository _unidadeRepository;
  final ContatoRepository _contatoRepository;
  final OrgaoRepository _orgaoRepository;

  /// Cria a unidade e o contato associado.
  ///
  /// Lança [ArgumentError] quando [idOrgao] não corresponde a um órgão
  /// existente.
  Future<Unidade> criar({
    required int idOrgao,
    required String sigla,
    required String descricao,
    bool ativo = true,
    Connection? connection,
  }) async {
    if (connection != null) {
      return _criarComConexao(
        idOrgao: idOrgao,
        sigla: sigla,
        descricao: descricao,
        ativo: ativo,
        conexao: connection,
      );
    }
    final dynamic resultado = await _connection.transaction(
      (Connection ctx) => _criarComConexao(
        idOrgao: idOrgao,
        sigla: sigla,
        descricao: descricao,
        ativo: ativo,
        conexao: ctx,
      ),
    );
    return resultado as Unidade;
  }

  Future<Unidade> _criarComConexao({
    required int idOrgao,
    required String sigla,
    required String descricao,
    required bool ativo,
    required Connection conexao,
  }) async {
    final Orgao? orgao = await _orgaoRepository.buscarPorId(
      idOrgao,
      connection: conexao,
    );
    if (orgao == null) {
      throw ArgumentError.value(
        idOrgao,
        'idOrgao',
        'Não existe órgão com este identificador.',
      );
    }

    final int idContato = await _contatoRepository.proximoId(
      connection: conexao,
    );
    final Contato contato = Contato(
      idContato: idContato,
      idContatoAssociado: orgao.idContato,
      tipoContato: TipoContato.unidades,
      nome: descricao,
      natureza: NaturezaContato.juridica,
      ativo: ativo,
      sigla: sigla,
    );
    await _contatoRepository.inserir(contato, connection: conexao);

    final int idUnidade = await _unidadeRepository.proximoId(
      connection: conexao,
    );
    final Unidade unidade = Unidade(
      idUnidade: idUnidade,
      idOrgao: idOrgao,
      idContato: idContato,
      sigla: sigla,
      descricao: descricao,
      ativo: ativo,
    );
    await _unidadeRepository.inserir(unidade, connection: conexao);

    return unidade;
  }

  Future<void> atualizarDadosCadastrais({
    required int idUnidade,
    required String sigla,
    required String descricao,
    required bool ativo,
    Connection? connection,
  }) async {
    // idOrgao/idContato são obrigatórios no construtor, mas irrelevantes
    // aqui: Unidade.toUpdateMap() não os inclui (ver Dartdoc do model).
    final Unidade dadosCadastrais = Unidade(
      idUnidade: idUnidade,
      idOrgao: 0,
      idContato: 0,
      sigla: sigla,
      descricao: descricao,
      ativo: ativo,
    );
    await _unidadeRepository.atualizar(
      idUnidade,
      dadosCadastrais,
      connection: connection,
    );
  }
}
