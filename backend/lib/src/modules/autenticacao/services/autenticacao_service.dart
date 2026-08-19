import 'package:bcrypt/bcrypt.dart';
import 'package:sei_backend/src/modules/autenticacao/models/login_resultado.dart';
import 'package:sei_backend/src/modules/autenticacao/repositories/autenticacao_repository.dart';
import 'package:sei_backend/src/modules/autenticacao/services/autenticacao_token_service.dart';
import 'package:sei_backend/src/modules/orgaos/repositories/orgao_repository.dart';
import 'package:sei_core/sei_core.dart';

/// Orquestra o login local do SEI: resolve o órgão pela sigla, busca o
/// usuário ativo naquele órgão, verifica a senha com bcrypt e emite o JWT.
///
/// Autenticação é local (`sei_5_0_0.usuario.senha`, hash bcrypt) — LDAP/AD é
/// integração opcional por órgão, fora de escopo aqui (ver
/// `backend/docs/evidencias_processo_detalhe.md`). Nenhuma escrita é feita
/// aqui: não é gravada auditoria de login em `sip_5_0_0.login`, pendência
/// documentada no roteiro mestre.
class AutenticacaoService {
  AutenticacaoService(
    this._orgaoRepository,
    this._autenticacaoRepository,
    this._tokenService,
  );

  final OrgaoRepository _orgaoRepository;
  final AutenticacaoRepository _autenticacaoRepository;
  final AutenticacaoTokenService _tokenService;

  /// Nome das claims do JWT emitido pelo login.
  static const String claimIdUsuario = 'id_usuario';
  static const String claimIdOrgao = 'id_orgao';
  static const String claimSigla = 'sigla';
  static const String claimNome = 'nome';

  /// Valida usuário, senha e órgão e emite o token de sessão.
  ///
  /// Lança [AutenticacaoInvalidaException] com mensagem genérica para
  /// qualquer motivo de falha (usuário inexistente, órgão inexistente,
  /// senha incorreta, usuário ou órgão inativo), para nunca revelar ao
  /// cliente qual campo especificamente estava errado.
  Future<LoginResultado> login({
    required String usuario,
    required String senha,
    required String siglaOrgao,
  }) async {
    final Orgao? orgao = await _orgaoRepository.buscarPorSigla(siglaOrgao);
    if (orgao == null || !orgao.ativo) {
      throw const AutenticacaoInvalidaException();
    }

    final Usuario? usuarioEncontrado = await _autenticacaoRepository
        .buscarUsuarioParaLogin(usuario, orgao.idOrgao);
    if (usuarioEncontrado == null) {
      throw const AutenticacaoInvalidaException();
    }

    final String? hash = usuarioEncontrado.senhaHash;
    if (hash == null || hash.isEmpty || !BCrypt.checkpw(senha, hash)) {
      throw const AutenticacaoInvalidaException();
    }

    final String token = _tokenService.emitir(<String, dynamic>{
      claimIdUsuario: usuarioEncontrado.idUsuario,
      claimIdOrgao: usuarioEncontrado.idOrgao,
      claimSigla: usuarioEncontrado.sigla,
      claimNome: usuarioEncontrado.nome,
    });

    return LoginResultado(
      token: token,
      idUsuario: usuarioEncontrado.idUsuario,
      idOrgao: usuarioEncontrado.idOrgao,
      siglaUsuario: usuarioEncontrado.sigla,
      nomeUsuario: usuarioEncontrado.nome,
    );
  }

  /// Órgãos ativos para o seletor da tela de login.
  Future<List<OrgaoLoginResumo>> listarOrgaosAtivos() {
    return _orgaoRepository.listarAtivosParaLogin();
  }
}
