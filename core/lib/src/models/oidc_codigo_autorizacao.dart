import 'dart:math';
import 'dart:convert';

import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Código de autorização de uso único do fluxo `authorization_code` OIDC.
///
/// Emitido por `OidcController.emitirCodigoERedirecionar` após login local
/// bem-sucedido e trocado por `access_token`/`id_token` (e, quando o escopo
/// pedido inclui `offline_access`, `refresh_token`) em `POST /oauth2/token`.
/// A linha é apagada assim que trocada — ver [OidcCodigoAutorizacaoCol] no
/// repository — o que garante o uso único: uma segunda tentativa com o
/// mesmo código não encontra mais a linha.
///
/// Não faz parte do schema real do SEI/SIP: é infraestrutura própria deste
/// projeto para o backend atuar como Identity Provider OIDC.
class OidcCodigoAutorizacao extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'oidc_codigo_autorizacao';
  static const String fqtn = '$schemaName.$tableName';

  static const String valorCodigoCol = 'valor_codigo';
  static const String idClienteCol = 'id_cliente';
  static const String idUsuarioCol = 'id_usuario';
  static const String escoposCol = 'escopos';
  static const String uriRedirecionamentoCol = 'uri_redirecionamento';
  static const String dataExpiracaoCol = 'data_expiracao';
  static const String codeChallengeCol = 'code_challenge';
  static const String codeChallengeMethodCol = 'code_challenge_method';
  static const String nonceCol = 'nonce';
  static const String dataCadastroCol = 'data_cadastro';

  OidcCodigoAutorizacao({
    required this.valorCodigo,
    required this.idCliente,
    required this.idUsuario,
    required this.escopos,
    required this.uriRedirecionamento,
    required this.dataExpiracao,
    this.codeChallenge,
    this.codeChallengeMethod,
    this.nonce,
    DateTime? dataCadastro,
  }) : dataCadastro = dataCadastro ?? DateTime.now();

  /// Valor do código em si — chave primária, string opaca aleatória.
  final String valorCodigo;
  final String idCliente;
  final int idUsuario;
  final List<String> escopos;
  final String uriRedirecionamento;
  final DateTime dataExpiracao;

  /// Desafio PKCE (RFC 7636) informado no `authorize`. Nulo quando o
  /// cliente não usou PKCE (não deveria ocorrer para cliente público, mas
  /// o campo é opcional no modelo porque a obrigatoriedade é regra de
  /// negócio do controller, não do dado em si).
  final String? codeChallenge;

  /// Método do desafio PKCE — hoje só `S256` é aceito pelo provider.
  final String? codeChallengeMethod;

  /// Valor `nonce` do pedido original, repassado ao `id_token` emitido.
  final String? nonce;

  final DateTime dataCadastro;

  bool get expirado => DateTime.now().isAfter(dataExpiracao);

  /// Gera um valor de código aleatório e seguro.
  static String gerarValorCodigo({int tamanho = 40}) {
    final Random aleatorio = Random.secure();
    final List<int> valores = List<int>.generate(
      tamanho,
      (int _) => aleatorio.nextInt(256),
    );
    return base64Url.encode(valores).replaceAll('=', '');
  }

  factory OidcCodigoAutorizacao.fromMap(Map<String, dynamic> map) {
    return OidcCodigoAutorizacao(
      valorCodigo: map[valorCodigoCol] as String,
      idCliente: map[idClienteCol] as String,
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      escopos: List<String>.from(map[escoposCol] as List),
      uriRedirecionamento: map[uriRedirecionamentoCol] as String,
      dataExpiracao: SeiCoreUtils.dataHoraLocal(
        map[dataExpiracaoCol],
        nomeCampo: dataExpiracaoCol,
      ),
      codeChallenge: map[codeChallengeCol] as String?,
      codeChallengeMethod: map[codeChallengeMethodCol] as String?,
      nonce: map[nonceCol] as String?,
      dataCadastro: SeiCoreUtils.dataHoraLocal(
        map[dataCadastroCol],
        nomeCampo: dataCadastroCol,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      valorCodigoCol: valorCodigo,
      idClienteCol: idCliente,
      idUsuarioCol: idUsuario,
      escoposCol: escopos,
      uriRedirecionamentoCol: uriRedirecionamento,
      dataExpiracaoCol: dataExpiracao.toIso8601String(),
      codeChallengeCol: codeChallenge,
      codeChallengeMethodCol: codeChallengeMethod,
      nonceCol: nonce,
      dataCadastroCol: dataCadastro.toIso8601String(),
    };
  }

  /// `valor_codigo` é atribuído pela aplicação (ver [gerarValorCodigo]),
  /// então entra no mapa de inserção.
  ///
  /// As colunas de data usam [DateTime.toUtc] antes de gravar — ver o
  /// comentário equivalente em `OidcCliente.toInsertMap` para o motivo
  /// (driver grava `timestamp without time zone` sem conversão e devolve
  /// UTC na leitura; gravar em UTC alinha escrita e leitura).
  @override
  Map<String, dynamic> toInsertMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa[dataExpiracaoCol] = dataExpiracao.toUtc();
    mapa[dataCadastroCol] = dataCadastro.toUtc();
    return mapa;
  }

  /// Presente por contrato de [BaseModel]; nunca chamado em produção — um
  /// código de autorização é de uso único e o repository só o insere ou o
  /// apaga (`OidcCodigoAutorizacaoRepository.revogar`), nunca o atualiza.
  @override
  Map<String, dynamic> toUpdateMap() => toInsertMap();
}
