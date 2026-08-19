import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/estado_bloco.dart';
import 'package:sei_core/src/models/tipo_bloco.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Bloco que contém este protocolo, com a unidade e o usuário resolvidos.
///
/// Projeção somente leitura de `bloco` unida a `rel_bloco_protocolo`
/// (filtrada pelo protocolo consultado), `unidade` e `usuario`. Como
/// `rel_bloco_protocolo.id_protocolo` é genérico, esta projeção serve tanto
/// para processo quanto para documento.
///
/// O Grupo do bloco não entra aqui: ele vive em
/// `rel_bloco_unidade.id_grupo_bloco`, um atributo por unidade, não do bloco
/// em si — uma listagem "Blocos da unidade" resolveria isso à parte.
class ProcessoBloco extends BaseModel {
  static const String schemaName = 'public';

  static const String blocoFqtn = '$schemaName.bloco';
  static const String relacaoFqtn = '$schemaName.rel_bloco_protocolo';
  static const String unidadeFqtn = '$schemaName.unidade';
  static const String usuarioFqtn = '$schemaName.usuario';

  static const String blocoIdSourceCol = 'id_bloco';
  static const String blocoIdFqCol = '$blocoFqtn.$blocoIdSourceCol';
  static const String blocoIdUnidadeSourceCol = 'id_unidade';
  static const String blocoIdUnidadeFqCol =
      '$blocoFqtn.$blocoIdUnidadeSourceCol';
  static const String blocoIdUsuarioSourceCol = 'id_usuario';
  static const String blocoIdUsuarioFqCol =
      '$blocoFqtn.$blocoIdUsuarioSourceCol';
  static const String blocoDescricaoSourceCol = 'descricao';
  static const String blocoDescricaoFqCol =
      '$blocoFqtn.$blocoDescricaoSourceCol';
  static const String blocoTipoSourceCol = 'sta_tipo';
  static const String blocoTipoFqCol = '$blocoFqtn.$blocoTipoSourceCol';
  static const String blocoEstadoSourceCol = 'sta_estado';
  static const String blocoEstadoFqCol = '$blocoFqtn.$blocoEstadoSourceCol';

  static const String relacaoIdProtocoloSourceCol = 'id_protocolo';
  static const String relacaoIdProtocoloFqCol =
      '$relacaoFqtn.$relacaoIdProtocoloSourceCol';
  static const String relacaoIdBlocoSourceCol = 'id_bloco';
  static const String relacaoIdBlocoFqCol =
      '$relacaoFqtn.$relacaoIdBlocoSourceCol';
  static const String relacaoSequenciaSourceCol = 'sequencia';
  static const String relacaoSequenciaFqCol =
      '$relacaoFqtn.$relacaoSequenciaSourceCol';
  static const String relacaoAnotacaoSourceCol = 'anotacao';
  static const String relacaoAnotacaoFqCol =
      '$relacaoFqtn.$relacaoAnotacaoSourceCol';

  static const String unidadeIdSourceCol = 'id_unidade';
  static const String unidadeIdFqCol = '$unidadeFqtn.$unidadeIdSourceCol';
  static const String unidadeSiglaSourceCol = 'sigla';
  static const String unidadeSiglaFqCol = '$unidadeFqtn.$unidadeSiglaSourceCol';

  static const String usuarioIdSourceCol = 'id_usuario';
  static const String usuarioIdFqCol = '$usuarioFqtn.$usuarioIdSourceCol';
  static const String usuarioNomeSourceCol = 'nome';
  static const String usuarioNomeFqCol = '$usuarioFqtn.$usuarioNomeSourceCol';

  static const String idBlocoCol = 'id_bloco';
  static const String tipoCol = 'tipo';
  static const String estadoCol = 'estado';
  static const String descricaoCol = 'descricao';
  static const String idUnidadeCol = 'id_unidade';
  static const String unidadeSiglaCol = 'unidade_sigla';
  static const String idUsuarioCol = 'id_usuario';
  static const String usuarioNomeCol = 'usuario_nome';
  static const String sequenciaCol = 'sequencia';
  static const String anotacaoCol = 'anotacao';

  ProcessoBloco({
    required this.idBloco,
    required this.tipo,
    required this.estado,
    required this.idUnidade,
    required this.unidadeSigla,
    required this.idUsuario,
    required this.usuarioNome,
    required this.sequencia,
    this.descricao,
    this.anotacao,
  });

  factory ProcessoBloco.fromMap(Map<String, dynamic> map) {
    return ProcessoBloco(
      idBloco: SeiCoreUtils.inteiro(map[idBlocoCol], nomeCampo: idBlocoCol),
      tipo: TipoBloco.fromValue(map[tipoCol] as String),
      estado: EstadoBloco.fromValue(map[estadoCol] as String),
      descricao: map[descricaoCol] as String?,
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      unidadeSigla: map[unidadeSiglaCol] as String,
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      usuarioNome: map[usuarioNomeCol] as String,
      sequencia: SeiCoreUtils.inteiro(
        map[sequenciaCol],
        nomeCampo: sequenciaCol,
      ),
      anotacao: map[anotacaoCol] as String?,
    );
  }

  final int idBloco;
  final TipoBloco tipo;
  final EstadoBloco estado;
  final String? descricao;

  /// Unidade geradora do bloco.
  final int idUnidade;
  final String unidadeSigla;

  /// Usuário que criou o bloco.
  final int idUsuario;
  final String usuarioNome;

  /// Ordem deste protocolo dentro do bloco.
  final int sequencia;

  /// Anotação exclusiva desta linha, feita ao incluir o protocolo no bloco.
  final String? anotacao;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idBlocoCol: idBloco,
      tipoCol: tipo.valor,
      estadoCol: estado.valor,
      descricaoCol: descricao,
      idUnidadeCol: idUnidade,
      unidadeSiglaCol: unidadeSigla,
      idUsuarioCol: idUsuario,
      usuarioNomeCol: usuarioNome,
      sequenciaCol: sequencia,
      anotacaoCol: anotacao,
    };
  }
}
