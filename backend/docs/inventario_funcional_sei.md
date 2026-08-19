# Inventário funcional do SEI

Este documento consolida o que cada recurso do SEI faz, como se comporta e onde
esse comportamento está provado no corpus local do repositório. Ele é a
contraparte funcional de `arquitetura_backend.md` e de
`roteiro_mestre_sei_dart_mod_pen.md`.

Toda afirmação traz a fonte local entre parênteses. Onde o corpus não prova, a
seção final registra a lacuna explicitamente. Nada aqui foi inferido de manuais
de terceiros.

## Corpus analisado

| Fonte | O que fornece |
| --- | --- |
| `referencias/manuais_sei_publicos/html/SEI/` | Manual do Usuário SEI 4.0+, 11 capítulos. Comportamento de tela. |
| `referencias/manuais_sei_publicos/html/SEIADM/` | Manual do Administrador: estrutura organizacional, permissões, contatos. |
| `referencias/sei-db-ref-executivo/postgresql/v5.0.0/` | Base de Referência oficial 5.0.0 (SEI + SIP): esquema, catálogo de tarefas, parâmetros, recursos, perfis. |
| `referencias/mod-sei-pen/src/` | Código PHP do módulo Tramita.GOV.BR: máquina de estados, workers, recibos. |
| `docs/inventario_schema_sei_5_0_0.csv` | 194 tabelas funcionais classificadas, com FKs e paridade PostgreSQL/MySQL. |
| `docs/evidencias_controle_processos.md` | Regras já comprovadas de Recebidos x Gerados. |

## 1. As seis perguntas críticas

### 1.1 Processo aberto em duas unidades ao mesmo tempo

O processo é único, mas o estado "aberto" não pertence a ele. Pertence ao par
`(processo, unidade)` e é gravado como uma linha em `atividade` com
`dth_conclusao IS NULL`. Duas linhas abertas significam processo aberto em duas
unidades.

```sql
CREATE TABLE public.atividade (
    id_atividade integer NOT NULL,
    id_protocolo bigint NOT NULL,
    id_unidade integer NOT NULL,
    ...
    dth_abertura timestamp without time zone NOT NULL,
    dth_conclusao timestamp without time zone,
    sin_inicial character(1) NOT NULL,
    ...
);

CREATE INDEX i03_atividade ON public.atividade
    USING btree (dth_conclusao, id_unidade, sin_inicial);
```

É por isso que a tela do processo exibe, abaixo dos ícones, "as unidades nas
quais o processo está aberto" (`Iniciando_operacoes.html`, Tela do Processo).
O `ProcessoUnidadesAbertasComponent` previsto no roteiro mestre é literalmente
essa consulta.

Existem quatro caminhos, com semânticas distintas:

| Caminho | Abre atividade na outra unidade? | Aparece no Controle de Processos dela? |
| --- | --- | --- |
| Envio a várias unidades | sim | sim |
| "Manter processo aberto na unidade atual" | mantém a da origem | sim, nas duas |
| Bloco de Assinatura / Reunião | não | não |
| Acompanhamento Especial | não | não |

Mecanismo interno do envio, comprovado no catálogo `tarefa`:

- tarefa 32 `Processo remetido pela unidade @UNIDADE@` tem
  `sin_fechar_andamentos_abertos = 'N'`. Enviar, por si só, não conclui.
- tarefa 41 `Conclusão automática de processo na unidade` tem
  `sin_fechar_andamentos_abertos = 'S'` e `sin_lancar_andamento_fechado = 'S'`.
  É ela que conclui, e só é lançada quando "Manter processo aberto" não é
  marcada.

Consequências:

- Minutas não atravessam unidades. Um documento interno não assinado é visível
  apenas na unidade geradora, mesmo com o processo aberto na outra. Só bloco
  resolve.
- Tempo é contado por unidade. `estatisticas` tem `tempo_aberto`,
  `dth_abertura` e `dth_conclusao` por `(id_procedimento, id_unidade)`.
- O filtro "Linha Direta" existe para reduzir ruído da árvore quando muitas
  unidades atuam em paralelo.
- Envio simultâneo só é recomendado quando as atividades das unidades forem
  independentes entre si.

### 1.2 O que significa processo concluído

Não é status do processo. É `dth_conclusao` preenchido na atividade daquela
unidade, com lançamento da tarefa 28 `Conclusão do processo na unidade`.

