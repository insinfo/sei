# Evidências — Detalhe do processo e códigos de domínio

Este documento registra como cada código de domínio usado pelas leituras do
detalhe de processo foi comprovado nas fontes locais, e o que continua sem
prova. Ele segue a mesma disciplina de `evidencias_controle_processos.md`:
nada aqui foi inferido de manual de terceiros.

As duas fontes empíricas são:

- a Base de Referência oficial restaurada em `sei_5_0_0`, proveniente de
  `backend/referencias/sei-db-ref-executivo/postgresql/v5.0.0/`, que contém o
  esquema e os catálogos, mas nenhuma atividade operacional;
- o dump histórico `backend/referencias/backup_sei_bd/sei.sql`, com 1.481
  protocolos, 639 procedimentos, 842 documentos e 4.830 atividades, usado
  somente para leitura de distribuição de valores. Nenhum dado pessoal foi
  reproduzido; apenas contagens e códigos de domínio.

## Abertura por unidade

| Regra implementada | Evidência local | Decisão |
| --- | --- | --- |
| O estado aberto pertence ao par processo e unidade | `atividade` possui `id_protocolo`, `id_unidade` e `dth_conclusao`; não existe coluna de estado aberto em `procedimento` nem em `protocolo`. | `ProcessoUnidadeAberta` agrega `atividade` por unidade com `dth_conclusao IS NULL`. |
| A consulta é nativa e indexada | Índice `i03_atividade (dth_conclusao, id_unidade, sin_inicial)` na Base de Referência. | Não criar índice adicional. |
| Concluir em uma unidade não conclui nas outras | No dump histórico, 73 dos 362 processos com atividade aberta estão abertos em mais de uma unidade ao mesmo tempo; um deles em quatro unidades. | A conclusão é filtrada por unidade, nunca aplicada ao processo inteiro. |
| Uma unidade tem no máximo um andamento aberto | No dump histórico, o máximo de atividades abertas para o mesmo par processo e unidade é **1**. | A agregação preserva `COUNT(*)` como defesa, mas a expectativa é 1. |
| A atribuição é da atividade, não da unidade | `atividade.id_usuario_atribuicao`; não há coluna equivalente em `unidade`. | Segunda consulta resolve a atribuição da atividade aberta mais recente. |

## Códigos de `protocolo.sta_protocolo`

Cruzamento das 1.481 linhas de `protocolo` do dump histórico com as chaves de
`procedimento` e de `documento`:

| Código | Ocorrências | Natureza cruzada | Leitura |
| --- | ---: | --- | --- |
| `P` | 639 | sempre em `procedimento` | processo |
| `G` | 536 | sempre em `documento` | documento gerado no editor |
| `R` | 306 | sempre em `documento` | documento externo registrado |

Implementado em `TipoProtocolo`.

## Códigos de `protocolo.sta_estado`

| Código | Ocorrências | Evidência | Leitura |
| --- | ---: | --- | --- |
| `0` | 1.472 | única em processos e documentos normais | estado normal |
| `2` | 9 | **somente em documentos** | documento cancelado |
| `4` | — | `mod-sei-pen/src/rn/ExpedirProcedimentoRN.php:32` | processo bloqueado no trâmite externo |
| `5` | — | `mod-sei-pen/src/rn/ExpedirProcedimentoRN.php:33` | envio externo em processamento |

Implementado em `EstadoProtocolo`. O código do **processo anexado** existe no
SEI, é referenciado como `ProtocoloRN::$TE_PROCEDIMENTO_ANEXADO` pelo módulo
PEN, mas nenhuma das fontes locais fixa o seu literal — e por isso ele não foi
declarado.

## Códigos de `rel_protocolo_protocolo.sta_associacao`

Cruzamento das 847 associações do dump histórico com as chaves de
`procedimento` e de `documento`:

