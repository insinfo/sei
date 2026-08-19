# 08 — Cenários e testes de aceitação

Estes cenários transformam o comportamento funcional analisado em requisitos testáveis para uma reimplementação.

## 1. Envio e unidades abertas

### Cenário 1 — Envio normal conclui origem

```gherkin
Dado que o processo P está aberto somente na unidade A
Quando A envia P para B sem marcar “Manter processo aberto”
Então P deve deixar a fila ativa de A
E P deve aparecer como recebido em B
E as unidades abertas de P devem conter B e não A
E o histórico deve registrar envio e conclusão de A
```

### Cenário 2 — Manter aberto produz paralelismo

```gherkin
Dado que P está aberto em A
Quando A envia P para B marcando “Manter processo aberto”
Então P deve permanecer aberto em A
E deve ficar disponível em B
E a lista de unidades abertas deve mostrar A e B
```

### Cenário 3 — Concluir uma unidade não conclui outra

```gherkin
Dado que P está aberto em A e B
Quando A conclui P
Então P deve ficar concluído em A
E deve permanecer aberto em B
E B deve continuar capaz de incluir documento e enviar o processo
```

### Cenário 4 — Envio simultâneo

```gherkin
Dado que P está aberto em A
Quando A envia P para B e C
Então B e C devem receber o mesmo NUP e a mesma árvore
E não devem ser criadas cópias independentes do processo
```

### Cenário 5 — Reabertura por unidade anterior

```gherkin
Dado que P tramitou por A e está concluído em A
Quando usuário de A consulta P sem reabrir
Então P não deve voltar ao Controle de Processos de A
Quando o usuário clica em Reabrir
Então P deve ficar aberto em A
E deve ser atribuído ao usuário que reabriu
```

### Cenário 6 — Processo totalmente concluído

```gherkin
Dado que P está aberto em A e B
Quando A conclui P
E B conclui P
Então o conjunto de unidades abertas deve ficar vazio
E P deve continuar pesquisável
E P não deve ser considerado arquivado automaticamente
```

## 2. Visibilidade entre unidades

### Cenário 7 — Dados locais não são transmitidos

```gherkin
Dado que A cadastrou marcador, anotação, atribuição e controle de prazo em P
Quando A envia P para B
Então B não deve visualizar esses quatro recursos de A
E A deve preservá-los conforme as regras de cada recurso
```

### Cenário 8 — Comentário compartilhado

```gherkin
Dado que A adicionou comentário no processo público P
Quando B recebe acesso a P
Então B deve visualizar o comentário
E o comentário deve estar identificado como não integrante da instrução processual
```

### Cenário 9 — Comentário em minuta

```gherkin
Dado que A adicionou comentário em documento interno não assinado
Então B não deve visualizá-lo
Quando o documento é assinado e B possui acesso
Então B deve poder consultar o comentário
```

### Cenário 10 — Observações por unidade

```gherkin
Dado que A e B incluíram observações próprias em P
Então A deve ver as observações de B em seção separada
E A não deve poder editar a observação de B
E B não deve poder editar a observação de A
```

## 3. Documentos e concorrência

### Cenário 11 — Documento assinado antes de acesso externo

```gherkin
Dado que A assinou documento D
E nenhuma outra unidade o acessou
Então D pode ser sinalizado como ainda editável
Quando usuário de B acessa D
Então D deve se tornar não editável
E nova correção deve seguir operação formal adequada
```

### Cenário 12 — Bloco de assinatura

```gherkin
Dado que A criou minuta D sem assinatura
Quando A disponibiliza D em bloco de assinatura para B
Então B pode visualizar a minuta
E pode editá-la enquanto não houver assinatura
E pode assiná-la conforme permissão
E o processo não precisa ser enviado formalmente a B
```

### Cenário 13 — Bloco de reunião

```gherkin
Dado que A inclui P em bloco de reunião para B
Então B pode visualizar minutas de P
Mas P não deve ser considerado aberto em B por causa apenas do bloco
E B não deve receber responsabilidade formal de tramitação
```

## 4. Prazo e acompanhamento

### Cenário 14 — Controle de prazo local

```gherkin
Dado que A define controle de prazo em P
Então usuários de A devem ver data e prazo restante
E B não deve visualizar o controle
Quando A conclui o controle
Então P deve continuar aberto, se já estava aberto
```

### Cenário 15 — Retorno programado

```gherkin
Dado que A envia P para B com retorno em 10 dias
Então A deve ver P em “Aguardando retorno”
E B deve ver P em “Para devolver”
Quando o prazo vence
Então o sistema deve sinalizar atraso
Mas não deve devolver P automaticamente
```