Texto literal do manual: "a conclusão do processo em uma unidade não acarreta
sua conclusão nas outras unidades em que esteja aberto".

- Reversível a qualquer momento pela tarefa 29 `Reabertura do processo na
  unidade`, em qualquer unidade por onde tramitou, sem novo trâmite.
- O processo reaberto é atribuído automaticamente a quem reabriu.
- Pode ser feito em lote pelo Controle de Processos.
- O processo continua localizável por Pesquisa, Acompanhamento Especial, Blocos
  Internos e Estatísticas.
- Para de contar tempo naquela unidade; segue contando nas demais.
- Para simples consulta não se deve reabrir.

Reabertura Programada (4.1) é recurso distinto: agenda a volta do processo à
mesa da origem e só fica disponível se "Manter processo aberto" **não** for
marcada. Tabela `reabertura_programada`.

### 1.3 Concluir versus arquivar

São eixos diferentes do sistema. No SEI 5.0.0 de referência o arquivamento é
nativo, mas fica em outro menu, com outro perfil e outra tabela.

| Eixo | Concluir | Arquivar |
| --- | --- | --- |
| Grava | `atividade.dth_conclusao` | linha em `arquivamento` com `id_localizador`, `sta_arquivamento` |
| Escopo | uma unidade | o protocolo, num localizador físico |
| Recurso SIP | `procedimento_concluir` | `arquivamento_arquivar` |
| Perfil | Básico | Arquivamento |
| Menu | ícone do processo | Arquivo > Arquivamento / Desarquivamento / Localizadores |
| Reversão | Reabrir Processo | `arquivamento_solicitar_desarquivamento` -> `arquivamento_desarquivar` |
| Prazo de guarda | não toca | `assunto.prazo_corrente`, `prazo_intermediario`, `sta_destinacao` |

A descrição oficial do perfil 100000941 é "Acesso aos recursos específicos para
quem trabalha com arquivamento de vias físicas de documentos", e os andamentos
falam em "Arquivado documento @DOCUMENTO@ no localizador @LOCALIZADOR@"
(tarefa 24). No núcleo, arquivar é guardar o suporte físico num endereço.

A destinação do processo eletrônico corre por outro caminho, também nativo:
menu Avaliação Documental (Avaliação / Revisão) e Arquivo > Documentos para
Eliminação / Editais de Eliminação, com as tarefas 130 a 133 e os campos
`procedimento.dta_eliminacao` e `protocolo.sin_eliminado`.

### 1.4 Concluir e arquivar ao mesmo tempo

Não em uma operação. A lista completa de 1.462 recursos do SIP não contém
nenhum recurso combinado. Existem `procedimento_concluir` (perfil Básico, sobre
a atividade) e `arquivamento_arquivar` (perfil Arquivamento, sobre o protocolo e
um localizador). São telas e responsáveis diferentes.

### 1.5 PDF do processo: síncrono ou agendado

Síncrono e imediato. Duas evidências independentes:

1. O recurso é `procedimento_gerar_pdf -> controlador.php?acao=procedimento_gerar_pdf`,
   ação direta do controlador; o mesmo vale para `procedimento_gerar_zip`.
2. `infra_agendamento_tarefa` na Base de Referência tem exatamente dez jobs, e
   geração de PDF/ZIP não é um deles (lista completa na seção 8).

Comportamento estabelecido pelo manual:

- O usuário escolhe quais documentos entram no arquivo.
- Não são convertidos: imagens, som, arquivos compactados, documentos cancelados
  e minutas de documentos de outras unidades.
- É necessário desabilitar o bloqueador de pop-ups.
- Gerar Arquivo ZIP é a alternativa que preserva os formatos originais.

O corpus local não comprova o timeout de 300 s nem o limite de anexos citados em
fóruns de terceiros. Prova apenas a natureza síncrona. Para o backend Dart, isso
significa que tornar a consolidação assíncrona é uma melhoria consciente, não uma
reprodução do SEI, e deve ser registrada como divergência intencional.

### 1.6 Duplicação de processo

Texto literal do manual: "O sistema duplica os documentos selecionados, à
exceção de minutas e e-mails; gera um novo número de processo e novas numerações
para os documentos; o processo gerado e os documentos que o compõem são criados
sem as assinaturas, as ciências e o acompanhamento especial, se houver."

