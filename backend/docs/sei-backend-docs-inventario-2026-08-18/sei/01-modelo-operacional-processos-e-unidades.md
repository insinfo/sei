# 01 — Modelo operacional de processos e unidades

## Resposta direta

No SEI, **“aberto” e “concluído” são condições relacionadas à unidade**, não simplesmente um único status global do processo.

Um processo pode estar:

- aberto somente na Unidade A;
- aberto simultaneamente nas Unidades A, B e C;
- concluído na Unidade A, mas aberto na Unidade B;
- sem nenhuma unidade aberta, situação normalmente chamada de processo totalmente concluído;
- posteriormente reaberto por uma unidade pela qual já tramitou.

## Como duas unidades ficam com o mesmo processo aberto

### Caminho 1 — Envio com manutenção na origem

```text
Estado inicial
  A = aberto
  B = não aberto

A envia para B marcando “Manter processo aberto na unidade atual”

Estado final
  A = aberto
  B = recebido/aberto
```

### Caminho 2 — Envio a várias unidades

O SEI permite informar uma ou várias unidades de destino no mesmo envio:

```text
A envia para B, C e D

A = concluída automaticamente, salvo “manter aberto”
B = recebe o processo
C = recebe o processo
D = recebe o processo
```

O manual recomenda o envio simultâneo apenas quando as atividades das unidades forem **independentes entre si**. Se a ação de C depender da produção de B, o envio paralelo pode quebrar a sequência lógica do trabalho.

### Caminho 3 — Reabertura por unidade anterior

Uma unidade pela qual o processo já tramitou pode localizá-lo e clicar em **Reabrir Processo**, sem solicitar novo envio. A reabertura cria novamente um contexto ativo para essa unidade e atribui o processo ao usuário que executou a ação.

Isso significa que o processo pode voltar a ficar aberto em múltiplas unidades mesmo sem novo envio da unidade que já o estava tratando.

## Envio normal e conclusão automática

Por padrão:

```text
A envia para B sem marcar “Manter processo aberto”

A = concluída
B = pendente de recebimento/aberta
```

A conclusão da origem é automática. Marcar **Manter processo aberto na unidade atual** impede essa conclusão.

## O que o recebimento significa

Na unidade destinatária, o processo aparece em vermelho até que um usuário clique em seu número. O clique registra no histórico:

- data e hora do recebimento;
- unidade;
- usuário responsável.

A cor vermelha é, portanto, uma sinalização de **não recebido por usuário da unidade**, e não a criação de outra pasta ou outro NUP.

## O processo é copiado?

Não. O processo permanece único:

```text
NUP único
árvore única de documentos
histórico único
metadados de processo compartilhados
```

Cada unidade possui sua organização operacional própria. Quando uma unidade inclui e assina um novo documento, esse documento passa a compor a árvore comum, observadas as regras de acesso.

## Minutas e documentos assinados

- Documento interno não assinado continua sendo uma minuta da unidade produtora.
- Para outra unidade visualizar/editar uma minuta antes da assinatura, o mecanismo próprio é o **Bloco de Assinatura** ou o **Bloco de Reunião**, conforme a finalidade.
- Um documento assinado ainda pode ser editável enquanto não tiver sido tramitado ou visualizado por outra unidade, sinalizado pela caneta amarela.
- Depois que usuário de outra unidade acessa o documento assinado, a caneta se torna preta e sua edição deixa de ser permitida.

Esse comportamento reduz o risco de uma unidade alterar silenciosamente um documento já conhecido por outra.

## Conclusão por unidade

Considere o processo aberto em A e B:

```text
Antes
  A = aberto
  B = aberto

A clica “Concluir Processo”

Depois
  A = concluído
  B = aberto
```

A conclusão em A:

- remove o processo do Controle de Processos de A;
- encerra o tempo de permanência aberto em A;
- não remove nem bloqueia o processo em B;
- não apaga documentos;
- não equivale a arquivamento;
- não impede consulta posterior por A.

## Quando o processo está “totalmente concluído”

Operacionalmente, isso ocorre quando não existe mais nenhuma unidade com andamento aberto:

```text
unidades_abertas(processo) = conjunto vazio
```

O termo “totalmente concluído” é útil para evitar ambiguidade, pois “concluído” pode significar apenas “concluído na minha unidade”.

## Reabrir não é consultar

Uma unidade que já participou do processo pode consultá-lo por pesquisa sem reabrir. Deve reabrir somente quando precisar:

- incluir documento;
- registrar novo ato;
- enviar novamente;
- executar outra providência que exija processo aberto.

