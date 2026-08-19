import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Tipo de aplicação cliente (Relying Party) registrada no provider OIDC.
///
/// Determina se PKCE é obrigatório e se um `client_secret` é esperado no
/// endpoint de token: [webSpa] e [aplicativoNativo] são clientes públicos
/// (sem segredo, autenticam só com PKCE); [backendConfidencial] é um
/// cliente que roda em servidor e pode guardar um segredo com segurança.
enum TipoAplicacaoOidc {
  webSpa('web_spa'),
  backendConfidencial('backend_confidencial'),
  aplicativoNativo('aplicativo_nativo');

  const TipoAplicacaoOidc(this.valor);

  /// Valor persistido em `oidc_cliente.tipo_aplicacao`.
  final String valor;

  static TipoAplicacaoOidc fromValue(String valor) {
    for (final TipoAplicacaoOidc tipo in TipoAplicacaoOidc.values) {
      if (tipo.valor == valor) {
        return tipo;
      }
    }
    throw FormatException('Tipo de aplicação OIDC desconhecido: $valor.');
  }
}

/// Cliente (Relying Party) registrado no provider OpenID Connect do SEI.
///
/// Esta tabela não faz parte do schema real do SEI/SIP restaurado: é
/// infraestrutura própria deste projeto para o backend atuar como Identity
/// Provider OIDC de outros sistemas — o mesmo papel que o SIP desempenha no
/// SEI verdadeiro como serviço de autorização compartilhado por múltiplos
/// sistemas de uma instituição. O primeiro cliente registrado é o próprio
/// frontend AngularDart do SEI, como aplicação `webSpa` sem segredo, usando
/// PKCE.
class OidcCliente extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'oidc_cliente';
  static const String fqtn = '$schemaName.$tableName';

  static const String idClienteCol = 'id_cliente';
  static const String hashSegredoCol = 'hash_segredo';
  static const String nomeCol = 'nome';
  static const String urisRedirecionamentoCol = 'uris_redirecionamento';
  static const String escoposPermitidosCol = 'escopos_permitidos';
  static const String tipoAplicacaoCol = 'tipo_aplicacao';
  static const String urisRedirecionamentoPosLogoutCol =
      'uris_redirecionamento_pos_logout';
  static const String tiposConcessaoSuportadosCol =
      'tipos_concessao_suportados';
  static const String tiposRespostaSuportadosCol = 'tipos_resposta_suportados';
  static const String metodoAutenticacaoTokenEndpointCol =
      'metodo_autenticacao_token_endpoint';
  static const String ativoCol = 'ativo';
  static const String dataCadastroCol = 'data_cadastro';
  static const String dataAtualizacaoCol = 'data_atualizacao';

  OidcCliente({
    required this.idCliente,
    required this.nome,
    required this.urisRedirecionamento,
    required this.escoposPermitidos,
    required this.tipoAplicacao,
    required this.dataCadastro,
    this.hashSegredo,
    List<String>? urisRedirecionamentoPosLogout,
    List<String>? tiposConcessaoSuportados,
    List<String>? tiposRespostaSuportados,
    String? metodoAutenticacaoTokenEndpoint,
    this.ativo = true,
    this.dataAtualizacao,
  })  : urisRedirecionamentoPosLogout =
            urisRedirecionamentoPosLogout ?? const <String>[],
        tiposConcessaoSuportados = tiposConcessaoSuportados ??
            const <String>['authorization_code', 'refresh_token'],
        tiposRespostaSuportados =
            tiposRespostaSuportados ?? const <String>['code'],
        metodoAutenticacaoTokenEndpoint = metodoAutenticacaoTokenEndpoint ??
            (tipoAplicacao == TipoAplicacaoOidc.backendConfidencial
                ? 'client_secret_post'
                : 'none');

  /// Identificador do cliente (chave primária, string opaca gerada pela
  /// aplicação, nunca pelo banco — ver [gerarIdCliente]).
  final String idCliente;

  /// Hash do segredo do cliente, presente apenas para clientes
  /// [TipoAplicacaoOidc.backendConfidencial]. Nulo para clientes públicos
  /// (`webSpa`/`aplicativoNativo`), que autenticam só com PKCE.
  String? hashSegredo;

  /// Nome legível exibido na tela de login e em telas administrativas.
  String nome;

  /// URIs de redirecionamento permitidas para o retorno do código de
  /// autorização. O servidor só redireciona para uma URI presente aqui
  /// (igualdade exata, sem coringa).
  List<String> urisRedirecionamento;

  /// Escopos que este cliente pode solicitar no `authorize`. Um escopo
  /// pedido fora desta lista é descartado na concessão, nunca negado com
  /// erro — ver `OidcController.authorize`.
  List<String> escoposPermitidos;

  /// Tipo de aplicação — define exigência de PKCE e de segredo.
  TipoAplicacaoOidc tipoAplicacao;

  /// URIs para onde o navegador pode ser redirecionado após logout.
  List<String> urisRedirecionamentoPosLogout;

  /// Grant types que este cliente pode usar no endpoint de token.
  List<String> tiposConcessaoSuportados;

  /// Response types que este cliente pode usar no endpoint de autorização.
  List<String> tiposRespostaSuportados;

  /// Método de autenticação do cliente no endpoint de token (`none`,
  /// `client_secret_post`, `client_secret_basic` — nomenclatura do RFC
  /// 6749/OIDC, mantida em inglês por ser valor de protocolo, não de
  /// domínio de negócio do SEI).
  String metodoAutenticacaoTokenEndpoint;

  /// Indica se o cliente pode autenticar. Cliente inativo é tratado como
  /// desconhecido pelo provider.
  bool ativo;

  final DateTime dataCadastro;
  DateTime? dataAtualizacao;

  /// Gera um identificador de cliente aleatório e seguro (base64url, sem
  /// padding). Mesma ideia de `OidcClient.generateClientId` do projeto de
  /// referência `new_sali`.
  static String gerarIdCliente({int tamanho = 32}) {
    final Random aleatorio = Random.secure();
    final List<int> valores = List<int>.generate(
      tamanho,
      (int _) => aleatorio.nextInt(256),
    );
    return base64Url.encode(valores).replaceAll('=', '');
  }

  /// Gera um segredo de cliente aleatório e seguro, em texto puro, para uso
  /// único no momento do cadastro de um cliente confidencial — quem chama
  /// deve gravar apenas o hash ([hashDoSegredo]) e nunca o valor bruto.
  static String gerarSegredoCliente({int tamanho = 48}) {
    final Random aleatorio = Random.secure();
    final List<int> valores = List<int>.generate(
      tamanho,
      (int _) => aleatorio.nextInt(256),
    );
    return base64Url.encode(valores).replaceAll('=', '');
  }

  /// Calcula o hash gravável de um segredo de cliente.
  ///
  /// Usa SHA-256, suficiente para um segredo aleatório de alta entropia
  /// (diferente de senha de usuário, que sofre de baixa entropia e por
  /// isso usa bcrypt em `AutenticacaoService`). Nenhum cliente
  /// `backendConfidencial` foi registrado ainda nesta rodada — este método
  /// existe para quando um cliente desse tipo for cadastrado.
  static String hashDoSegredo(String segredo) {
    return sha256.convert(utf8.encode(segredo)).toString();
  }

  /// Verifica um segredo em texto puro contra o hash gravado.
  ///
  /// Cliente público (sem [hashSegredo]) sempre passa: a autenticação dele
  /// é feita por PKCE, não por segredo.
  static bool verificarSegredo(String? segredo, String? hash) {
    if (hash == null || hash.isEmpty) {
      return true;
    }
    if (segredo == null || segredo.isEmpty) {
      return false;
    }
    return hashDoSegredo(segredo) == hash;
  }

  factory OidcCliente.fromMap(Map<String, dynamic> map) {
    return OidcCliente(
      idCliente: map[idClienteCol] as String,
      hashSegredo: map[hashSegredoCol] as String?,
      nome: map[nomeCol] as String,
      urisRedirecionamento:
          List<String>.from(map[urisRedirecionamentoCol] as List),
      escoposPermitidos: List<String>.from(map[escoposPermitidosCol] as List),
      tipoAplicacao:
          TipoAplicacaoOidc.fromValue(map[tipoAplicacaoCol] as String),
      urisRedirecionamentoPosLogout: List<String>.from(
        (map[urisRedirecionamentoPosLogoutCol] as List?) ?? const <Object>[],
      ),
      tiposConcessaoSuportados: List<String>.from(
        (map[tiposConcessaoSuportadosCol] as List?) ?? const <Object>[],
      ),
      tiposRespostaSuportados: List<String>.from(
        (map[tiposRespostaSuportadosCol] as List?) ?? const <Object>[],
      ),
      metodoAutenticacaoTokenEndpoint:
          map[metodoAutenticacaoTokenEndpointCol] as String?,
      ativo: map[ativoCol] as bool,
      dataCadastro: SeiCoreUtils.dataHoraLocal(
        map[dataCadastroCol],
        nomeCampo: dataCadastroCol,
      ),
      dataAtualizacao: map[dataAtualizacaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[dataAtualizacaoCol],
              nomeCampo: dataAtualizacaoCol,
            ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idClienteCol: idCliente,
      hashSegredoCol: hashSegredo,
      nomeCol: nome,
      urisRedirecionamentoCol: urisRedirecionamento,
      escoposPermitidosCol: escoposPermitidos,
      tipoAplicacaoCol: tipoAplicacao.valor,
      urisRedirecionamentoPosLogoutCol: urisRedirecionamentoPosLogout,
      tiposConcessaoSuportadosCol: tiposConcessaoSuportados,
      tiposRespostaSuportadosCol: tiposRespostaSuportados,
      metodoAutenticacaoTokenEndpointCol: metodoAutenticacaoTokenEndpoint,
      ativoCol: ativo,
      dataCadastroCol: dataCadastro.toIso8601String(),
      dataAtualizacaoCol: dataAtualizacao?.toIso8601String(),
    };
  }

  /// `id_cliente` é atribuído pela aplicação (ver [gerarIdCliente]), então
  /// entra no mapa de inserção — diferente de uma PK sequencial, que o
  /// banco geraria sozinho.
  ///
  /// As colunas de data usam [DateTime.toUtc] antes de gravar: o driver
  /// grava os dígitos recebidos literalmente em `timestamp without time
  /// zone` e, na leitura, devolve um `DateTime` marcado UTC com esses
  /// mesmos dígitos — sem essa normalização, gravar `DateTime.now()` (hora
  /// local) e comparar depois com `DateTime.now()` de novo compararia
  /// instantes reais diferentes (defasagem do fuso, aqui 3h). Gravar em
  /// UTC alinha escrita e leitura.
  @override
  Map<String, dynamic> toInsertMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa[dataCadastroCol] = dataCadastro.toUtc();
    mapa.remove(dataAtualizacaoCol);
    return mapa;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa[dataAtualizacaoCol] = (dataAtualizacao ?? DateTime.now()).toUtc();
    mapa.remove(idClienteCol);
    mapa.remove(dataCadastroCol);
    return mapa;
  }
}