### Cenário 16 — Acompanhamento sem abertura

```gherkin
Dado que A concluiu P e o incluiu em Acompanhamento Especial
Quando B adiciona documento assinado em P
Então A deve conseguir acompanhar a atualização
E P não deve voltar automaticamente à fila ativa de A
```

## 5. Sobrestamento, conclusão e arquivo

### Cenário 17 — Sobrestamento

```gherkin
Dado que P está apto a ser sobrestado em A
Quando A informa motivo e salva
Então P deve sair da fila comum de A
E aparecer em Processos Sobrestados
Quando A remove o sobrestamento
Então P deve voltar ao fluxo ativo aplicável
```

### Cenário 18 — Arquivo exige zero unidades abertas

```gherkin
Dado que P ainda está aberto em B
Quando A tenta arquivar P
Então a operação deve ser recusada
Quando todas as unidades concluem P
Então P pode ficar pendente de arquivamento conforme perfil/configuração
```

### Cenário 19 — Arquivado não reabre diretamente

```gherkin
Dado que P está arquivado
Quando usuário tenta Reabrir Processo
Então a ação deve ser indisponível ou recusada
Quando usuário autorizado desarquiva P
Então P deve retornar ao Controle de Processos da unidade de desarquivamento
```

## 6. PDF e ZIP

### Cenário 20 — PDF imediato

```gherkin
Dado que P possui documentos convertíveis
Quando usuário seleciona “Todos os documentos disponíveis” e clica Gerar
Então a resposta deve produzir download do PDF no mesmo fluxo
E deve respeitar timeout e memória configurados
```

### Cenário 21 — Itens omitidos

```gherkin
Dado que P contém imagem, áudio, ZIP, documento cancelado e minuta de outra unidade
Quando o usuário gera PDF
Então esses itens não devem ser convertidos
E o sistema deve preservar os originais no processo
```

### Cenário 22 — Controle de acesso no PDF

```gherkin
Dado que P contém documento sem permissão para o usuário
Quando ele solicita PDF
Então o documento não deve ser incluído
E a autorização deve ser revalidada no momento da geração/download
```

### Cenário 23 — Falha do JOD

```gherkin
Dado que um DOCX exige conversão e o JOD está indisponível
Quando o PDF do processo é gerado
Então a falha deve ser tratada sem corromper o processo
E deve ficar claro qual documento não pôde ser convertido
```

## 7. Pesquisa e acesso

### Cenário 24 — Tempo de indexação

```gherkin
Dado que novo documento foi assinado agora
Quando a pesquisa é executada imediatamente
Então o documento pode ainda não aparecer
Quando a indexação conclui
Então o documento deve ser recuperado conforme nível de acesso
```

### Cenário 25 — Sigiloso

```gherkin
Dado que P é sigiloso
Quando usuário sem credencial pesquisa P
Então P não deve ser recuperado
Quando usuário com credencial acessa diretamente
Então o conteúdo deve seguir a credencial concedida
```

## 8. Invariantes de banco/domínio

- NUP identifica um processo único.
- Uma unidade não pode possuir dois contextos ativos duplicados para o mesmo processo.
- Conclusão deve fechar somente o contexto da unidade autora.
- Histórico deve ser append-only para eventos de negócio; correções são novos eventos.
- Dados locais devem carregar `id_unidade` obrigatório.
- Documento assinado e visto por outra unidade deve ser imutável ou exigir novo ato formal.
- Arquivo exige ausência de unidades abertas.
- Eliminação exige fluxo arquivístico, não `DELETE` técnico direto.
- Pesquisa e exportação devem aplicar autorização.
- Envio externo não deve serializar organização interna da unidade.

## 9. Testes de desempenho recomendados

- 10, 50, 200, 1.000 e 5.000 documentos por processo;
- PDF de 100 MB, 500 MB e 1 GB;
- 100 gerações de PDF concorrentes;
- 20 unidades abertas simultaneamente;
- envio para 100 unidades por grupo;
- reindexação integral do Solr;
- documento OCR de centenas de páginas;
- retorno do JOD lento e indisponível;
- mudança de permissão durante exportação;
- processo com histórico de milhões de eventos.

## Fontes

Os cenários são derivados dos manuais oficiais referenciados em [`09-fontes-e-rastreabilidade.md`](09-fontes-e-rastreabilidade.md). Os detalhes de arquitetura e desempenho são recomendações de implementação.
