/// Catálogo de tipos de contato do SEI, persistido em `tipo_contato`.
///
/// A tabela documenta o próprio domínio em `nome`/`descricao` — o mesmo
/// padrão de autodocumentação já usado para `TipoPermissao` no SIP — por
/// isso é declarada com confiança total, sem lacuna. As 6 linhas abaixo são
/// as únicas existentes na Base de Referência local
/// (`SELECT * FROM tipo_contato`). Duas delas embutem a sigla do órgão da
/// instalação no próprio nome (`Usuários ABC`, `Unidades ABC` — "ABC" é a
/// sigla do órgão de referência local): o instalador do SEI nomeia essas
/// duas categorias dinamicamente a partir da sigla do primeiro órgão
/// cadastrado, então [nome] aqui carrega só um rótulo genérico e estável
/// para uso no código Dart, não o texto exato gravado no banco.
///
/// O cadastro implementado neste projeto usa três valores: [usuarios] e
/// [unidades] para o contato mínimo criado junto com `usuario`/`unidade`, e
/// [orgaos] para o contato criado junto com `orgao`. Nos dois primeiros,
/// `contato.id_contato_associado` aponta para o `id_contato` do órgão dono
/// (confirmado por cruzamento local: toda linha com `id_tipo_contato` 1 ou 5
/// tem `id_contato_associado` igual ao `id_contato` do órgão da Base de
/// Referência); em [orgaos] e [sistemas], `id_contato_associado` aponta para
/// o próprio `id_contato` (autorreferência).
enum TipoContato {
  /// Pessoas físicas internas do órgão (usuários do SEI/SIP).
  usuarios(1, 'Usuários'),

  /// Sistemas associados (contas técnicas como SEI, SIP, INTRANET, INTERNET).
  sistemas(2, 'Sistemas'),

  /// Usuários externos (peticionamento eletrônico), fora do escopo deste
  /// cadastro.
  usuariosExternos(3, 'Usuários Externos'),

  /// Contextos temporários, fora do escopo deste cadastro.
  temporario(4, 'Temporário'),

  /// Unidades organizacionais internas do órgão.
  unidades(5, 'Unidades'),

  /// Órgãos.
  orgaos(6, 'Órgãos');

  const TipoContato(this.id, this.nome);

  /// Valor persistido em `contato.id_tipo_contato` e `tipo_contato.id_tipo_contato`.
  final int id;

  /// Rótulo estável para uso no código; não é necessariamente igual ao texto
  /// gravado em `tipo_contato.nome` (ver Dartdoc da classe).
  final String nome;

  /// Converte o identificador do banco no tipo conhecido correspondente.
  static TipoContato fromId(int id) {
    for (final TipoContato tipo in values) {
      if (tipo.id == id) {
        return tipo;
      }
    }
    throw FormatException(
      'id_tipo_contato $id não corresponde a nenhum tipo de contato conhecido.',
    );
  }
}
