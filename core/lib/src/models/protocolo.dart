import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/estado_protocolo.dart';
import 'package:sei_core/src/models/tipo_protocolo.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Identidade comum de processos e documentos do SEI, gravável em `protocolo`.
///
/// É o hub do núcleo processual: `procedimento` e `documento` especializam a
/// mesma linha, e o NUP, o nível de acesso e o estado moram aqui. Diferente
/// das projeções de leitura, esta entidade escreve na tabela e por isso
/// implementa [toInsertMap] e [toUpdateMap].
///
/// O identificador é atribuído pela aplicação, e não por sequência do banco:
/// a coluna `id_protocolo` não possui `DEFAULT` na Base de Referência. Por
/// isso ele participa de [toInsertMap] e é obrigatório na construção.
class Protocolo extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'protocolo';
  static const String fqtn = '$schemaName.$tableName';

  static const String idProtocoloCol = 'id_protocolo';
  static const String idProtocoloFqCol = '$fqtn.$idProtocoloCol';
  static const String idUnidadeGeradoraCol = 'id_unidade_geradora';
  static const String idUnidadeGeradoraFqCol = '$fqtn.$idUnidadeGeradoraCol';
  static const String idUsuarioGeradorCol = 'id_usuario_gerador';
  static const String idUsuarioGeradorFqCol = '$fqtn.$idUsuarioGeradorCol';
  static const String idProtocoloAgrupadorCol = 'id_protocolo_agrupador';
  static const String idProtocoloAgrupadorFqCol =
      '$fqtn.$idProtocoloAgrupadorCol';
  static const String idHipoteseLegalCol = 'id_hipotese_legal';
  static const String idHipoteseLegalFqCol = '$fqtn.$idHipoteseLegalCol';
  static const String protocoloFormatadoCol = 'protocolo_formatado';
  static const String protocoloFormatadoFqCol = '$fqtn.$protocoloFormatadoCol';
  static const String tipoProtocoloCol = 'sta_protocolo';
  static const String tipoProtocoloFqCol = '$fqtn.$tipoProtocoloCol';
  static const String dataGeracaoCol = 'dta_geracao';
  static const String dataGeracaoFqCol = '$fqtn.$dataGeracaoCol';
  static const String estadoCol = 'sta_estado';
  static const String estadoFqCol = '$fqtn.$estadoCol';
  static const String descricaoCol = 'descricao';
  static const String descricaoFqCol = '$fqtn.$descricaoCol';
  static const String nivelAcessoLocalCol = 'sta_nivel_acesso_local';
  static const String nivelAcessoLocalFqCol = '$fqtn.$nivelAcessoLocalCol';
  static const String nivelAcessoGlobalCol = 'sta_nivel_acesso_global';
  static const String nivelAcessoGlobalFqCol = '$fqtn.$nivelAcessoGlobalCol';
  static const String protocoloFormatadoPesquisaCol =
      'protocolo_formatado_pesquisa';
  static const String protocoloFormatadoPesquisaFqCol =
      '$fqtn.$protocoloFormatadoPesquisaCol';
  static const String protocoloFormatadoPesqInvCol =
      'protocolo_formatado_pesq_inv';
  static const String protocoloFormatadoPesqInvFqCol =
      '$fqtn.$protocoloFormatadoPesqInvCol';
  static const String codigoBarrasCol = 'codigo_barras';
  static const String codigoBarrasFqCol = '$fqtn.$codigoBarrasCol';
  static const String grauSigiloCol = 'sta_grau_sigilo';
  static const String grauSigiloFqCol = '$fqtn.$grauSigiloCol';
  static const String nivelAcessoOriginalCol = 'sta_nivel_acesso_original';
  static const String nivelAcessoOriginalFqCol =
      '$fqtn.$nivelAcessoOriginalCol';
  static const String dataInclusaoCol = 'dta_inclusao';
  static const String dataInclusaoFqCol = '$fqtn.$dataInclusaoCol';
  static const String idProtocoloFederacaoCol = 'id_protocolo_federacao';
  static const String idProtocoloFederacaoFqCol =
      '$fqtn.$idProtocoloFederacaoCol';
  static const String eliminadoCol = 'sin_eliminado';
  static const String eliminadoFqCol = '$fqtn.$eliminadoCol';

  Protocolo({
    required this.idProtocolo,
    required this.idUnidadeGeradora,
    required this.idUsuarioGerador,
    required this.protocoloFormatado,
    required this.tipoProtocolo,
    required this.dataGeracao,
    required this.dataInclusao,
    this.idProtocoloAgrupador,
    this.estado = EstadoProtocolo.normal,
    this.nivelAcessoLocal = nivelAcessoPublico,
    this.nivelAcessoGlobal = nivelAcessoPublico,
    this.eliminado = false,
    this.descricao,
    this.idHipoteseLegal,
    this.codigoBarras,
    this.grauSigilo,
    this.nivelAcessoOriginal,
    this.idProtocoloFederacao,
    String? protocoloFormatadoPesquisa,
    String? protocoloFormatadoPesqInv,
  })  : protocoloFormatadoPesquisa =
            protocoloFormatadoPesquisa ?? somenteDigitos(protocoloFormatado),
        protocoloFormatadoPesqInv = protocoloFormatadoPesqInv ??
            inverter(somenteDigitos(protocoloFormatado));

  factory Protocolo.fromMap(Map<String, dynamic> map) {
    return Protocolo(
      idProtocolo: SeiCoreUtils.inteiro(
        map[idProtocoloCol],
        nomeCampo: idProtocoloCol,
      ),
      idUnidadeGeradora: SeiCoreUtils.inteiro(
        map[idUnidadeGeradoraCol],
        nomeCampo: idUnidadeGeradoraCol,
      ),
      idUsuarioGerador: SeiCoreUtils.inteiro(
        map[idUsuarioGeradorCol],
        nomeCampo: idUsuarioGeradorCol,
      ),
      idProtocoloAgrupador: map[idProtocoloAgrupadorCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idProtocoloAgrupadorCol],
              nomeCampo: idProtocoloAgrupadorCol,
            ),
      idHipoteseLegal: map[idHipoteseLegalCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idHipoteseLegalCol],
              nomeCampo: idHipoteseLegalCol,
            ),
      protocoloFormatado: map[protocoloFormatadoCol] as String,
      protocoloFormatadoPesquisa: map[protocoloFormatadoPesquisaCol] as String?,
      protocoloFormatadoPesqInv: map[protocoloFormatadoPesqInvCol] as String?,
      tipoProtocolo: TipoProtocolo.fromValue(map[tipoProtocoloCol] as String),
      dataGeracao: SeiCoreUtils.dataHoraLocal(
        map[dataGeracaoCol],
        nomeCampo: dataGeracaoCol,
      ),
      dataInclusao: SeiCoreUtils.dataHoraLocal(
        map[dataInclusaoCol],
        nomeCampo: dataInclusaoCol,
      ),
      estado: EstadoProtocolo.fromValueOrNull(map[estadoCol] as String) ??
          EstadoProtocolo.normal,
      descricao: map[descricaoCol] as String?,
      nivelAcessoLocal: (map[nivelAcessoLocalCol] as String).trim(),
      nivelAcessoGlobal: (map[nivelAcessoGlobalCol] as String).trim(),
      codigoBarras: map[codigoBarrasCol] as String?,
      grauSigilo: (map[grauSigiloCol] as String?)?.trim(),
      nivelAcessoOriginal: (map[nivelAcessoOriginalCol] as String?)?.trim(),
      idProtocoloFederacao: map[idProtocoloFederacaoCol] as String?,
      eliminado: SeiCoreUtils.simNaoParaBool(
        (map[eliminadoCol] as String).trim(),
        nomeCampo: eliminadoCol,
      ),
    );
  }

  /// Código de nível de acesso público em `sta_nivel_acesso_local` e
  /// `sta_nivel_acesso_global`.
  ///
  /// É o único dos três níveis comprovado pelo corpus local: ele responde por
  /// 1.228 dos 1.481 protocolos do dump histórico e é o padrão de autuação
  /// descrito no manual. Restrito e sigiloso possuem códigos próprios que as
  /// fontes locais não permitem distinguir, e por isso não são declarados.
  static const String nivelAcessoPublico = '0';

  /// Identificador do protocolo, atribuído pela aplicação.
  final int idProtocolo;
  final int idUnidadeGeradora;
  final int idUsuarioGerador;

  /// Protocolo que agrupa o documento dentro do processo; para o próprio
  /// processo o SEI grava o seu identificador.
  final int? idProtocoloAgrupador;
  final int? idHipoteseLegal;

  /// NUP formatado, como exibido na árvore e no Controle de Processos.
  final String protocoloFormatado;

  /// Forma normalizada usada pela pesquisa por número.
  final String protocoloFormatadoPesquisa;

  /// Forma normalizada e invertida usada pela pesquisa por sufixo.
  final String protocoloFormatadoPesqInv;

  final TipoProtocolo tipoProtocolo;
  final DateTime dataGeracao;
  final DateTime dataInclusao;
  final EstadoProtocolo estado;
  final String? descricao;
  final String nivelAcessoLocal;
  final String nivelAcessoGlobal;
  final String? codigoBarras;
  final String? grauSigilo;
  final String? nivelAcessoOriginal;
  final String? idProtocoloFederacao;
  final bool eliminado;

  /// Remove tudo que não for dígito, como exige a coluna de pesquisa.
  static String somenteDigitos(String valor) {
    return valor.replaceAll(RegExp('[^0-9]'), '');
  }

  /// Inverte a cadeia, como exige a coluna de pesquisa por sufixo.
  static String inverter(String valor) {
    return String.fromCharCodes(valor.runes.toList().reversed);
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idProtocoloCol: idProtocolo,
      idUnidadeGeradoraCol: idUnidadeGeradora,
      idUsuarioGeradorCol: idUsuarioGerador,
      idProtocoloAgrupadorCol: idProtocoloAgrupador ?? idProtocolo,
      idHipoteseLegalCol: idHipoteseLegal,
      protocoloFormatadoCol: protocoloFormatado,
      protocoloFormatadoPesquisaCol: protocoloFormatadoPesquisa,
      protocoloFormatadoPesqInvCol: protocoloFormatadoPesqInv,
      tipoProtocoloCol: tipoProtocolo.valor,
      dataGeracaoCol: dataGeracao,
      dataInclusaoCol: dataInclusao,
      estadoCol: estado.valor,
      descricaoCol: descricao,
      nivelAcessoLocalCol: nivelAcessoLocal,
      nivelAcessoGlobalCol: nivelAcessoGlobal,
      codigoBarrasCol: codigoBarras,
      grauSigiloCol: grauSigilo,
      nivelAcessoOriginalCol: nivelAcessoOriginal,
      idProtocoloFederacaoCol: idProtocoloFederacao,
      eliminadoCol: SeiCoreUtils.boolParaSimNao(eliminado),
    };
  }

  /// Mapa de inserção com todas as colunas, inclusive a chave.
  ///
  /// A chave permanece porque o SEI atribui o identificador na aplicação; a
  /// coluna não tem `DEFAULT` no banco.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade, que pertence ao filtro.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idProtocoloCol);
    return mapa;
  }
}