| Código | Ocorrências | Ligação | Estado dos protocolos | Leitura |
| --- | ---: | --- | --- | --- |
| `1` | 842 | sempre processo para documento | — | documento na árvore do processo |
| `3` | 5 | sempre processo para processo | ambos em `sta_estado = '0'` | processo relacionado |

O código `3` é **relacionamento e não anexação**: o processo anexado perde a
independência e muda de estado, enquanto os cinco pares observados permanecem
normais. Nenhum par possui linha recíproca, o que confirma que o vínculo é
gravado uma única vez e é direcionado, embora a tela o exiba nos dois
processos.

Implementado em `AssociacaoProtocolo`. Documento movido e processo anexado
possuem códigos próprios que o corpus local não permite fixar.

## Códigos de `participante.sta_participacao`

| Código | Ocorrências | Leitura |
| --- | ---: | --- |
| `I` | 1.438 | interessado |
| `D` | 51 | destinatário |
| `R` | 36 | remetente |
| `A` | 11 | **sem correspondência provada** |

Implementado em `ProcessoParticipacao` com os três primeiros. O DTO
`ProcessoParticipante` preserva o código bruto em `codigoParticipacao` para não
perder a informação dos registros com `A`.

## Códigos de `documento.sta_documento` e o corpo do documento

Cruzamento exato das 842 linhas de `documento` do dump histórico com
`protocolo.sta_protocolo`, `documento.sta_editor` e `documento.sin_versoes`:

| `sta_documento` | Ocorrências | `sta_protocolo` | `sta_editor` | `sin_versoes` | Leitura |
| :---: | ---: | :---: | :---: | :---: | --- |
| `I` | 535 | sempre `G` | sempre `2` | sempre `S` | documento interno, editor do SEI |
| `X` | 306 | sempre `R` | sempre `0` | sempre `N` | documento externo |
| `A` | 1 | `G` | `0` | `N` | **sem correspondência confiável** |

`I` e `X` são domínio fechado e comprovado sem exceção. `A` tem uma única
ocorrência — um documento `G` com editor `0`, sem versões e bloqueado — que
não permite atribuir significado com segurança (poderia ser gerado por
formulário em vez do editor rico). Implementado em `EstadoDocumento` só com
`interno` e `externo`; o código `A` fica como lacuna.

`documento.sta_editor` não virou enum: a correlação `'2'` = interno,
`'0'` = externo pode refletir apenas "documento externo não tem editor", não
um domínio de tipos de editor. `Documento.editor` guarda o código bruto, e é
`NOT NULL` no banco — toda escrita precisa informá-lo.

`documento_conteudo` tem exatamente 536 linhas no dump histórico, uma para
cada documento `G` (535 `I` + a 1 `A`), e zero para documentos `R`. Isso
confirma o mecanismo: o corpo HTML de um documento interno vive em
`documento_conteudo.conteudo`; um documento externo nunca tem linha ali.

O ponteiro para o arquivo de um documento externo vem de `anexo`, cruzado por
`anexo.id_protocolo = documento.id_documento`. Das 320 linhas de `anexo`, 283
têm `id_protocolo` preenchido, e todas as 283 apontam para um documento `R` —
nunca para outra coisa. Nenhum documento externo tem mais de um `anexo`
(1:1), e 23 dos 306 documentos externos não têm nenhum. As outras 37 linhas de
`anexo` (sem `id_protocolo`) pertencem a Base de Conhecimento, fora do escopo
desta leitura. `Anexo` só modela o caso de documento externo.

O byte do arquivo em si **não está no banco**: `anexo` só guarda nome,
tamanho, data e hash. `ProcessoDocumentoConteudo` expõe esse ponteiro; servir
o arquivo depende do `SeiFileRepository` da seção 9 do roteiro mestre, ainda
não implementado.

## Catálogo de `tarefa`

A Base de Referência traz 119 tarefas. As marcações que governam o estado do
processo foram conferidas diretamente no banco restaurado:

