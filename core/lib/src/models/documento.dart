import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/estado_documento.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Especialização de `protocolo` que representa um documento do processo.
///
/// Assim como `procedimento`, a linha compartilha a chave com `protocolo`:
/// `id_documento` é a mesma identidade e é atribuída pela aplicação, sem
/// `DEFAULT` no banco. Por isso a chave participa de [toInsertMap]. O byte do
/// documento não mora aqui: para documento interno ele vive em
/// `documento_conteudo` ([DocumentoConteudo]); para documento externo ele vive
/// fora do banco, apontado por `anexo` ([Anexo]).
class Documento extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'documento';
  static const String fqtn = '$schemaName.$tableName';

  static const String idDocumentoCol = 'id_documento';
  static const String idDocumentoFqCol = '$fqtn.$idDocumentoCol';
  static const String idUnidadeResponsavelCol = 'id_unidade_responsavel';
  static const String idUnidadeResponsavelFqCol =
      '$fqtn.$idUnidadeResponsavelCol';
  static const String idDocumentoEdocCol = 'id_documento_edoc';
  static const String idDocumentoEdocFqCol = '$fqtn.$idDocumentoEdocCol';
  static const String idSerieCol = 'id_serie';
  static const String idSerieFqCol = '$fqtn.$idSerieCol';
  static const String idProcedimentoCol = 'id_procedimento';
  static const String idProcedimentoFqCol = '$fqtn.$idProcedimentoCol';
  static const String idConjuntoEstilosCol = 'id_conjunto_estilos';
  static const String idConjuntoEstilosFqCol = '$fqtn.$idConjuntoEstilosCol';
  static const String idTipoConferenciaCol = 'id_tipo_conferencia';
  static const String idTipoConferenciaFqCol = '$fqtn.$idTipoConferenciaCol';
  static const String idTipoFormularioCol = 'id_tipo_formulario';
  static const String idTipoFormularioFqCol = '$fqtn.$idTipoFormularioCol';
  static const String numeroCol = 'numero';
  static const String numeroFqCol = '$fqtn.$numeroCol';
  static const String bloqueadoCol = 'sin_bloqueado';
  static const String bloqueadoFqCol = '$fqtn.$bloqueadoCol';
  static const String estadoCol = 'sta_documento';
  static const String estadoFqCol = '$fqtn.$estadoCol';
  static const String nomeArvoreCol = 'nome_arvore';
  static const String nomeArvoreFqCol = '$fqtn.$nomeArvoreCol';
  static const String arquivamentoCol = 'sin_arquivamento';
  static const String arquivamentoFqCol = '$fqtn.$arquivamentoCol';
  static const String versoesCol = 'sin_versoes';
  static const String versoesFqCol = '$fqtn.$versoesCol';
  static const String valorMonetarioCol = 'din_valor';
  static const String valorMonetarioFqCol = '$fqtn.$valorMonetarioCol';
  static const String editorCol = 'sta_editor';
  static const String editorFqCol = '$fqtn.$editorCol';

  Documento({
    required this.idDocumento,
    required this.idUnidadeResponsavel,
    required this.idSerie,
    required this.idProcedimento,
    required this.estado,
    required this.editor,
    this.idDocumentoEdoc,
    this.idConjuntoEstilos,
    this.idTipoConferencia,
    this.idTipoFormulario,
    this.numero,
    this.bloqueado = false,
    this.nomeArvore,
    this.arquivamento = false,
    this.versoes = false,
    this.valorMonetario,
  });

  factory Documento.fromMap(Map<String, dynamic> map) {
    return Documento(
      idDocumento: SeiCoreUtils.inteiro(
        map[idDocumentoCol],
        nomeCampo: idDocumentoCol,
      ),
      idUnidadeResponsavel: SeiCoreUtils.inteiro(
        map[idUnidadeResponsavelCol],
        nomeCampo: idUnidadeResponsavelCol,
      ),
      idDocumentoEdoc: map[idDocumentoEdocCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idDocumentoEdocCol],
              nomeCampo: idDocumentoEdocCol,
            ),
      idSerie: SeiCoreUtils.inteiro(map[idSerieCol], nomeCampo: idSerieCol),
      idProcedimento: SeiCoreUtils.inteiro(
        map[idProcedimentoCol],
        nomeCampo: idProcedimentoCol,
      ),
      idConjuntoEstilos: map[idConjuntoEstilosCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idConjuntoEstilosCol],
              nomeCampo: idConjuntoEstilosCol,
            ),
      idTipoConferencia: map[idTipoConferenciaCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idTipoConferenciaCol],
              nomeCampo: idTipoConferenciaCol,
            ),
      idTipoFormulario: map[idTipoFormularioCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idTipoFormularioCol],
              nomeCampo: idTipoFormularioCol,
            ),
      numero: map[numeroCol] as String?,
      bloqueado: SeiCoreUtils.simNaoParaBool(
        (map[bloqueadoCol] as String).trim(),
        nomeCampo: bloqueadoCol,
      ),
      estado: EstadoDocumento.fromValueOrNull(map[estadoCol] as String) ??
          EstadoDocumento.interno,
      nomeArvore: map[nomeArvoreCol] as String?,
      arquivamento: SeiCoreUtils.simNaoParaBool(
        (map[arquivamentoCol] as String).trim(),
        nomeCampo: arquivamentoCol,
      ),
      versoes: SeiCoreUtils.simNaoParaBool(
        (map[versoesCol] as String).trim(),
        nomeCampo: versoesCol,
      ),
      valorMonetario: map[valorMonetarioCol] == null
          ? null
          : (map[valorMonetarioCol] as num).toDouble(),
      editor: (map[editorCol] as String).trim(),
    );
  }

  /// Identidade compartilhada com `protocolo.id_protocolo`.
  final int idDocumento;
  final int idUnidadeResponsavel;
  final int? idDocumentoEdoc;
  final int idSerie;
  final int idProcedimento;
  final int? idConjuntoEstilos;
  final int? idTipoConferencia;
  final int? idTipoFormulario;
  final String? numero;
  final bool bloqueado;
  final EstadoDocumento estado;
  final String? nomeArvore;
  final bool arquivamento;

  /// Indica que o documento tem controle de versões — comprovadamente
  /// verdadeiro para todo documento interno e falso para todo externo.
  final bool versoes;
  final double? valorMonetario;

  /// Código bruto de `sta_editor`. A coluna é `NOT NULL` no banco.
  ///
  /// Os dados reais mostram `'2'` em todo documento interno e `'0'` em todo
  /// documento externo, mas essa correlação pode refletir apenas "documento
  /// externo não tem editor", não um domínio de tipos de editor. O código é
  /// preservado sem enum.
  final String editor;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idDocumentoCol: idDocumento,
      idUnidadeResponsavelCol: idUnidadeResponsavel,
      idDocumentoEdocCol: idDocumentoEdoc,
      idSerieCol: idSerie,
      idProcedimentoCol: idProcedimento,
      idConjuntoEstilosCol: idConjuntoEstilos,
      idTipoConferenciaCol: idTipoConferencia,
      idTipoFormularioCol: idTipoFormulario,
      numeroCol: numero,
      bloqueadoCol: SeiCoreUtils.boolParaSimNao(bloqueado),
      estadoCol: estado.valor,
      nomeArvoreCol: nomeArvore,
      arquivamentoCol: SeiCoreUtils.boolParaSimNao(arquivamento),
      versoesCol: SeiCoreUtils.boolParaSimNao(versoes),
      valorMonetarioCol: valorMonetario,
      editorCol: editor,
    };
  }

  /// Mapa de inserção com a chave, que é a mesma identidade do protocolo.
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
