import 'package:sei_core/src/models/base_model.dart';
import 'package:sei_core/src/utils/sei_core_utils.dart';

/// Usuário do SEI, persistido em `sei_5_0_0.usuario`.
///
/// **Autenticação real.** Diferente de `sip_5_0_0.usuario` (autorização,
/// sem credencial), esta tabela guarda o login local do SEI:
/// [senhaHash] mapeia `usuario.senha character(60)`, um hash bcrypt
/// (`password_hash()` do PHP). Ver a correção documentada em
/// `backend/docs/evidencias_processo_detalhe.md` e
/// `backend/docs/roteiro_mestre_sei_dart_mod_pen.md` — autenticação não
/// depende de LDAP/AD, que é integração opcional por órgão.
///
/// **`toMap()` nunca inclui a senha.** `toMap()` é o contrato de transporte
/// da API (ver `BaseModel`), e o hash bcrypt não pode ser serializado de
/// volta para o cliente. [toInsertMap] inclui [senhaHash] explicitamente
/// porque grava a coluna; [toUpdateMap] cobre só os campos cadastrais
/// (nome, sigla, ativo) — troca de senha usa [mapaAtualizacaoSenha], um
/// contrato de escrita separado e propositalmente estreito, para que uma
/// atualização cadastral nunca sobrescreva a senha por acidente.
///
/// **`staTipo` é opaco.** O cruzamento no dump histórico
/// (`backend/referencias/backup_sei_bd/sei.sql`, 1071 linhas de `usuario`)
/// mostra correlação forte com a presença de senha local: `sta_tipo` `'0'`
/// (1059 linhas) e `'1'` (5 linhas, as contas de sistema SEI/SIP/INTRANET/
/// INTERNET) nunca têm `senha` preenchida; `'2'` (1 linha) e `'3'` (6
/// linhas) sempre têm. Não há evidência do significado exato de cada
/// dígito, só da correlação com senha. Como todo usuário criado por este
/// cadastro sempre recebe senha local, o valor padrão usado aqui é `'2'`,
/// nunca `'0'`/`'1'` (que nos dados reais jamais aparecem com senha). Ver a
/// lacuna registrada em `backend/docs/evidencias_processo_detalhe.md`.
///
/// O identificador é atribuído pela aplicação, e não por sequência do banco:
/// `id_usuario` não possui `DEFAULT` na Base de Referência. Por isso ele
/// participa de [toInsertMap] e é obrigatório na construção.
class Usuario extends BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'usuario';
  static const String fqtn = '$schemaName.$tableName';

  static const String idUsuarioCol = 'id_usuario';
  static const String idUsuarioFqCol = '$fqtn.$idUsuarioCol';
  static const String idContatoCol = 'id_contato';
  static const String idContatoFqCol = '$fqtn.$idContatoCol';
  static const String idOrgaoCol = 'id_orgao';
  static const String idOrgaoFqCol = '$fqtn.$idOrgaoCol';
  static const String idOrigemCol = 'id_origem';
  static const String idOrigemFqCol = '$fqtn.$idOrigemCol';
  static const String ativoCol = 'sin_ativo';
  static const String ativoFqCol = '$fqtn.$ativoCol';
  static const String siglaCol = 'sigla';
  static const String siglaFqCol = '$fqtn.$siglaCol';
  static const String nomeCol = 'nome';
  static const String nomeFqCol = '$fqtn.$nomeCol';
  static const String idxUsuarioCol = 'idx_usuario';
  static const String idxUsuarioFqCol = '$fqtn.$idxUsuarioCol';
  static const String staTipoCol = 'sta_tipo';
  static const String staTipoFqCol = '$fqtn.$staTipoCol';
  static const String senhaCol = 'senha';
  static const String senhaFqCol = '$fqtn.$senhaCol';
  static const String nomeRegistroCivilCol = 'nome_registro_civil';
  static const String nomeRegistroCivilFqCol = '$fqtn.$nomeRegistroCivilCol';
  static const String nomeSocialCol = 'nome_social';
  static const String nomeSocialFqCol = '$fqtn.$nomeSocialCol';
  static const String idUsuarioFederacaoCol = 'id_usuario_federacao';
  static const String idUsuarioFederacaoFqCol = '$fqtn.$idUsuarioFederacaoCol';
  static const String sinGovBrCol = 'sin_gov_br';
  static const String sinGovBrFqCol = '$fqtn.$sinGovBrCol';
  static const String dthTermoUsoCol = 'dth_termo_uso';
  static const String dthTermoUsoFqCol = '$fqtn.$dthTermoUsoCol';
  static const String dthPoliticaPrivacidadeCol = 'dth_politica_privacidade';
  static const String dthPoliticaPrivacidadeFqCol =
      '$fqtn.$dthPoliticaPrivacidadeCol';

  /// Único valor de `sta_tipo` usado pelo cadastro deste projeto: usuário
  /// com senha local (ver Dartdoc da classe). Os valores `'0'`/`'1'`
  /// observados na Base de Referência nunca têm senha preenchida.
  static const String staTipoComSenhaLocal = '2';

  Usuario({
    required this.idUsuario,
    required this.idContato,
    required this.idOrgao,
    required this.sigla,
    required this.nome,
    String? nomeRegistroCivil,
    this.ativo = true,
    this.idOrigem,
    this.idxUsuario,
    this.staTipo = staTipoComSenhaLocal,
    this.senhaHash,
    this.nomeSocial,
    this.idUsuarioFederacao,
    this.sinGovBr = false,
    this.dthTermoUso,
    this.dthPoliticaPrivacidade,
  }) : nomeRegistroCivil = nomeRegistroCivil ?? nome;

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: SeiCoreUtils.inteiro(
        map[idUsuarioCol],
        nomeCampo: idUsuarioCol,
      ),
      idContato: SeiCoreUtils.inteiro(
        map[idContatoCol],
        nomeCampo: idContatoCol,
      ),
      idOrgao: SeiCoreUtils.inteiro(
        map[idOrgaoCol],
        nomeCampo: idOrgaoCol,
      ),
      sigla: map[siglaCol] as String,
      nome: map[nomeCol] as String,
      nomeRegistroCivil: map[nomeRegistroCivilCol] as String?,
      ativo: SeiCoreUtils.simNaoParaBool(
        map[ativoCol] as String,
        nomeCampo: ativoCol,
      ),
      idOrigem: map[idOrigemCol] as String?,
      idxUsuario: map[idxUsuarioCol] as String?,
      staTipo: (map[staTipoCol] as String).trim(),
      senhaHash: (map[senhaCol] as String?)?.trim().isEmpty ?? true
          ? null
          : (map[senhaCol] as String).trim(),
      nomeSocial: map[nomeSocialCol] as String?,
      idUsuarioFederacao: map[idUsuarioFederacaoCol] as String?,
      sinGovBr: SeiCoreUtils.simNaoParaBool(
        map[sinGovBrCol] as String,
        nomeCampo: sinGovBrCol,
      ),
      dthTermoUso: map[dthTermoUsoCol] as DateTime?,
      dthPoliticaPrivacidade: map[dthPoliticaPrivacidadeCol] as DateTime?,
    );
  }

  /// Identificador do usuário, atribuído pela aplicação.
  int idUsuario;
  int idContato;
  int idOrgao;
  String? idOrigem;
  bool ativo;
  String sigla;
  String nome;
  String? idxUsuario;

  /// Código opaco (ver Dartdoc da classe); não é um domínio fechado provado.
  String staTipo;

  /// Hash bcrypt da senha (60 caracteres), ou `null` para usuários sem login
  /// local (por exemplo, autenticados só por LDAP/AD). Nunca é serializado
  /// por [toMap].
  String? senhaHash;

  String nomeRegistroCivil;
  String? nomeSocial;
  String? idUsuarioFederacao;
  bool sinGovBr;
  DateTime? dthTermoUso;
  DateTime? dthPoliticaPrivacidade;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idUsuarioCol: idUsuario,
      idContatoCol: idContato,
      idOrgaoCol: idOrgao,
      idOrigemCol: idOrigem,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
      siglaCol: sigla,
      nomeCol: nome,
      idxUsuarioCol: idxUsuario,
      staTipoCol: staTipo,
      nomeRegistroCivilCol: nomeRegistroCivil,
      nomeSocialCol: nomeSocial,
      idUsuarioFederacaoCol: idUsuarioFederacao,
      sinGovBrCol: SeiCoreUtils.boolParaSimNao(sinGovBr),
      dthTermoUsoCol: dthTermoUso,
      dthPoliticaPrivacidadeCol: dthPoliticaPrivacidade,
    };
  }

  /// Mapa de inserção com todas as colunas, inclusive a chave e a senha.
  ///
  /// A chave permanece porque o SEI atribui o identificador na aplicação; a
  /// coluna não tem `DEFAULT` no banco. [senhaHash] é incluído explicitamente
  /// porque [toMap] nunca o expõe.
  @override
  Map<String, dynamic> toInsertMap() {
    final Map<String, dynamic> mapa = toMap();
    mapa[senhaCol] = senhaHash;
    return mapa;
  }

  /// Mapa de atualização cadastral: nome, sigla e situação de ativação.
  ///
  /// Propositalmente não inclui [senhaHash] nem a organização/contato do
  /// usuário — trocar senha é [mapaAtualizacaoSenha], um contrato à parte
  /// para que uma edição cadastral nunca sobrescreva a senha por acidente.
  @override
  Map<String, dynamic> toUpdateMap() {
    return <String, dynamic>{
      siglaCol: sigla,
      nomeCol: nome,
      ativoCol: SeiCoreUtils.boolParaSimNao(ativo),
    };
  }

  /// Mapa de atualização exclusivo para troca de senha.
  ///
  /// Único ponto de escrita da coluna `senha` fora da criação do usuário.
  static Map<String, dynamic> mapaAtualizacaoSenha(String hashBcrypt) {
    return <String, dynamic>{senhaCol: hashBcrypt};
  }
}