| Tarefa | `sin_fechar_andamentos_abertos` | `sin_lancar_andamento_fechado` | `sin_permite_processo_fechado` |
| --- | :---: | :---: | :---: |
| 1 — Processo gerado | S | N | N |
| 5 — Assinado documento | S | N | **S** |
| 28 — Conclusão do processo na unidade | S | **S** | N |
| 29 — Reabertura do processo na unidade | S | N | N |
| 32 — Processo remetido pela unidade | **N** | N | N |
| 41 — Conclusão automática na unidade | S | **S** | N |
| 48 — Processo recebido na unidade | S | N | N |

A linha 32 é a prova de que **enviar não conclui por si só**: a remessa não
fecha os andamentos abertos. Quem conclui na origem é a tarefa 41, lançada
apenas quando a opção de manter o processo aberto não é marcada. As duas
conclusões, 28 e 41, combinam fechar o que estava aberto com nascer já
concluídas, e por isso encerram a presença do processo na unidade.

Implementado em `TarefaCatalogo` e `TarefaSei`, com regressão em
`backend/test/integration/catalogo_repository_test.dart`.

## Código de `andamento_marcador.sta_operacao`

Cruzamento das 227 linhas de `andamento_marcador` do dump histórico:

| Código | Ocorrências | Leitura |
| --- | ---: | --- |
| `I` | 202 | inclusão do marcador no processo |
| `R` | 24 | remoção do marcador do processo |
| `A` | 1 | alteração do texto complementar |

Domínio totalmente comprovado, e coincide com a descrição do manual do usuário
para o Histórico de Marcadores: "Operação (inclusão, alteração ou remoção)".
Implementado em `OperacaoMarcador`.

O cruzamento de três colunas (`sin_ultimo`, `sta_operacao`, `sin_ativo`) revela
o mecanismo completo do histórico, que é *append-only*:

| `sin_ultimo` | `sta_operacao` | `sin_ativo` | Ocorrências | Leitura |
| :---: | :---: | :---: | ---: | --- |
| `S` | `I` | `S` | 177 | marcador em uso, linha corrente |
| `S` | `A` | `S` | 1 | texto alterado, linha corrente |
| `N` | `I` | `N` | 24 | inclusão original, superada por uma remoção posterior |
| `N` | `I` | `S` | 1 | caso isolado, não investigado |
| `N` | `R` | `N` | 24 | a própria remoção |

**Achado que não estava no roteiro original:** uma remoção real não apenas
insere uma linha nova com `sta_operacao = 'R'` — ela também **rebaixa a linha
até então corrente**, atualizando o `sin_ultimo` dela para `'N'`. Sem essa
segunda escrita, o par processo e marcador ficaria com duas linhas
`sin_ultimo = 'S'` ao mesmo tempo, o que nenhum dos 227 registros reais
apresenta. Isso foi descoberto porque o primeiro teste de
`processo_sinalizacoes_test.dart` para "marcador removido" falhou ao inserir
somente a linha de remoção: a leitura continuava enxergando a inclusão antiga
como vigente. A correção ficou registrada no próprio teste, como prova viva do
mecanismo, e deve orientar o service de remoção quando ele for implementado.

`ProcessoMarcador` lê a linha vigente filtrando `sin_ultimo = 'S'` **e**
`sin_ativo = 'S'` juntos — nenhuma linha com `sin_ultimo = 'S'` e
`sin_ativo = 'N'` foi observada, mas o filtro duplo é defensivo.

## Códigos de `bloco.sta_tipo` e `bloco.sta_estado`

Cruzamento das 113 linhas de `bloco` do dump histórico, das 83 linhas de
`rel_bloco_protocolo` e das 204 linhas de `rel_bloco_unidade`.

### `sta_tipo`

| Código | Ocorrências | Conteúdo cruzado (`rel_bloco_protocolo` → `protocolo.sta_protocolo`) | Leitura |
| --- | ---: | --- | --- |
| `A` | 95 | 77 relações, sempre com protocolo `G` (documento gerado no editor) | Assinatura |
| `I` | 16 | 5 relações, sempre com protocolo `P` (processo) | Interno |
| `R` | 2 | 1 relação, sempre com protocolo `P` (processo) | Reunião |