- Pede-se o interessado e a seleção dos documentos.
- Há a opção "Manter as associações com os processos relacionados".
- Minutas e e-mails nunca são duplicados, nem os da própria unidade.
- Todos os documentos copiados precisam ser reassinados.

## 2. O modelo que explica quase tudo

```text
        procedimento            protocolo             documento
      (tipo, prioridade)  <--  (NUP, nivel de   -->  (serie, minuta
                                acesso, estado)        ou assinado)
                                     |
                                     v
                                 atividade
                    uma linha por (protocolo, unidade, evento)
                    dth_abertura | dth_conclusao | sin_inicial
                                     |
                                     v
                                   tarefa
                       catalogo de ~120 tipos de andamento
```

### Flags de `tarefa` que governam o comportamento

| Coluna | Efeito | Exemplo revelador |
| --- | --- | --- |
| `sin_fechar_andamentos_abertos` | fecha as atividades abertas da unidade | tarefa 32 tem `N`: enviar não conclui |
| `sin_lancar_andamento_fechado` | o andamento nasce concluído | tarefa 41 tem `S`: é ela que conclui no envio |
| `sin_permite_processo_fechado` | evento permitido com processo concluído | tarefas 5, 34, 38: assinar e blocos funcionam em processo concluído |
| `sin_historico_resumido` / `sin_historico_completo` | define em qual visão do histórico aparece | separa as visões resumida, completa e total |

### Estados de `protocolo.sta_estado`

| Constante | Significado |
| --- | --- |
| `TE_NORMAL` | estado corrente |
| `TE_PROCEDIMENTO_ANEXADO` | processo perdeu independência ao ser anexado |
| `TE_PROCEDIMENTO_BLOQUEADO = '4'` | em trâmite externo PEN, somente leitura |
| `TE_PROCEDIMENTO_EM_PROCESSAMENTO = '5'` | envio externo em andamento |
| `TE_DOCUMENTO_CANCELADO` | documento cancelado, sem conteúdo acessível |

Fonte: `mod-sei-pen/src/rn/ExpedirProcedimentoRN.php:32-33` e
`ProcessoEletronicoRN.php:1842`; tarefas 122 e 123.

### Recebidos e gerados

`atividade.sin_inicial = 'S'` para gerados, `'N'` para recebidos, sempre com
`dth_conclusao IS NULL` e filtro pela unidade. O índice `i03_atividade` existe
para essa consulta. Um processo que volta à unidade geradora entra como
recebido: classificar pela unidade geradora do protocolo produz resultado
errado (`docs/evidencias_controle_processos.md`).

## 3. Ciclo de vida do processo

| Recurso | Comportamento | Limitação |
| --- | --- | --- |
| Iniciar Processo (`procedimento_gerar`) | assunto automático pelo tipo; protocolo automático ou informado com máscara `#####.######/####-##`; Prioridade desde a 4.1 (PcD, idoso 60-80, idoso 80+, doença grave, ECA, licença ambiental) | tipo inexistente exige gestão documental; NUP e data de autuação não editáveis |
| Receber Processo | clicar no número em vermelho; registra hora, unidade e usuário | cor é da sessão, não é status persistente |
| Enviar Processo (`procedimento_enviar`) | várias unidades; e-mail de notificação; Retorno Programado; Reabertura Programada; manter aberto; remover anotação | sem "manter aberto" conclui na origem; Reabertura Programada e "manter aberto" são mutuamente exclusivas |
| Atribuir Processo | individual ou em lote; filtro "atribuídos a mim"; tela de redistribuição | não restringe outros usuários da unidade; invisível a outras unidades |
| Concluir Processo | individual ou em lote; para a estatística da unidade | só naquela unidade; não arquiva; não encerra prazo de Retorno Programado |
| Reabrir Processo | sem novo trâmite; atribui a quem reabriu | só em unidade por onde tramitou |
| Reabertura Programada | data certa ou dias úteis/corridos; roda no agendamento 00:01 e 01:01 | única operação processual efetivamente assíncrona do núcleo |
| Sobrestar Processo | Somente Sobrestar ou vinculando a outro processo; motivo obrigatório; menu próprio | exige processo aberto apenas na unidade; some do Controle de Processos |
| Relacionar Processos | vínculo bidirecional; Iniciar Processo Relacionado | não tramitam juntos, sem hierarquia; só a unidade que criou desfaz |
| Anexar Processo | anexado vira acessório na árvore do principal; relacionamentos mantidos | cinco regras de anexação; anexado não recebe nem assina documento; anexado Restrito estende restrição ao principal; só administrador desanexa (`procedimento_desanexar`) |
| Duplicar Processo | copia documentos selecionados; pode herdar relacionamentos | novo NUP; sem assinaturas, ciências, acompanhamento; sem minutas e e-mails |
| Excluir Processo | permite excluir documentos excluíveis antes | andamento aberto somente na unidade geradora e processo sem documentos |
| Ciência | processo ou documento; lista quem deu ciência | não pode ser cancelada nem anulada |
| Atualizar Andamento | texto livre, individual ou em lote | não pode ser editado nem excluído; corrige-se com novo registro |
| Retorno Programado | data ou dias; calendário; prazos em cascata | só determina prazo; concluir não encerra a contagem, só o envio de volta; alteração só prorroga |
| Controle de Prazos | data, dias ou concluído; em lote; lista por ano | interno da unidade; outras unidades não veem |
| Plano de Trabalho (4.1) | etapas e itens com seis situações; incluir documento move o item para "em andamento" | criado só por administrador; não bloqueia nenhuma ação |
| Ponto de Controle | fases em lote; tabelas e gráficos; histórico | fases cadastradas pelo administrador; se não removido antes de concluir ou enviar, continua nos gráficos |

