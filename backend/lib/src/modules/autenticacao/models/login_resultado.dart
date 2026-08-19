/// Envelope de transporte da resposta de login bem-sucedido.
///
/// Não pertence ao `core` porque é um DTO de transporte exclusivo desta rota
/// (mesmo raciocínio de `RespostaErroApi`), sem uso como modelo de domínio.
class LoginResultado {
  const LoginResultado({
    required this.token,
    required this.idUsuario,
    required this.idOrgao,
    required this.siglaUsuario,
    required this.nomeUsuario,
  });

  static const String tokenCol = 'token';
  static const String idUsuarioCol = 'id_usuario';
  static const String idOrgaoCol = 'id_orgao';
  static const String siglaUsuarioCol = 'sigla_usuario';
  static const String nomeUsuarioCol = 'nome_usuario';

  final String token;
  final int idUsuario;
  final int idOrgao;
  final String siglaUsuario;
  final String nomeUsuario;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      tokenCol: token,
      idUsuarioCol: idUsuario,
      idOrgaoCol: idOrgao,
      siglaUsuarioCol: siglaUsuario,
      nomeUsuarioCol: nomeUsuario,
    };
  }
}

/// Erro de login com mensagem genérica, para não revelar qual campo falhou.
///
/// Cobre usuário inexistente, órgão inexistente, senha incorreta e usuário
/// ou órgão inativo — todos resultam na mesma mensagem, prática padrão de
/// segurança para não informar a um atacante qual dado estava errado.
class AutenticacaoInvalidaException implements Exception {
  const AutenticacaoInvalidaException();

  static const String mensagemGenerica = 'Usuário ou senha inválidos.';

  @override
  String toString() => mensagemGenerica;
}
