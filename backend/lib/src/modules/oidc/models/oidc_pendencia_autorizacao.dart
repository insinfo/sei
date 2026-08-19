/// Requisição de autorização OIDC pendente, guardada na sessão HTTP entre
/// `GET /oauth2/authorize` e a submissão de `POST /login`.
///
/// Não pertence ao `core` porque é um dado interno e transitório do
/// backend (nunca serializado para o cliente nem persistido em tabela) —
/// mesmo raciocínio de `UsuarioAutenticado`. Vive só na sessão HTTP nativa
/// do Angel (`request.session`, backada por `dart:io.HttpSession` em
/// produção e por um mapa em memória nos testes), processo único — não há
/// hoje suporte a múltiplas instâncias do backend compartilhando sessão.
class OidcPendenciaAutorizacao {
  const OidcPendenciaAutorizacao({
    required this.idCliente,
    required this.uriRedirecionamento,
    required this.escopos,
    this.state,
    this.nonce,
    this.codeChallenge,
    this.codeChallengeMethod,
  });

  final String idCliente;
  final String uriRedirecionamento;
  final List<String> escopos;
  final String? state;
  final String? nonce;
  final String? codeChallenge;
  final String? codeChallengeMethod;
}