Cobertura de 100% dos dados observados (95 + 16 + 2 = 113), sem código
residual. O cruzamento por conteúdo é exato: nenhum bloco `A` contém
processo, e nenhum bloco `I`/`R` contém documento. As iniciais batem com as
três seções do manual do usuário — "Bloco de Assinatura", "Bloco de reunião"
e "Blocos Internos" (`backend/referencias/manuais_sei_publicos/html/SEI/Blocos.html`)
—, cuja descrição funcional confirma exatamente essa divisão de conteúdo.
Implementado em `TipoBloco`.

### `sta_estado`

| Código | Ocorrências | Cruzado com `sta_tipo` | Leitura |
| --- | ---: | --- | --- |
| `A` | 48 | 30 Assinatura, 16 Interno, 2 Reunião | Gerado |
| `D` | 64 | só Assinatura | Disponibilizado |
| `C` | 1 | só Assinatura | Concluído |

Cobertura de 100% dos dados observados (48 + 64 + 1 = 113), sem código
residual. O manual do usuário lista cinco rótulos na coluna Estado da tela
Blocos — "Podendo ser: Gerado, Disponibilizado, Recebido, Retornado e
Concluído" — mas o próprio texto do manual mostra que **"Recebido" não é um
quarto código**: é o mesmo bloco disponibilizado (`D`), rotulado como
"Recebido" quando a tela é aberta pela unidade destinatária em vez da
geradora ("os Blocos recebidos de outras unidades são identificados pelo
estado 'Recebido'"). `A` corresponde a "Gerado": o manual descreve o bloco
recém-criado, antes de qualquer disponibilização, como estando "no estado
'Gerado'" — e é exatamente o único código visto nos blocos Interno e Reunião
desta amostra, que nunca chegam a `D`/`C` nela (consistente com a seção
"Blocos Internos" do manual, que não descreve nenhuma ação de
disponibilizar para esse tipo).

**"Retornado" fica de fora, como lacuna.** Nenhuma das 113 linhas do dump
histórico grava esse estado em `bloco.sta_estado`. A única fonte de código
literal encontrada para um "estado de bloco" é
`TramiteEmBlocoRN::$TE_ABERTO = 'A'`, `$TE_DISPONIBILIZADO = 'D'`,
`$TE_RETORNADO = 'R'`, `$TE_CONCLUIDO = 'C'` e
`$TE_CONCLUIDO_PARCIALMENTE = 'P'`, em
`mod-sei-pen/src/rn/TramiteEmBlocoRN.php` — mas essa classe mapeia
`md_pen_bloco`, uma tabela **distinta** que o módulo PEN usa para trâmite em
lote (`TramiteEmBlocoDTO::getStrNomeTabela()` retorna `'md_pen_bloco'`), não
`public.bloco`. A estrutura de `md_pen_bloco` é quase idêntica à de `bloco`
(`id_unidade`, `id_usuario`, `descricao`, `idx_bloco`, `sta_tipo`,
`sta_estado`), o que sugere fortemente que os dois compartilham o mesmo
domínio de código — inclusive a coincidência dos três valores já comprovados
(`A`/`D`/`C`) — mas é evidência de tabela vizinha, não da própria coluna, e
por isso `R` (Retornado) não foi declarado em `EstadoBloco`. A hipótese mais
provável é que a devolução de um bloco seja tratada por
`rel_bloco_unidade.sin_retornado` (sempre `N` nas 204 linhas observadas, sem
nenhuma ocorrência `S` para confirmar), e não por um quarto código de
`sta_estado` — nome e propósito da coluna batem com a ação "Devolver Bloco"
do manual, mas sem linha real com `sin_retornado = 'S'` para provar o
mecanismo. Implementado em `EstadoBloco`, só com `gerado`, `disponibilizado`
e `concluido`.

As sinalizações de `rel_bloco_unidade` — `sin_prioridade`, `sin_revisao` e
`sin_comentario`, cada uma com seu par `id_usuario_*`/`dth_*` — batem
exatamente com as três sinalizações "Prioritário", "Revisado" e "Comentado"
descritas no manual, inclusive o detalhe de que passar o cursor sobre o
ícone mostra "o usuário que inseriu a sinalização... bem como a data e a
hora". Nesta amostra, `sin_revisao = 'S'` aparece em 2 das 204 linhas e
`sin_prioridade = 'S'` em 1; `sin_comentario` e `sin_retornado` são sempre
`N`. Implementado em `RelacaoBlocoUnidade`, sem enum (são apenas booleanos).

## Lacuna: `base_conhecimento` sem dado real

`base_conhecimento` e `rel_base_conhec_tipo_proced` têm **zero linhas**,
tanto na Base de Referência restaurada quanto no dump histórico local. Não
há nenhum dado real para cruzar `sta_estado` nem `sta_documento` dessa
tabela, e por isso nenhum enum foi declarado para esses dois campos:
`BaseConhecimento.estado` e `BaseConhecimento.documento` (assim como
`ProcessoBaseConhecimento.estado`/`documento`) preservam o código bruto do
banco, sem transformação, no mesmo padrão já usado para
`Acompanhamento.tipoVisualizacao` e `Anotacao.situacao`. A leitura estrutural
(`join` de `procedimento` → `rel_base_conhec_tipo_proced` →
`base_conhecimento` → `unidade`/`usuario`) foi validada contra o esquema da
Base de Referência e não apresenta ambiguidade nenhuma — a lacuna é
exclusivamente nos dois códigos de domínio de uma letra.

## Fixture transacional

A Base de Referência não pode ganhar dado sintético, mas as consultas precisam
ser exercitadas contra linhas reais. `EscopoRepositorioTeste.emTransacaoRevertida`
abre uma transação, registra a conexão dela em um contêiner-filho do Angel — de
modo que os repositórios saem das mesmas fábricas do DI de produção — e força o
`rollback` com uma exceção sentinela ao final.

Todos os mapas de escrita da fixture vêm de `toInsertMap()` das entidades do
`core` (`Protocolo`, `Procedimento`, `Atividade`, `Participante`,
`RelacaoProtocolo`, `Anotacao`, `Marcador`, `AndamentoMarcador`,
`GrupoAcompanhamento`, `Acompanhamento`, `ControlePrazo`,
`RetornoProgramado`), conforme a regra registrada em `AGENTS.md`. O contato é
reaproveitado da própria base, sem inserção sintética.

O cenário em `processo_unidades_abertas_test.dart` reproduz o comportamento
central do SEI: um processo aberto ao mesmo tempo na unidade geradora e na
recebedora, uma terceira unidade que já concluiu, um processo relacionado e
dois participantes em papéis distintos. O cenário em
`processo_sinalizacoes_test.dart` acrescenta uma anotação exclusiva da
unidade geradora, um marcador vigente, um acompanhamento especial na unidade
que já concluiu — provando que ele não exige o processo aberto ali —, um
controle de prazo interno e um retorno programado ainda não cumprido. O
último teste de cada arquivo confere que, encerrada a transação, a Base de
Referência volta exatamente ao estado anterior.

## SIP — autorização por recurso, e a correção sobre autenticação

Investigação do esquema de autenticação/autorização do SIP (`sip_5_0_0`),
motivada pelo requisito "Autenticação e autorização por recurso do SIP"
citado como pendência da Entrega E2 em `roteiro_mestre_sei_dart_mod_pen.md`.
A conclusão delimita a fronteira entre o que é possível implementar contra a
Base de Referência local e o que depende de infraestrutura externa.

**Correção de um erro deste documento.** A primeira versão desta seção
concluía que "o SEI real delega toda verificação de identidade a um LDAP/AD
externo por órgão", com base em `sip_5_0_0.usuario` não ter nenhuma coluna
de credencial (`id_usuario, id_orgao, id_origem, sigla, nome, sin_ativo,
cpf, nome_registro_civil, nome_social, email, sin_bloqueado,
dth_pausa_2fa`) e em `servidor_autenticacao` ter 2 linhas de exemplo com
`sta_tipo = 'AD'`. Isso foi longe demais: `sip_5_0_0.usuario` é a tabela de
**autorização** do SIP (concede perfil/permissão por unidade), não a tabela
de login do SEI — não ter senha ali não significa que o SEI não tenha senha
em lugar nenhum. `sei_5_0_0.usuario` (o banco da aplicação, não o do SIP)
tem coluna própria `senha character(60)` — 60 caracteres é exatamente o
tamanho de um hash bcrypt (`$2y$10$...`), o formato que `password_hash()` do
PHP produz por padrão, consistente com o SEI ser escrito em PHP. O manual
público de instalação do SEI ("6. Integração LDAP/AD",
softwarepublico.gov.br) confirma que a integração é **opcional** — "o SIP
permite integração com OpenLDAP e/ou ActiveDirectory" — e que, quando vários
servidores estão configurados, a tentativa segue a ordem da lista até um
funcionar; o próprio roteiro de configuração do LDAP pede para logar antes
"com o usuário e senha teste", ou seja, login local por usuário e senha é o
mecanismo padrão/de base, e LDAP/AD é uma integração por órgão sobre ele, não
um substituto obrigatório. Isso também bate com o manual do usuário já lido
nesta base (`Iniciando_operacoes.html`): "informar seu login, senha e – no
caso de instalações multiórgão – o órgão ao qual está vinculado". As 2 linhas
de `servidor_autenticacao` com `sta_tipo = 'AD'`, endereço
`hostnamedoservidor.dominio.gov.br` e nome `Exemplo_Conexao_AD_1/2` são
exemplos deixados pelo instalador de referência, não prova de que AD seja
obrigatório.

**Fronteira de escopo, sem mudar.** A conclusão errada não muda a decisão
prática desta rodada: autenticação (validar credencial, abrir sessão, trocar
unidade ativa) continua fora de escopo aqui, porque `sei_5_0_0` é tratado
como Base de Referência somente leitura neste projeto e a coluna `senha` não
foi — e não deve ser — usada para implementar login contra ela. A correção é
sobre a **razão**: não é porque o SEI real dependa de LDAP/AD externo
inexistente neste laboratório, é porque autenticação de fato é um mecanismo
próprio do SEI (`sei_5_0_0.usuario.senha`, hash local, com LDAP/AD como
integração opcional por órgão) que está fora do escopo desta rodada por
decisão de projeto, não por impossibilidade técnica. O que **é** implementável
e testável com dado real, sem depender de login algum, é a metade de
**autorização**: dado um `id_usuario` e um `id_unidade` já resolvidos por
outro mecanismo (hoje, o contexto de desenvolvimento não autenticado do
projeto), resolver quais perfis estão vigentes e quais recursos
(telas/ações) esses perfis liberam. É isso que
`SipReferenciaRepository.resolverAutorizacao` faz.

**Esquema usado, confirmado por `\d` direto no banco:**

- `permissao(id_perfil, id_sistema, id_usuario, id_unidade,
  id_tipo_permissao, dta_inicio, dta_fim, sin_subunidades)`, PK composta
  `(id_perfil, id_sistema, id_unidade, id_usuario)`. **8 linhas reais** na
  Base de Referência, todas para `id_usuario = 100000001` e
  `id_unidade = 110000000` (o órgão raiz), `dta_fim` sempre nulo (sem
  expiração) e `sin_subunidades` sempre `'N'`. Das 8, 3 são do sistema SIP
  (`id_sistema = 100000099`) e 5 do sistema SEI (`id_sistema = 100000100`).
- `tipo_permissao(id_tipo_permissao, descricao)` — catálogo de 3 linhas com a
  própria `descricao` documentando o significado (`1 = Não Delegável`,
  `2 = Delegável`, `3 = Delegável uma vez`), diferente dos códigos de uma
  letra do restante deste documento. Como o banco documenta o domínio na
  própria coluna, foi declarado `TipoPermissao` com confiança total, sem
  lacuna. As 8 linhas reais de `permissao` usam sempre `id_tipo_permissao = 1`.
- `perfil(id_perfil, id_sistema, nome, descricao, sin_coordenado, sin_ativo,
  sin_2_fatores)`, PK composta `(id_perfil, id_sistema)` — o mesmo número de
  perfil pode existir em mais de um sistema com significado independente.
- `recurso(id_sistema, id_recurso, nome, descricao, caminho, sin_ativo)`, PK
  composta `(id_recurso, id_sistema)`. **1.578 linhas** na Base de
  Referência: 234 do sistema SIP e 1.344 do sistema SEI. `caminho` guarda o
  identificador funcional usado pela tela para checar acesso (ex.:
  `controlador.php?acao=sistema_cadastrar`), herdado do SEI em PHP.
- `rel_perfil_recurso(id_perfil, id_sistema, id_recurso)` — vínculo N:N entre
  perfil e recurso, PK composta pelas 3 colunas. **2.790 linhas** na Base de
  Referência. Não tem DTO de catálogo próprio: é usada só como ponte no
  `join` que resolve recursos liberados.

**Resultado para o único usuário com permissão real na Base de Referência**
(`id_usuario = 100000001`, `id_unidade = 110000000`, o órgão raiz): 8 perfis
vigentes e **1.544 recursos distintos** liberados por eles, combinando os
dois sistemas (recursos podem se repetir entre perfis do mesmo sistema, daí
a deduplicação por `DISTINCT` na consulta). Filtrando só pelo sistema SEI
(`id_sistema = 100000100`), restam 5 perfis e 1.314 recursos. Nenhuma outra
unidade da Base de Referência tem linha em `permissao`.

**"Vigente" é a janela de tempo, não o `sin_ativo` do catálogo.** Um perfil
está vigente quando `dta_inicio <= agora` e (`dta_fim IS NULL` ou
`dta_fim >= agora`). Isso é independente do `perfil.sin_ativo` do cadastro —
os dois campos não têm relação entre si, por isso `PerfilAtivo.perfil.ativo`
preserva o `sin_ativo` bruto sem usá-lo para filtrar a vigência. Como as 8
linhas reais foram gravadas em 2016 sem `dta_fim`, a janela está sempre
aberta nos dados de teste, mas a regra foi implementada com a comparação
completa (não apenas "sem `dta_fim`"), usando `LOCALTIMESTAMP` do próprio
banco para a comparação, e não o relógio do processo Dart.

Implementado em `PerfilSip`, `RecursoSip`, `PerfilAtivo`, `AutorizacaoUsuario`
e `TipoPermissao` (core), com leitura em
`SipReferenciaRepository.resolverAutorizacao` e exposição em
`GET /api/v1/sip/usuarios/:idUsuario/autorizacao`. Sem N+1: as duas consultas
(perfis, recursos) são únicas cada uma, com `join` direto entre as tabelas
acima — nenhuma delas é grande o suficiente para exigir análise adicional de
índice (a maior, `rel_perfil_recurso`, tem 2.790 linhas).

## Lacunas que permanecem

- **Condição canônica de sobrestado.** O manual afirma que processos
  sobrestados não aparecem no Controle de Processos, mas a expressão SQL que os
  identifica ainda não foi comprovada. O filtro não foi inferido nem
  implementado.
- **Níveis de acesso.** Apenas o código `0`, público, é distinguível: ele
  responde por 1.228 dos 1.481 protocolos. Os códigos `1` e `2` aparecem sem
  hipótese legal associada no dump histórico, o que impede separar restrito de
  sigiloso com segurança. Somente `Protocolo.nivelAcessoPublico` foi declarado.
- **Semântica de `procedimento.dta_conclusao`.** Existe uma data de conclusão
  no nível do procedimento, distinta das conclusões por unidade. Quando ela é
  gravada e como se relaciona com o início da temporalidade não está provado.
- **Código do processo anexado** em `sta_estado` e em `sta_associacao`.
- **Significado de `participante.sta_participacao = 'A'`.**
- **Valores de `atividade.tipo_visualizacao`.** A distribuição observada é `0`
  com 4.301 linhas, `1` com 500, `3` com 22 e `2` com 7; o significado de cada
  uma não está documentado nas fontes locais. `Atividade.tipoVisualizacaoPadrao`
  registra apenas o valor mais frequente.
- **Significado de `anotacao.sta_anotacao`.** As 58 linhas do dump histórico só
  mostram o código `U`, sem descrição no manual do usuário. `Anotacao` carrega
  o código bruto sem transformá-lo em enum.
- **Domínio de `acompanhamento.tipo_visualizacao`.** Só os códigos `0` (56
  linhas) e `2` (2 linhas) aparecem nos dados reais, insuficientes para um
  domínio fechado. `Acompanhamento` carrega o código bruto.
- **Cálculo de `acompanhamento.idx_acompanhamento`.** É o índice de busca
  textual sobre `observacao`, mantido pelo próprio SEI; a regra de
  normalização não está comprovada e a entidade não a grava.
- **Ponto de Controle.** As tabelas `situacao` e `andamento_situacao` têm
  esquema claro (a segunda é histórico com `sin_ultimo`, no mesmo padrão de
  `andamento_marcador`), mas zero linhas tanto na Base de Referência quanto no
  dump histórico. Sem nenhuma linha real para cruzar, este recurso ficou fora
  desta etapa.
- **Estado "Retornado" de `bloco.sta_estado`.** O manual descreve cinco
  rótulos de estado, mas os dados reais só comprovam três códigos
  (`A`/`D`/`C`); nenhuma linha do dump histórico grava um quarto código. A
  hipótese — devolução tratada por `rel_bloco_unidade.sin_retornado` — não
  tem nenhuma ocorrência `S` para confirmá-la.
- **`base_conhecimento.sta_estado` e `sta_documento`.** Zero linhas na Base
  de Referência e no dump histórico; sem enum, código bruto preservado.
- **`usuario.sta_tipo`.** A Base de Referência local só mostra `'0'` (o
  usuário de teste) e `'1'` (as 4 contas de sistema SEI/SIP/INTRANET/
  INTERNET). Cruzado contra o dump histórico
  (`backend/referencias/backup_sei_bd/sei.sql`, `INSERT INTO usuario`, 1071
  linhas, parseado com script Python ad-hoc em LATIN1): a distribuição real
  é `'0'` (1059), `'1'` (5, as mesmas contas de sistema), `'2'` (1) e `'3'`
  (6). Cruzando com a presença de `senha`: toda linha `'0'`/`'1'` tem
  `senha` vazia; toda linha `'2'`/`'3'` tem `senha` preenchida (hash bcrypt
  real, formato `$2a$12$...`), sem exceção nas 1071 linhas. Essa correlação
  é forte e reforça que o login local por senha é real, mas não prova o
  significado de cada dígito individualmente — por que `'0'` e não `'1'`
  para a maioria dos usuários sem senha, ou `'2'` e não `'3'` para quem tem
  senha. `Usuario.staTipo` (`core/lib/src/models/usuario.dart`) permanece um
  `String` opaco, sem enum; usuários criados pelo cadastro implementado em
  19 de agosto de 2026 usam `Usuario.staTipoComSenhaLocal = '2'` como
  padrão, por ser um dos dois valores que na amostra completa sempre têm
  senha preenchida — nunca `'0'`/`'1'`, que jamais aparecem com senha.
