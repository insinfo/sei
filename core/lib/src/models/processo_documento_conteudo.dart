import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/estado_documento.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Conteúdo de um documento, interno ou externo, para exibição na tela.
///
/// Projeção somente leitura que une `documento` a `documento_conteudo`
/// (quando [estado] é [EstadoDocumento.interno]) ou a `anexo` (quando é
/// [EstadoDocumento.externo]). Só um dos dois grupos de campos vem
/// preenchido; qual deles depende de [estado], nunca dos dois ao mesmo tempo.
///
/// A escrita usa as entidades [Documento], [DocumentoConteudo] e [Anexo]
/// diretamente, nunca esta projeção.
class ProcessoDocumentoConteudo extends BaseModel {
  static const String schemaName = 'public';

  static const String documentoFqtn = '$schemaName.documento';
  static const String protocoloFqtn = '$schemaName.protocolo';
  static const String conteudoFqtn = '$schemaName.documento_conteudo';
  static const String anexoFqtn = '$schemaName.anexo';

  static const String documentoIdSourceCol = 'id_documento';
  static const String documentoIdFqCol = '$documentoFqtn.$documentoIdSourceCol';
  static const String documentoIdProcedimentoSourceCol = 'id_procedimento';
  static const String documentoIdProcedimentoFqCol =
      '$documentoFqtn.$documentoIdProcedimentoSourceCol';
  static const String documentoEstadoSourceCol = 'sta_documento';
  static const String documentoEstadoFqCol =
      '$documentoFqtn.$documentoEstadoSourceCol';
  static const String documentoBloqueadoSourceCol = 'sin_bloqueado';
  static const String documentoBloqueadoFqCol =
      '$documentoFqtn.$documentoBloqueadoSourceCol';
  static const String documentoVersoesSourceCol = 'sin_versoes';
  static const String documentoVersoesFqCol =
      '$documentoFqtn.$documentoVersoesSourceCol';

  static const String protocoloIdSourceCol = 'id_protocolo';
  static const String protocoloIdFqCol = '$protocoloFqtn.$protocoloIdSourceCol';

  static const String conteudoIdDocumentoSourceCol = 'id_documento';
  static const String conteudoIdDocumentoFqCol =
      '$conteudoFqtn.$conteudoIdDocumentoSourceCol';
  static const String conteudoConteudoSourceCol = 'conteudo';
  static const String conteudoConteudoFqCol =
      '$conteudoFqtn.$conteudoConteudoSourceCol';
  static const String conteudoCrcAssinaturaSourceCol = 'crc_assinatura';
  static const String conteudoCrcAssinaturaFqCol =
      '$conteudoFqtn.$conteudoCrcAssinaturaSourceCol';
  static const String conteudoQrCodeAssinaturaSourceCol = 'qr_code_assinatura';
  static const String conteudoQrCodeAssinaturaFqCol =
      '$conteudoFqtn.$conteudoQrCodeAssinaturaSourceCol';

  static const String anexoIdProtocoloSourceCol = 'id_protocolo';
  static const String anexoIdProtocoloFqCol =
      '$anexoFqtn.$anexoIdProtocoloSourceCol';
  static const String anexoNomeSourceCol = 'nome';
  static const String anexoNomeFqCol = '$anexoFqtn.$anexoNomeSourceCol';
  static const String anexoTamanhoSourceCol = 'tamanho';
  static const String anexoTamanhoFqCol = '$anexoFqtn.$anexoTamanhoSourceCol';
  static const String anexoHashSourceCol = 'hash';
  static const String anexoHashFqCol = '$anexoFqtn.$anexoHashSourceCol';
  static const String anexoDataInclusaoSourceCol = 'dth_inclusao';
  static const String anexoDataInclusaoFqCol =
      '$anexoFqtn.$anexoDataInclusaoSourceCol';