## 4. Documentos e editor

| Recurso | Comportamento | Limitação |
| --- | --- | --- |
| Documento interno | texto inicial: nenhum, Documento Modelo (Favoritos) ou Texto Padrão | enquanto não assinado é minuta, invisível fora da unidade geradora |
| Documento em lote (`documento_gerar_multiplo`) | mesmo documento em vários processos, opcionalmente já em bloco | mesmo tipo, texto inicial e nível de acesso para todos |
| Documento externo | nato-digital ou digitalizado; Tipo de Conferência; flag "Para Arquivamento" | upload até 200 MB (`SEI_TAM_MB_DOC_EXTERNO`); extensões restritas por cadastro |
| Editar Conteúdo | imagens, links, AutoTexto, estilos, referências a processo/documento | assinado só é editável com caneta amarela; editar depois exige reassinar |
| Versões | nova versão a cada gravação; visualizar, recuperar e comparar duas versões | só documentos internos |
| Assinar | senha ou certificado digital; quantas assinaturas forem necessárias | assinatura de outra unidade exige Bloco de Assinatura; caneta preta trava a edição |
| Autenticar externo | senha ou certificado; tarja exibível | só formato "Digitalizado nesta Unidade" com conferência "Cópia Autenticada Administrativamente"; só unidades protocoladoras |
| Excluir documento | conteúdo vai para a Lixeira desde a 5.0 | três situações permitidas apenas (não assinado; assinado com caneta amarela; externo não tramitado e não visualizado) |
| Cancelar documento | permanece na árvore, esmaecido, com motivo | só unidade geradora; ícone só aparece quando excluir já não é possível; não entra no PDF |
| Mover documento externo | exige motivo; registrado no andamento dos dois processos | documentos internos não são movidos, só referenciados por link |
| Ordenar Árvore | mover acima/abaixo | processos volumosos aglutinam em pastas (`SEI_NUM_MAX_DOCS_PASTA = 20`) |
| Gerar PDF / ZIP | seleção de documentos; ZIP preserva formatos | síncrono; não converte imagem, som, compactado, cancelado, minuta de outra unidade |
| Publicar / Agendar | imediata ou agendada; resumo obrigatório; Gerar Publicação Relacionada | perfil Publicador em Unidade Publicadora; publicação efetivada não pode ser excluída nem cancelada; confirmação roda no agendamento 00:00 e 01:00 |
| Gerar Circular | um documento por destinatário a partir dos Contatos, com bloco de assinatura e envio por e-mail | exige "Permite Destinatários" no tipo; destinatário sem e-mail não recebe |
| Correspondência eletrônica | anexa arquivos ou documentos; Texto Padrão e Grupos de E-mail; o e-mail passa a compor a árvore | sem e-mail cadastrado na unidade o envio é impossível |
| Comentários | visíveis a outras unidades com acesso; vários por protocolo | não compõem instrução; comentário em minuta só é visto na unidade até a assinatura; exclusão não deixa histórico |
| Lixeira (5.0) | download pelo próprio usuário que excluiu | 45 dias (`SEI_NUM_DIAS_LIXEIRA`), limpa às 00:02 |