Ao reabrir, o processo volta ao Controle de Processos e é atribuído automaticamente ao usuário que o reabriu.

## Consequências estatísticas

O manual informa que o tempo durante o qual o processo permanece aberto, mesmo sem atividade, é computado como tempo de andamento da unidade. Portanto, deixar o processo aberto apenas “para acompanhar” produz indicadores distorcidos.

Para simples acompanhamento, use **Acompanhamento Especial**.

## Riscos de manter aberto em várias unidades

| Risco | Exemplo | Mitigação |
|---|---|---|
| Trabalho duplicado | A e B produzem respostas para a mesma demanda. | Definir responsabilidade no despacho e usar envio sequencial quando houver dependência. |
| Ordem documental confusa | Documentos de A e B são inseridos em paralelo. | Padronizar títulos, registrar andamentos e ordenar árvore apenas quando necessário. |
| Indicadores inflados | Unidade mantém processo aberto sem atuação. | Concluir e usar Acompanhamento Especial. |
| Decisão concorrente | Duas unidades tentam dar solução final diferente. | Definir unidade coordenadora e tarefas independentes. |
| Estado difícil de entender | Usuário conclui em A achando que encerrou todo o processo. | Exibir sempre a lista de unidades abertas e usar linguagem “Concluir nesta unidade”. |
| Propagação excessiva | Cada unidade envia para novas unidades mantendo-se aberta. | Regras de governança e auditoria de unidades abertas. |

## Ferramenta correta para cada necessidade

| Necessidade | Recurso adequado |
|---|---|
| Apenas observar futuras atualizações | Acompanhamento Especial |
| Organizar processos internos da unidade | Marcador ou Bloco Interno |
| Cobrar devolução de outra unidade | Retorno Programado |
| Compartilhar minuta para assinatura | Bloco de Assinatura |
| Compartilhar minuta para discussão, sem atuação formal | Bloco de Reunião |
| Executar tarefas paralelas independentes | Envio a múltiplas unidades ou manutenção aberta na origem |
| Suspender formalmente o trabalho | Sobrestamento |
| Encerrar a participação da unidade | Concluir Processo |
| Encerrar gestão documental e iniciar guarda | Arquivar Processo, quando habilitado |

## Filtro “Linha Direta”

Quando várias unidades trabalham no mesmo processo, o filtro **Linha Direta** pode exibir somente documentos produzidos por unidades que enviaram o processo diretamente para a unidade atual ou o receberam diretamente dela. Esse filtro não exclui documentos; apenas reduz a árvore visualizada. Pode causar a falsa impressão de que unidades diferentes possuem versões distintas da pasta.

## Modelo conceitual recomendado para uma reimplementação

> Recomendação de arquitetura; não representa necessariamente as tabelas privadas do SEI.

```text
processo
  id
  nup
  tipo
  nivel_acesso
  ...

processo_unidade
  id_processo
  id_unidade
  situacao: PENDENTE_RECEBIMENTO | ABERTO | CONCLUIDO
  data_envio
  data_recebimento
  data_abertura
  data_conclusao
  id_usuario_recebimento
  id_usuario_conclusao
  origem_do_envio

andamento
  id_processo
  id_unidade
  id_usuario
  tipo_evento
  data_hora
  descricao
```

### Invariantes úteis

1. Um processo possui no máximo um contexto ativo por unidade.
2. Concluir A nunca altera automaticamente B, C ou D.
3. Enviar sem manter aberto conclui somente o contexto remetente.
4. Reabrir exige que a unidade tenha vínculo histórico ou permissão equivalente.
5. A ausência de unidades abertas não apaga nem arquiva o processo.
6. Arquivamento só pode ocorrer sem contextos abertos.
7. Dados locais da unidade não são copiados para a unidade destinatária.

## Exemplo completo

```text
09:00 — A inicia o processo
         abertas = {A}

10:00 — A envia para B mantendo aberto
         abertas = {A, B}

11:00 — B recebe
         abertas = {A, B}

14:00 — A conclui sua parte
         abertas = {B}

15:00 — B envia para C sem manter aberto
         abertas = {C}

16:00 — C conclui
         abertas = {}
         condição operacional: totalmente concluído

Dia seguinte — A reabre para correção
         abertas = {A}
```

## Fontes principais

- [Operações Básicas com Processos][U2]
- [Iniciando Operações — Tela do Processo][U1]
- [Operações Básicas com Documentos][U5]
- [Blocos][U7]

[U1]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Iniciando_operacoes.html
[U2]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_basicas_com_processos.html
[U5]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_basicas_com_documentos.html
[U7]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Blocos.html
