import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Corpo HTML de um documento interno, gravável em `documento_conteudo`.
///
/// Só existe para documento com `Documento.estado == EstadoDocumento.interno`
/// — o cruzamento no dump histórico confirma que as 536 linhas de
/// `documento_conteudo` correspondem exatamente aos 536 documentos com
/// `protocolo.sta_protocolo = 'G'`, e nenhum documento externo tem linha
/// correspondente.
///
/// A relação com `documento` é 1:1 pela própria chave: não há coluna de
/// identidade própria, `id_documento` é ao mesmo tempo chave primária e
/// estrangeira. Por isso [toUpdateMap] usa `id_documento` no filtro da
/// consulta, não no mapa de campos a atualizar — mas a linha inteira
/// participa de [toInsertMap], já que a chave não é gerada pelo banco.
class DocumentoConteudo extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'documento_conteudo';
  static const String fqtn = '$schemaName.$tableName';

  static const String idDocumentoCol = 'id_documento';
  static const String idDocumentoFqCol = '$fqtn.$idDocumentoCol';
  static const String conteudoCol = 'conteudo';
  static const String conteudoFqCol = '$fqtn.$conteudoCol';
  static const String conteudoAssinaturaCol = 'conteudo_assinatura';
  static const String conteudoAssinaturaFqCol = '$fqtn.$conteudoAssinaturaCol';
  static const String crcAssinaturaCol = 'crc_assinatura';
  static const String crcAssinaturaFqCol = '$fqtn.$crcAssinaturaCol';
  static const String qrCodeAssinaturaCol = 'qr_code_assinatura';
  static const String qrCodeAssinaturaFqCol = '$fqtn.$qrCodeAssinaturaCol';

  DocumentoConteudo({
    required this.idDocumento,
    this.conteudo,
    this.conteudoAssinatura,
    this.crcAssinatura,
    this.qrCodeAssinatura,
  });

  factory DocumentoConteudo.fromMap(Map<String, dynamic> map) {
    return DocumentoConteudo(
      idDocumento: SeiCoreUtils.inteiro(
        map[idDocumentoCol],
        nomeCampo: idDocumentoCol,
      ),
      conteudo: map[conteudoCol] as String?,
      conteudoAssinatura: map[conteudoAssinaturaCol] as String?,
      crcAssinatura: map[crcAssinaturaCol] as String?,
      qrCodeAssinatura: map[qrCodeAssinaturaCol] as String?,
    );
  }

  /// Identidade compartilhada com `documento.id_documento`.
  final int idDocumento;

  /// Corpo HTML do documento, como produzido pelo editor.
  final String? conteudo;

  /// Conteúdo protegido pela assinatura.
  ///
  /// A coluna existe e é preservada, mas a relação exata com [conteudo] —
  /// cópia congelada no momento da assinatura, versão normalizada para
  /// cálculo de hash, ou outra coisa — não está comprovada pelas fontes
  /// locais. Nenhuma suposição adicional é feita sobre este campo.
  final String? conteudoAssinatura;
  final String? crcAssinatura;
  final String? qrCodeAssinatura;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idDocumentoCol: idDocumento,
      conteudoCol: conteudo,
      conteudoAssinaturaCol: conteudoAssinatura,
      crcAssinaturaCol: crcAssinatura,
      qrCodeAssinaturaCol: qrCodeAssinatura,
    };
  }

  /// Mapa de inserção com a chave, que é a mesma identidade do documento.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idDocumentoCol);
    return mapa;
  }
}