## 5. Blocos

| Bloco | Contém | A outra unidade pode | Regras |
| --- | --- | --- | --- |
| Assinatura | documentos de um ou vários processos | visualizar, editar minuta e assinar, em lote | Incluir -> Disponibilizar -> Devolver; "Incluir e Disponibilizar" junta os passos; unidades em branco vira assinatura em lote interna; editar só sem nenhuma assinatura; só blocos não assinados podem ser excluídos |
| Reunião | processos | somente visualizar, inclusive minutas | não edita, não inclui, não assina; não significa que o processo tramitou pela unidade, mas ela passa a localizá-lo pela Pesquisa mesmo restrito |
| Interno | processos | nao se disponibiliza | organização e acompanhamento de atualizações; exige o processo aberto na unidade no momento da inclusão; sem ícone no processo, informação fica no Histórico |

Comuns aos três: estados Gerado, Disponibilizado, Recebido, Retornado e
Concluído (`bloco.sta_estado`), com reabertura para reutilização; sinalizações
Prioritário, Revisado e Comentado; atribuição a usuário; Grupos de Bloco
compartilhados entre os três tipos; limite de 1000 protocolos por bloco
(`SEI_NUM_MAX_PROTOCOLOS_BLOCO`). A tela "Selecionar Bloco" exibe blocos
internos e de reunião juntos.

Bloco Interno organiza e exige o processo aberto na unidade. Acompanhamento
Especial monitora e funciona com o processo em qualquer lugar. O mesmo processo
pode estar nos dois.

## 6. Organização, acompanhamento e recuperação

| Recurso | Comportamento | Limitação |
| --- | --- | --- |
| Acompanhamento Especial | público, restrito já tramitado ou sigiloso com credencial; grupos; observação pesquisável; lote; vários por processo | não abre o processo e não registra andamento; inclusão processo a processo |
| Marcadores | 32 cores; texto até 500 caracteres (4.1); vários por processo; histórico completo; filtro "Ver por marcadores" | só na unidade que criou; só valem com o processo aberto na unidade; marcador usado não pode ser excluído, só desativado |
| Anotações | simples ou com prioridade; em lote | visíveis só na unidade que inseriu; nunca tramitam; "Remover anotação" no envio evita que reapareça no retorno |
| Favoritos | documento como modelo reutilizável; grupos de favoritos | processo em Favoritos não serve de modelo |
| Textos Padrão | formatação e variáveis do sistema; usável como texto inicial, AutoTexto e em e-mail | escopo da unidade, qualquer usuário dela altera |
| Pesquisa | quatro fontes (cadastro, editor, OCR, texto); operadores aspas, `*`, E, OU, NÃO; Salvar Pesquisa | sigilosos nunca recuperados; restritos fora das unidades só pela Pesquisa Rápida, sem conteúdo; indexação leva minutos; documento não assinado só é achado na unidade que o produziu |
| Estatísticas | Unidade, Desempenho de Processos e Arquivamento; flag "considerar apenas concluídos"; drill-down "Detalhar por Unidade" | minutas contam como documentos gerados |
| Painel de Controle | nove blocos configuráveis; números clicáveis; pode ser página inicial; Painel em Números (4.1) | configuração por unidade |
| Relatório de Atividades na Unidade (4.1) | por usuário e período, em Totais ou Detalhado | menu Relatórios |
| Histórico | resumido, completo e total, governados pelas flags de `tarefa` | registros de andamento não são editáveis |

## 7. Acesso, sigilo e credenciais

| Nível | Quem enxerga | Comportamento |
| --- | --- | --- |
| Público | todos os usuários do órgão | documentos assinados visíveis a qualquer usuário; é o padrão |
| Restrito | unidades por onde tramitou | hipótese legal obrigatória; recuperável por Pesquisa Rápida fora dessas unidades, só árvore e andamento |
| Sigiloso | usuários credenciados | não tem trâmite unidade a unidade; exige senha a cada acesso; tipo precisa ser habilitado pelo administrador |

Marcar um documento como Restrito ou Sigiloso propaga o nível para todo o
processo. Anexar processo Restrito estende a restrição ao principal.

Credenciais:

- Credencial de Acesso: conceder, cassar, renovar, transferir, renunciar. Quem
  recebe pode conceder a outros.