  static const String idDocumentoCol = 'id_documento';
  static const String estadoCol = 'estado';
  static const String bloqueadoCol = 'bloqueado';
  static const String possuiVersoesCol = 'possui_versoes';
  static const String conteudoHtmlCol = 'conteudo_html';
  static const String crcAssinaturaCol = 'crc_assinatura';
  static const String qrCodeAssinaturaCol = 'qr_code_assinatura';
  static const String anexoNomeCol = 'anexo_nome';
  static const String anexoTamanhoCol = 'anexo_tamanho';
  static const String anexoHashCol = 'anexo_hash';
  static const String anexoDataInclusaoCol = 'anexo_data_inclusao';

  ProcessoDocumentoConteudo({
    required this.idDocumento,
    required this.estado,
    required this.bloqueado,
    required this.possuiVersoes,
    this.conteudoHtml,
    this.crcAssinatura,
    this.qrCodeAssinatura,
    this.anexoNome,
    this.anexoTamanho,
    this.anexoHash,
    this.anexoDataInclusao,
  });

  factory ProcessoDocumentoConteudo.fromMap(Map<String, dynamic> map) {
    return ProcessoDocumentoConteudo(
      idDocumento: SeiCoreUtils.identificadorParaString(
        map[idDocumentoCol],
        nomeCampo: idDocumentoCol,
      ),
      estado: EstadoDocumento.fromValueOrNull(map[estadoCol] as String) ??
          EstadoDocumento.interno,
      bloqueado: SeiCoreUtils.simNaoParaBool(
        (map[bloqueadoCol] as String).trim(),
        nomeCampo: bloqueadoCol,
      ),
      possuiVersoes: SeiCoreUtils.simNaoParaBool(
        (map[possuiVersoesCol] as String).trim(),
        nomeCampo: possuiVersoesCol,
      ),
      conteudoHtml: map[conteudoHtmlCol] as String?,
      crcAssinatura: map[crcAssinaturaCol] as String?,
      qrCodeAssinatura: map[qrCodeAssinaturaCol] as String?,
      anexoNome: map[anexoNomeCol] as String?,
      anexoTamanho: map[anexoTamanhoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[anexoTamanhoCol],
              nomeCampo: anexoTamanhoCol,
            ),
      anexoHash: map[anexoHashCol] as String?,
      anexoDataInclusao: map[anexoDataInclusaoCol] == null
          ? null
          : SeiCoreUtils.dataHoraLocal(
              map[anexoDataInclusaoCol],
              nomeCampo: anexoDataInclusaoCol,
            ),
    );
  }

  final String idDocumento;
  final EstadoDocumento estado;
  final bool bloqueado;
  final bool possuiVersoes;

  /// Preenchido apenas quando [estado] é [EstadoDocumento.interno].
  final String? conteudoHtml;
  final String? crcAssinatura;
  final String? qrCodeAssinatura;

  /// Preenchidos apenas quando [estado] é [EstadoDocumento.externo].
  ///
  /// O byte do arquivo não está aqui — ele vive fora do banco, no repositório
  /// de arquivos ainda não implementado. Estes campos são o ponteiro.
  final String? anexoNome;
  final int? anexoTamanho;
  final String? anexoHash;
  final DateTime? anexoDataInclusao;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idDocumentoCol: idDocumento,
      estadoCol: estado.valor,
      bloqueadoCol: SeiCoreUtils.boolParaSimNao(bloqueado),
      possuiVersoesCol: SeiCoreUtils.boolParaSimNao(possuiVersoes),
      conteudoHtmlCol: conteudoHtml,
      crcAssinaturaCol: crcAssinatura,
      qrCodeAssinaturaCol: qrCodeAssinatura,
      anexoNomeCol: anexoNome,
      anexoTamanhoCol: anexoTamanho,
      anexoHashCol: anexoHash,
      anexoDataInclusaoCol: anexoDataInclusao?.toIso8601String(),
    };
  }
}
