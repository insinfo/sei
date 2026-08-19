import 'package:bcrypt/bcrypt.dart';
import 'package:eloquent/eloquent.dart';
import 'package:sei_backend/src/modules/orgaos/repositories/orgao_repository.dart';
import 'package:sei_backend/src/modules/usuarios/repositories/usuario_repository.dart';
import 'package:sei_backend/src/shared/repositories/contato_repository.dart';
import 'package:sei_core/sei_core.dart';

/// Orquestra a criação e a atualização de usuário: geração de próximo id,
/// hash de senha e a linha `contato` associada.
///
/// A criação grava `contato` e `usuario` na mesma transação: se o
/// `id_orgao` informado não existir, nada é gravado. Quando chamado sem
/// [Connection] explícita, abre a própria transação sobre a conexão
/// injetada; quando chamado com uma conexão já em transação (como o
/// `EscopoRepositorioTeste` dos testes), participa dela em vez de tentar
/// abrir uma transação aninhada.
class UsuarioService {
  UsuarioService(
    this._connection,
    this._usuarioRepository,
    this._contatoRepository,
    this._orgaoRepository,
  );

  final Connection _connection;
  final UsuarioRepository _usuarioRepository;
  final ContatoRepository _contatoRepository;
  final OrgaoRepository _orgaoRepository;

  /// Cria o usuário e o contato associado.
  ///
  /// Lança [ArgumentError] quando [idOrgao] não corresponde a um órgão
  /// existente.
  Future<Usuario> criar({
    required int idOrgao,
    required String sigla,
    required String nome,
    required String senha,
    bool ativo = true,
    Connection? connection,
  }) async {
    if (connection != null) {
      return _criarComConexao(
        idOrgao: idOrgao,
        sigla: sigla,
        nome: nome,
        senha: senha,
        ativo: ativo,
        conexao: connection,
      );
    }
    final dynamic resultado = await _connection.transaction(
      (Connection ctx) => _criarComConexao(
        idOrgao: idOrgao,
        sigla: sigla,
        nome: nome,
        senha: senha,
        ativo: ativo,
        conexao: ctx,
      ),
    );
    return resultado as Usuario;
  }

  Future<Usuario> _criarComConexao({
    required int idOrgao,
    required String sigla,
    required String nome,
    required String senha,
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
      tipoContato: TipoContato.usuarios,
      nome: nome,
      natureza: NaturezaContato.fisica,
      ativo: ativo,
      enderecoAssociado: true,
      sigla: sigla,
    );
    await _contatoRepository.inserir(contato, connection: conexao);

    final int idUsuario = await _usuarioRepository.proximoId(
      connection: conexao,
    );
    final String senhaHash = BCrypt.hashpw(senha, BCrypt.gensalt());
    final Usuario usuario = Usuario(
      idUsuario: idUsuario,
      idContato: idContato,
      idOrgao: idOrgao,
      sigla: sigla,
      nome: nome,
      ativo: ativo,
      idxUsuario: '${sigla.toLowerCase()} ${nome.toLowerCase()}',
      senhaHash: senhaHash,
    );
    await _usuarioRepository.inserir(usuario, connection: conexao);

    return usuario;
  }

  /// Atualiza dados cadastrais (nome, sigla, ativação). Nunca a senha.
  Future<void> atualizarDadosCadastrais({
    required int idUsuario,
    required String sigla,
    required String nome,
    required bool ativo,
    Connection? connection,
  }) async {
    // idContato/idOrgao são obrigatórios no construtor, mas irrelevantes
    // aqui: Usuario.toUpdateMap() não os inclui (ver Dartdoc do model).
    final Usuario dadosCadastrais = Usuario(
      idUsuario: idUsuario,
      idContato: 0,
      idOrgao: 0,
      sigla: sigla,
      nome: nome,
      ativo: ativo,
    );
    await _usuarioRepository.atualizar(
      idUsuario,
      dadosCadastrais,
      connection: connection,
    );
  }

  /// Gera o hash bcrypt de [senhaNova] e grava, sem tocar em outro campo.
  Future<void> trocarSenha({
    required int idUsuario,
    required String senhaNova,
    Connection? connection,
  }) async {
    final String hash = BCrypt.hashpw(senhaNova, BCrypt.gensalt());
    await _usuarioRepository.atualizarSenha(
      idUsuario,
      hash,
      connection: connection,
    );
  }
}