- Renovar credencial em processo concluído reabre o processo automaticamente.
- Credencial cassada não se renova; concede-se outra.
- Não se cassa credencial concedida ao mesmo usuário em outra unidade; ali ele
  precisa renunciar.
- Não se renuncia sendo o único com acesso.
- Credencial de Assinatura dá acesso ao conteúdo do processo. Cassá-la não
  retira a credencial de acesso.
- Relatório "Acervo de Processos Sigilosos na Unidade" exige o perfil
  100000949; ativa e cancela credenciais em lote e gera planilha.

Autenticação em dois fatores por app TOTP, com e-mail pessoal de confirmação e
link válido por 60 minutos. Há SSO e login gov.br para externos.

## 8. Contatos, grupos, modelos e Base de Conhecimento

### Contatos

Cadeia de dependência estabelecida no manual do administrador: Contato depende
de Categoria, Tipo de Contato e Cargo; Cargo depende de Vocativo, Título e
Tratamento. Vocativo não tem tela própria, cadastra-se dentro de "Novo Cargo".

Cada Tipo de Contato define as unidades administradoras e o escopo de consulta:
completa em todas as unidades, resumida em todas, ou completa apenas em unidades
escolhidas (`tipo_contato`, `rel_unidade_tipo_contato`). Todas as seis
classificações têm cadastrar, alterar, desativar (reversível) e excluir
(irreversível).

### Grupos

| Onde | Tipos | Escopo |
| --- | --- | --- |
| Menu Grupos | Contatos, E-Mail, Envio, Federação | unidade |
| Administração > Grupos Institucionais | Contatos, E-Mail, Envio, Federação | institucional |
| Blocos > Listar Grupos | Grupos de Bloco | comuns aos três tipos de bloco |
| Acompanhamento Especial > Listar Grupos | Grupos de Acompanhamento | unidade |
| Favoritos > Grupos | Grupos de Favoritos | unidade |

`grupo_contato`, `grupo_email` e `grupo_unidade` têm a mesma forma: `id_unidade`,
`nome`, `descricao`, `sta_tipo`, `sin_ativo`. Grupo de Envio agrupa unidades para
tramitar em um clique.

### Modelos de documento

| Camada | Quem cria | O que é |
| --- | --- | --- |
| Administração > Editor (Modelos, Estilos, Tarjas) | administrador | estrutura HTML do tipo de documento, com seções editáveis e não editáveis (`modelo`, `secao_modelo`, `conjunto_estilos`, `tarja_assinatura`) |
| Favoritos (Documento Modelo) | qualquer usuário | documento inteiro salvo como base (`protocolo_modelo`) |
| Textos Padrão | usuário da unidade | fragmento com variáveis (`texto_padrao_interno`) |

Cada tipo de documento (`serie`) carrega as flags do formulário:
`sin_interessado`, `sin_destinatario`, `sta_numeracao`,
`sin_assinatura_publicacao`, `sta_aplicabilidade`, `sin_interno`,
`sin_usuario_externo`, `sin_valor_monetario`.

### Base de Conhecimento

Descreve as etapas de um tipo de processo, não de um processo individual.
Aceita conteúdo rico com referências e um PDF anexo.

Ciclo com versionamento explícito: criar, editar conteúdo, Liberar Versão e,
para mudar, Nova Versão do Procedimento. Há Cancelar Liberação de Versão
(`base_conhecimento.sta_estado`, `id_base_conhecimento_agrupador`,
`id_base_conhecimento_origem`). Consultável por todas as unidades por
palavra-chave ou pelo ícone ao lado do número do processo. "Minha Base" lista
apenas os procedimentos da unidade criadora. Associação N:N em
`rel_base_conhec_tipo_proced`.

## 9. Arquivo e gestão documental

