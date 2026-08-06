/// DTO interno que representa um erro JSON devolvido pelas rotas da API.
///
/// Não pertence ao pacote `core` porque é um envelope de transporte exclusivo
/// do backend, sem uso como modelo de domínio ou estado da interface.
class RespostaErroApi {
  const RespostaErroApi(this.mensagem);

  static const String erroCol = 'erro';
  static const String mensagemCol = 'mensagem';

  final String mensagem;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      erroCol: true,
      mensagemCol: mensagem,
    };
  }
}
