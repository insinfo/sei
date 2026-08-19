import 'dart:convert';
import 'dart:math';

import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Refresh token do provider OIDC do SEI, emitido quando o escopo concedido
/// inclui `offline_access`.
///
/// Cada renovação (`grant_type=refresh_token` em `POST /oauth2/token`)
/// revoga o token usado e emite um novo (rotação), reduzindo o risco de um
/// valor roubado continuar utilizável indefinidamente.
///
/// Não faz parte do schema real do SEI/SIP: é infraestrutura própria deste
/// projeto para o backend atuar como Identity Provider OIDC.
class OidcTokenRenovacao extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'oidc_token_renovacao';
  static const String fqtn = '$schemaName.$tableName';

  static const String valorTokenCol = 'valor_token';
  static const String idClienteCol = 'id_cliente';
  static const String idUsuarioCol = 'id_usuario';
  static const String escoposCol = 'escopos';
  static const String dataExpiracaoCol = 'data_expiracao';
  static const String dataCadastroCol = 'data_cadastro';
  static const String revogadoCol = 'revogado';

  OidcTokenRenovacao({
    required this.valorToken,
    required this.idCliente,
    required this.idUsuario,
    required this.escopos,
    required this.dataExpiracao,
    DateTime? dataCadastro,
    this.revogado = false,
  }) : dataCadastro = dataCadastro ?? DateTime.now();

  /// Valor do token em si — chave primária, string opaca aleatória.
  final String valorToken;
  final String idCliente;
  final int idUsuario;
  final List<String> escopos;
  final DateTime dataExpiracao;
  final DateTime dataCadastro;

  /// `true` quando o token já foi trocado por um novo par (rotação) ou
  /// revogado explicitamente; um token revogado nunca é aceito de novo.
  bool revogado;

  bool get expirado => DateTime.now().isAfter(dataExpiracao);

  /// Gera um valor de refresh token aleatório e seguro.
  static String gerarValorToken({int tamanho = 64}) {
    final Random aleatorio = Random.secure();
    final List<int> valores = List<int>.generate(
      tamanho,
      (int _) => aleatorio.nextInt(256),
    );
    return base64Url.encode(valores).replaceAll('=', '');
  }

  factory OidcTokenRenovacao.fromMap(Map<String, dynamic> map) {
    return OidcTokenRenovacao(
      valorToken: map[valorTokenCol] as String,
      idCliente: map[idClienteCol] as String,
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      escopos: List<String>.from(map[escoposCol] as List),
      dataExpiracao: SeiCoreUtils.dataHoraLocal(
        map[dataExpiracaoCol],
        nomeCampo: dataExpiracaoCol,
      ),
      dataCadastro: SeiCoreUtils.dataHoraLocal(
        map[dataCadastroCol],
        nomeCampo: dataCadastroCol,
      ),
      revogado: map[revogadoCol] as bool,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      valorTokenCol: valorToken,
      idClienteCol: idCliente,
      idUsuarioCol: idUsuario,
      escoposCol: escopos,
      dataExpiracaoCol: dataExpiracao.toIso8601String(),
      dataCadastroCol: dataCadastro.toIso8601String(),
      revogadoCol: revogado,
    };
  }

  /// `valor_token` é atribuído pela aplicação (ver [gerarValorToken]), então
  /// entra no mapa de inserção.
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

  /// Só a coluna [revogadoCol] muda depois da inserção — ver
  /// `OidcTokenRenovacaoRepository.revogar`.
  @override
  Map<String, dynamic> toUpdateMap() {
    return <String, dynamic>{revogadoCol: revogado};
  }
}