| Recurso | Onde | O que faz | Estrutura |
| --- | --- | --- | --- |
| Arquivamento | Arquivo > Arquivamento | arquivar em localizador, receber documento para arquivamento, cancelar recebimento, migrar localizador | `arquivamento` (`id_localizador`, `sta_arquivamento`, `sta_eliminacao` e as atividades correspondentes) |
| Desarquivamento | Arquivo > Desarquivamento | solicitar, efetivar, cancelar solicitação | tarefas 26, 55, 56 |
| Localizadores | Arquivo > Localizadores | endereçamento físico; etiquetas, inclusive PDF; lista de protocolos | `localizador`, `tipo_localizador`, `lugar_localizador`, `tipo_suporte` |
| Avaliação Documental | Avaliação Documental > Avaliação / Revisão | avaliar classificação e revisar | `avaliacao_documental`, `revisao_avaliacao`, `assunto_proxy`, `mapeamento_assunto` |
| Eliminação | Arquivo > Documentos para Eliminação / Editais de Eliminação | montar edital, incluir e retirar processos, desarquivar para eliminação, eliminar | `edital_eliminacao`, tarefas 130 a 133, `procedimento.dta_eliminacao`, `protocolo.sin_eliminado` |
| Temporalidade | Administração > Tabela de Assuntos | prazos e destinação por assunto | `assunto.prazo_corrente`, `prazo_intermediario`, `sta_destinacao` |
| Estatísticas de Arquivamento | Estatísticas > Arquivamento | números do acervo | `gerar_estatisticas_arquivamento` |

## 10. Usuário externo e trâmite entre órgãos

Acesso externo: liberação por e-mail com validade e controle de visualização
(`acesso_externo` com `hash_interno`, `dta_validade`, `sin_processo`,
`dth_visualizacao`); assinatura externa por documento (tarefas 86 a 88); login
gov.br e 2FA externo parametrizáveis; inclusão de documento pelo externo
desligada por padrão (`SEI_HABILITAR_ACESSO_EXTERNO_INCLUSAO_DOCUMENTO = 0`).

Tramita.GOV.BR (`mod-sei-pen`) é o único ponto com processamento em segundo
plano real, com workers Gearman e dois agendamentos separados
(`PENAgendamentoRN::processarTarefasEnvioPEN` e `processarTarefasRecebimentoPEN`).

- Validações de envio: especificação e ao menos um interessado obrigatórios; ao
  menos um documento interno assinado ou um externo; documentos sem assinatura
  bloqueiam o trâmite.
- Durante o envio o processo fica bloqueado (`sta_estado = '4'`), somente
  leitura, mas continua no Controle de Processos. Confirmado o recebimento,
  deixa de ter andamentos abertos e ainda pode ser reaberto na origem para
  consulta.
- Máquina de estados de 11 situações, de "não iniciado" a "ciência de recusa";
  recusa e cancelamento são conclusões normais de trâmite
  (`ProcessoEletronicoRN.php:43-53`).
- Recibos de envio e de conclusão de trâmite, para remetente e destinatário.
- Na devolução, o PEN reconhece o que o destinatário já tem e tramita só o
  necessário.
- Mapeamentos obrigatórios: tipos de processo, tipos de documento de envio e
  recebimento, hipóteses legais, unidades, órgãos externos, restrições de
  componentes digitais e envio parcial.

SEI Federação tem 11 tabelas no núcleo e agendamento a cada 5 minutos.

## 11. Administração, perfis e infraestrutura

Perfis padrão da Base de Referência:

| Perfil | Para quê |
| --- | --- |
| Básico | obrigatório para qualquer outro perfil funcionar |
| Colaborador (Básico sem Assinatura) | mesmo acesso, sem assinar |
| Administrador | tabelas básicas, relatórios, configurações |
| Informática | suporte técnico |
| Arquivamento | arquivamento de vias físicas de documentos |
| Avaliação Documental | avaliação e revisão arquivística |
| Ouvidoria | fluxo de ouvidoria |
| Inspeção | inspeção administrativa |
| Acervo de Sigilosos da Unidade | relatório e gestão de credenciais sigilosas |

Flags de `unidade` que mudam o comportamento: `sin_protocolo` (unidade
protocoladora, autentica externos), `sin_arquivamento` (unidade de arquivo),
`sin_ouvidoria`, `sin_envio_processo` (pode receber processos),
`sin_mail_pendencia`.

Menus de topo do SEI 5.0.0: Acompanhamento Especial, Acompanhamento Ouvidoria,
Administração, Arquivo, Avaliação Documental, Base de Conhecimento, Blocos,
Contatos, Controle de Prazos, Controle de Processos, Estatísticas, Favoritos,
Grupos, Infra, Iniciar Processo, Inspeção Administrativa, Lixeira, Marcadores,
Painel de Controle, Pesquisa, Pontos de Controle, Processos Sobrestados,
Reabertura Programada, Relatórios, Retorno Programado, Textos Padrão.

## 12. Parâmetros e limites comprovados

