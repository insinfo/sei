import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/models/natureza_contato.dart';
import 'package:sei_core/src/models/tipo_contato.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Contato mínimo exigido por `usuario`, `orgao` e `unidade` via `id_contato`.
///
/// `contato` tem mais de 30 colunas no schema real, a maioria nula (endereço,
/// documento, cargo etc.). Este model cobre as colunas `NOT NULL` da tabela
/// mais um pequeno conjunto de campos úteis de identificação (`sigla`,
/// `email`, `cpf`, `cnpj`); os demais campos nulos não usados pelo cadastro
/// de usuário/unidade/órgão deste projeto não são modelados ainda — adicione
/// quando um fluxo precisar deles.
///
/// O identificador é atribuído pela aplicação, e não por sequência do banco:
/// `id_contato` não possui `DEFAULT` na Base de Referência (confirmado por
/// `information_schema.columns`). Por isso ele participa de [toInsertMap] e
/// é obrigatório na construção.
class Contato extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'contato';
  static const String fqtn = '$schemaName.$tableName';

  static const String idContatoCol = 'id_contato';
  static const String idContatoFqCol = '$fqtn.$idContatoCol';
  static const String idContatoAssociadoCol = 'id_contato_associado';
  static const String idContatoAssociadoFqCol = '$fqtn.$idContatoAssociadoCol';
  static const String idTipoContatoCol = 'id_tipo_contato';
  static const String idTipoContatoFqCol = '$fqtn.$idTipoContatoCol';
  static const String nomeCol = 'nome';
  static const String nomeFqCol = '$fqtn.$nomeCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';
  static const String naturezaCol = 'sta_natureza';
  static const String naturezaFqCol = '$fqtn.$naturezaCol';
  static const String enderecoAssociadoCol = 'sin_endereco_associado';
  static const String enderecoAssociadoFqCol = '$fqtn.$enderecoAssociadoCol';
  static const String siglaCol = 'sigla';
  static const String siglaFqCol = '$fqtn.$siglaCol';
  static const String emailCol = 'email';
  static const String emailFqCol = '$fqtn.$emailCol';
  static const String cpfCol = 'cpf';
  static const String cpfFqCol = '$fqtn.$cpfCol';
  static const String cnpjCol = 'cnpj';
  static const String cnpjFqCol = '$fqtn.$cnpjCol';

  Contato({
    required this.idContato,
    required this.idContatoAssociado,
    required this.tipoContato,
    required this.nome,
    required this.natureza,
    this.ativo = true,
    this.enderecoAssociado = false,
    this.sigla,
    this.email,
    this.cpf,
    this.cnpj,
  });

  factory Contato.fromMap(Map<String, dynamic> map) {
    return Contato(
      idContato: SeiCoreUtils.inteiro(
        map[idContatoCol],
        nomeCampo: idContatoCol,
      ),
      idContatoAssociado: SeiCoreUtils.inteiro(
        map[idContatoAssociadoCol],
        nomeCampo: idContatoAssociadoCol,
      ),
      tipoContato: TipoContato.fromId(
        SeiCoreUtils.inteiro(
          map[idTipoContatoCol],
          nomeCampo: idTipoContatoCol,
        ),
      ),
      nome: map[nomeCol] as String,
      natureza: NaturezaContato.fromValue(map[naturezaCol] as String),
      ativo: SeiCoreUtils.simNaoParaBool(
        map[ativoCol] as String,
        nomeCampo: ativoCol,
      ),
      enderecoAssociado: SeiCoreUtils.simNaoParaBool(
        map[enderecoAssociadoCol] as String,
        nomeCampo: enderecoAssociadoCol,
      ),
      sigla: map[siglaCol] as String?,
      email: map[emailCol] as String?,
      cpf: map[cpfCol] as int?,
      cnpj: map[cnpjCol] as String?,
    );
  }

  /// Identificador do contato, atribuído pela aplicação.
  int idContato;

  /// Contato "dono" desta linha. Para [TipoContato.usuarios] e
  /// [TipoContato.unidades], é o `id_contato` do órgão a que pertencem; para
  /// [TipoContato.orgaos] e [TipoContato.sistemas], é o próprio [idContato]
  /// (autorreferência) — ver Dartdoc de [TipoContato].
  int idContatoAssociado;

  TipoContato tipoContato;
  String nome;
  bool ativo;
  NaturezaContato natureza;
  bool enderecoAssociado;
  String? sigla;
  String? email;
  int? cpf;
  String? cnpj;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idContatoCol: idContato,
      idContatoAssociadoCol: idContatoAssociado,
      idTipoContatoCol: tipoContato.id,
      nomeCol: nome,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
      naturezaCol: natureza.valor,
      enderecoAssociadoCol: SeiCoreUtils.boolParaSimNao(enderecoAssociado),
      siglaCol: sigla,
      emailCol: email,
      cpfCol: cpf,
      cnpjCol: cnpj,
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
    mapa.remove(idContatoCol);
    return mapa;
  }
}
