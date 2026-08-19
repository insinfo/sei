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
