import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Metadados do arquivo de um documento externo, gravável em `anexo`.
///
/// O byte do arquivo não fica no banco: ele vive no repositório de arquivos
/// configurado pelo SEI (ver `SeiFileRepository` no roteiro mestre, seção 9),
/// que este projeto ainda não implementa. Esta entidade expõe apenas o
/// ponteiro — nome, tamanho e hash — necessário para localizar e validar o
/// arquivo quando o repositório existir.
///
/// A mesma tabela também serve anexos de Base de Conhecimento, apontados por
/// `id_base_conhecimento` em vez de `id_protocolo`; o cruzamento no dump
/// histórico confirma que os dois usos nunca se misturam: toda linha com
/// `id_protocolo` preenchido aponta para um documento externo, nunca para
/// outra coisa, e nenhum documento externo tem mais de um anexo. Este projeto
/// só modela o caso de documento externo.
///
/// O identificador é atribuído pela aplicação, sem `DEFAULT` no banco, e por
/// isso participa de [toInsertMap].
class Anexo extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'anexo';
  static const String fqtn = '$schemaName.$tableName';

  static const String idAnexoCol = 'id_anexo';
  static const String idAnexoFqCol = '$fqtn.$idAnexoCol';
  static const String idProtocoloCol = 'id_protocolo';
  static const String idProtocoloFqCol = '$fqtn.$idProtocoloCol';
  static const String idUnidadeCol = 'id_unidade';
  static const String idUnidadeFqCol = '$fqtn.$idUnidadeCol';
  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String idBaseConhecimentoCol = 'id_base_conhecimento';
  static const String idBaseConhecimentoFqCol = '$fqtn.$idBaseConhecimentoCol';
  static const String idProjetoCol = 'id_projeto';
  static const String idProjetoFqCol = '$fqtn.$idProjetoCol';
  static const String nomeCol = 'nome';
  static const String nomeFqCol = '$fqtn.$nomeCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';
  static const String tamanhoCol = 'tamanho';
  static const String tamanhoFqCol = '$fqtn.$tamanhoCol';
  static const String dataInclusaoCol = 'dth_inclusao';
  static const String dataInclusaoFqCol = '$fqtn.$dataInclusaoCol';
  static const String hashCol = 'hash';
  static const String hashFqCol = '$fqtn.$hashCol';

  Anexo({
    required this.idAnexo,
    required this.idUnidade,
    required this.idUsuario,
    required this.nome,
    required this.tamanho,
    required this.dataInclusao,
    required this.hash,
    this.idProtocolo,
    this.idBaseConhecimento,
    this.idProjeto,
    this.ativo = true,
  });

  factory Anexo.fromMap(Map<String, dynamic> map) {
    return Anexo(
      idAnexo: SeiCoreUtils.inteiro(map[idAnexoCol], nomeCampo: idAnexoCol),
      idProtocolo: map[idProtocoloCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idProtocoloCol],
              nomeCampo: idProtocoloCol,
            ),
      idUnidade: SeiCoreUtils.inteiro(
        map[idUnidadeCol],
        nomeCampo: idUnidadeCol,
      ),
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      idBaseConhecimento: map[idBaseConhecimentoCol] == null
          ? null
          : SeiCoreUtils.inteiro(
              map[idBaseConhecimentoCol],
              nomeCampo: idBaseConhecimentoCol,
            ),
      idProjeto: map[idProjetoCol] == null
          ? null
          : SeiCoreUtils.inteiro(map[idProjetoCol], nomeCampo: idProjetoCol),
      nome: map[nomeCol] as String,
      ativo: SeiCoreUtils.simNaoParaBool(
        (map[ativoCol] as String).trim(),
        nomeCampo: ativoCol,
      ),
      tamanho: SeiCoreUtils.inteiro(map[tamanhoCol], nomeCampo: tamanhoCol),
      dataInclusao: SeiCoreUtils.dataHoraLocal(
        map[dataInclusaoCol],
        nomeCampo: dataInclusaoCol,
      ),
      hash: map[hashCol] as String,
    );
  }

  /// Identificador do anexo, atribuído pela aplicação.
  final int idAnexo;

  /// Documento externo dono do arquivo, quando o anexo não é de Base de
  /// Conhecimento.
  final int? idProtocolo;
  final int idUnidade;
  final int idUsuario;
  final int? idBaseConhecimento;
  final int? idProjeto;
  final String nome;
  final bool ativo;

  /// Tamanho do arquivo em bytes.
  final int tamanho;
  final DateTime dataInclusao;

  /// Hash do conteúdo, com 32 caracteres na Base de Referência.
  ///
  /// O roteiro mestre já adverte para não inferir o algoritmo apenas pelo
  /// tamanho da coluna; nenhuma suposição de algoritmo é feita aqui.
  final String hash;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idAnexoCol: idAnexo,
      idProtocoloCol: idProtocolo,
      idUnidadeCol: idUnidade,
      idUsuarioCol: idUsuario,
      idBaseConhecimentoCol: idBaseConhecimento,
      idProjetoCol: idProjeto,
      nomeCol: nome,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
      tamanhoCol: tamanho,
      dataInclusaoCol: dataInclusao,
      hashCol: hash,
    };
  }

  /// Mapa de inserção com a chave atribuída pela aplicação.
  @override
  Map<String, dynamic> toInsertMap() => toMap();

  /// Mapa de atualização sem a chave de identidade.
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa.remove(idAnexoCol);
    return mapa;
  }
}
