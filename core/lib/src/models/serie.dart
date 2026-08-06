import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Tipo de documento configurado na tabela de séries do SEI.
class Serie extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'serie';
  static const String fqtn = '$schemaName.$tableName';

  static const String idCol = 'id_serie';
  static const String idFqCol = '$fqtn.$idCol';
  static const String idModeloEdocCol = 'id_modelo_edoc';
  static const String idGrupoSerieCol = 'id_grupo_serie';
  static const String idModeloCol = 'id_modelo';
  static const String idTipoFormularioCol = 'id_tipo_formulario';
  static const String nomeCol = 'nome';
  static const String descricaoCol = 'descricao';
  static const String ativoCol = 'sin_ativo';
  static const String interessadoCol = 'sin_interessado';
  static const String destinatarioCol = 'sin_destinatario';
  static const String numeracaoCol = 'sta_numeracao';
  static const String assinaturaPublicacaoCol = 'sin_assinatura_publicacao';
  static const String aplicabilidadeCol = 'sta_aplicabilidade';
  static const String internoCol = 'sin_interno';
  static const String usuarioExternoCol = 'sin_usuario_externo';
  static const String valorMonetarioCol = 'sin_valor_monetario';

  Serie({
    required this.idSerie,
    required this.nome,
    required this.ativo,
    required this.interessado,
    required this.destinatario,
    required this.numeracao,
    required this.assinaturaPublicacao,
    required this.aplicabilidade,
    required this.interno,
    required this.usuarioExterno,
    required this.valorMonetario,
    this.idModeloEdoc,
    this.idGrupoSerie,
    this.idModelo,
    this.idTipoFormulario,
    this.descricao,
  });

  factory Serie.fromMap(Map<String, dynamic> map) {
    return Serie(
      idSerie: map[idCol] as int,
      idModeloEdoc: map[idModeloEdocCol] as int?,
      idGrupoSerie: map[idGrupoSerieCol] as int?,
      idModelo: map[idModeloCol] as int?,
      idTipoFormulario: map[idTipoFormularioCol] as int?,
      nome: map[nomeCol] as String,
      descricao: map[descricaoCol] as String?,
      ativo: SeiCoreUtils.simNaoParaBool(
        map[ativoCol] as String,
        nomeCampo: ativoCol,
      ),
      interessado: SeiCoreUtils.simNaoParaBool(
        map[interessadoCol] as String,
        nomeCampo: interessadoCol,
      ),
      destinatario: SeiCoreUtils.simNaoParaBool(
        map[destinatarioCol] as String,
        nomeCampo: destinatarioCol,
      ),
      numeracao: map[numeracaoCol] as String,
      assinaturaPublicacao: SeiCoreUtils.simNaoParaBool(
        map[assinaturaPublicacaoCol] as String,
        nomeCampo: assinaturaPublicacaoCol,
      ),
      aplicabilidade: map[aplicabilidadeCol] as String,
      interno: SeiCoreUtils.simNaoParaBool(
        map[internoCol] as String,
        nomeCampo: internoCol,
      ),
      usuarioExterno: SeiCoreUtils.simNaoParaBool(
        map[usuarioExternoCol] as String,
        nomeCampo: usuarioExternoCol,
      ),
      valorMonetario: SeiCoreUtils.simNaoParaBool(
        map[valorMonetarioCol] as String,
        nomeCampo: valorMonetarioCol,
      ),
    );
  }

  final int idSerie;
  final int? idModeloEdoc;
  final int? idGrupoSerie;
  final int? idModelo;
  final int? idTipoFormulario;
  final String nome;
  final String? descricao;
  final bool ativo;
  final bool interessado;
  final bool destinatario;
  final String numeracao;
  final bool assinaturaPublicacao;
  final String aplicabilidade;
  final bool interno;
  final bool usuarioExterno;
  final bool valorMonetario;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idCol: idSerie,
      idModeloEdocCol: idModeloEdoc,
      idGrupoSerieCol: idGrupoSerie,
      idModeloCol: idModelo,
      idTipoFormularioCol: idTipoFormulario,
      nomeCol: nome,
      descricaoCol: descricao,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
      interessadoCol: SeiCoreUtils.boolParaSimNao(interessado),
      destinatarioCol: SeiCoreUtils.boolParaSimNao(destinatario),
      numeracaoCol: numeracao,
      assinaturaPublicacaoCol:
          SeiCoreUtils.boolParaSimNao(assinaturaPublicacao),
      aplicabilidadeCol: aplicabilidade,
      internoCol: SeiCoreUtils.boolParaSimNao(interno),
      usuarioExternoCol: SeiCoreUtils.boolParaSimNao(usuarioExterno),
      valorMonetarioCol: SeiCoreUtils.boolParaSimNao(valorMonetario),
    };
  }
}