| Parâmetro | Valor | Significado |
| --- | --- | --- |
| `SEI_VERSAO` | 5.0.0 | versão da base de referência |
| `SEI_TAM_MB_DOC_EXTERNO` | 200 | upload máximo de documento externo, em MB |
| `SEI_NUM_MAX_DOCS_PASTA` | 20 | documentos por pasta na árvore |
| `SEI_NUM_PAGINACAO_CONTROLE_PROCESSOS` | 100 | linhas por página no Controle de Processos |
| `SEI_NUM_MAX_PROTOCOLOS_BLOCO` | 1000 | protocolos por bloco |
| `SEI_NUM_DIAS_LIXEIRA` | 45 | retenção da lixeira |
| `SEI_WS_NUM_MAX_DOCS` | 5 | documentos por chamada de web service |
| `SEI_TAM_MB_CORRETOR_DESABILITADO` | 2 | tamanho acima do qual o corretor é desligado |
| `SEI_NUM_REVISORES_AVALIACAO_DOCUMENTAL` | 1 | revisores na avaliação documental |
| `SEI_MASCARA_NUMERO_PROCESSO_INFORMADO` | `#####.######/####-##` | máscara do NUP informado |
| `SEI_EXIBIR_ARVORE_RESTRITO_SEM_ACESSO` | 1 | árvore visível em restrito sem acesso ao conteúdo |
| `SEI_HABILITAR_GRAU_SIGILO` | 0 | grau de sigilo desligado por padrão |

Escala: 194 tabelas funcionais, 122 sequências, 1.462 recursos no SIP,
aproximadamente 120 tipos de andamento. Hubs: `unidade` (73 FKs de entrada),
`usuario` (52), `protocolo` (21), `atividade` (15). 42 tabelas têm ordem física
de colunas diferente entre PostgreSQL e MySQL, portanto todo `INSERT` precisa
nomear as colunas.

## 13. O que roda em segundo plano no núcleo

Lista completa de `infra_agendamento_tarefa`. Tudo o que não está aqui é
síncrono, inclusive a geração de PDF e ZIP.

| Comando | Periodicidade | O que faz | Ativo |
| --- | --- | --- | --- |
| `AgendamentoRN::reabrirProcessos` | diário 00:01, 01:01 | processa reaberturas programadas | S |
| `AgendamentoRN::confirmarPublicacaoInterna` | diário 00:00, 01:00 | efetiva publicações agendadas | S |
| `AgendamentoRN::limparLixeira` | diário 00:02 | expurga a lixeira | S |
| `AgendamentoRN::processarFederacao` | a cada 5 min | replica sinalizações e avisa sobre solicitações | S |
| `AgendamentoRN::otimizarIndicesSolr` | diário | otimiza índices de pesquisa | S |
| `AgendamentoRN::removerAquivosExternosExcluidos` | diário | remove arquivos de externos excluídos | S |
| `AgendamentoRN::removerAquivosNaoUtilizados` | diário | limpa arquivos com mais de 24 h sem uso | S |
| `AgendamentoRN::removerDadosTemporariosEstatisticas` | diário | expurga temporários de estatísticas | S |
| `AgendamentoRN::removerDadosTemporariosAuditoria` | diário | expurga temporários de auditoria | S |
| `AgendamentoRN::testarAgendamento` | a cada 5 min | teste do agendador | N |

## 14. Lacunas do corpus local

Pontos em que uma decisão de implementação precisa de fonte adicional, isto é,
do SEI oficial em PHP, que não está neste repositório.

- Condição canônica de "sobrestado" em banco. O manual afirma que sobrestados
  não aparecem no Controle de Processos, mas a expressão SQL exata não está
  comprovada (`docs/evidencias_controle_processos.md`).
- Semântica de `procedimento.dta_conclusao`, distinta das conclusões por unidade
  em `atividade`. Não se sabe quando é gravada nem como se relaciona com o
  início da temporalidade.
- Valores literais de `protocolo.sta_estado` para normal, anexado e documento
  cancelado. Só `'4'` e `'5'` aparecem como literais no código do PEN.
- Limites reais de tamanho e tempo da geração de PDF/ZIP e o motor de conversão.
- Regras de transação e bloqueio em operações concorrentes.
- Algoritmo de hash de anexos; o roteiro mestre adverte para não inferir pelo
  tamanho da coluna.
- A Base de Referência restaurada não possui atividades operacionais, portanto
  as rotas de leitura retornam página vazia até existir fixture anonimizada ou
  ambiente autorizado.
