# 04 — Conclusão, sobrestamento, arquivamento e estados

## 1. “Concluído” é um status do processo?

A resposta mais precisa é:

> **A conclusão é uma situação operacional por unidade, e não necessariamente um estado global único do processo.**

O botão da tela é descrito oficialmente como **“Concluir processo nesta unidade”**. Na imagem analisada, o processo está aberto somente na unidade TESTE:

![Processo aberto somente na unidade TESTE](assets/01-processo-aberto-unidade-concluir.png)

Se o mesmo processo estivesse aberto também em outra unidade, concluir na TESTE encerraria apenas a participação da TESTE.

### Três expressões úteis

| Expressão | Significado recomendado |
|---|---|
| Aberto na unidade | A unidade possui contexto ativo de trabalho. |
| Concluído na unidade | A unidade encerrou seu contexto, mas outras podem continuar abertas. |
| Totalmente concluído | Não há nenhuma unidade com andamento aberto. |

Essa distinção evita tratar “concluído” como um booleano global simples.

## 2. O que Concluir Processo faz

- encerra as providências da unidade atual;
- remove o processo da tela Controle de Processos daquela unidade;
- registra a conclusão no histórico;
- interrompe a contagem de permanência aberta na unidade;
- mantém consulta por pesquisa, estatística ou acompanhamento;
- não apaga documentos;
- não cancela o processo;
- não arquiva;
- não conclui outras unidades.

## 3. O que Reabrir Processo faz

- cria novamente contexto ativo na unidade;
- coloca o processo de volta no Controle de Processos;
- atribui o processo ao usuário que reabriu;
- pode ser executado por unidade na qual o processo já tramitou;
- não exige novo envio apenas para reativar a unidade anterior.

Consultar processo concluído não exige reabertura. Reabrir deve significar “voltarei a praticar atos”.

## 4. Sobrestamento

O sobrestamento interrompe temporariamente o trâmite porque o processo precisa aguardar uma providência ou decisão.

![Tela de sobrestamento](assets/04-sobrestamento.png)

### Modalidades

- **Somente Sobrestar:** o fundamento consta do próprio processo.
- **Sobrestar vinculado a outro processo:** o fundamento consta de outro processo do SEI.

### Efeitos

- processo sai da fila normal e vai para Processos Sobrestados;
- motivo e eventual processo vinculado ficam registrados;
- trabalho fica suspenso até Remover Sobrestamento;
- não ocorre arquivamento nem encerramento definitivo.

### Regra relevante

Operações como anexação exigem que o processo esteja aberto apenas na unidade que realizará a ação. O sobrestamento também deve ser tratado como ato coordenado, evitando que outra unidade continue movimentando um processo que uma unidade acredita estar suspenso.

## 5. Conclusão versus arquivamento

| Aspecto | Concluir Processo | Arquivar Processo |
|---|---|---|
| Finalidade | Encerrar o trabalho da unidade. | Declarar encerrada a ação administrativa e iniciar gestão de guarda. |
| Escopo | Por unidade. | Processo como objeto arquivístico, sem andamentos abertos. |
| Pré-requisito | Não haver mais ação da unidade. | Processo concluído e sem unidades/andamentos abertos. |
| Volta ao trabalho | Reabrir Processo. | Desarquivar Processo. |
| Novos documentos | Outra unidade aberta ainda pode incluir; a própria unidade precisa reabrir. | Bloqueados até desarquivamento. |
| Contagem arquivística | Não inicia, por si só. | Inicia prazo de guarda corrente. |
| Documento gerado | Normalmente apenas andamento de conclusão. | Módulo pode gerar e assinar Termo de Arquivamento. |
| Onde aparece | Pesquisa, estatísticas, acompanhamento. | Arquivo da Unidade/Pendências/Gestão Documental. |

## 6. É possível concluir e arquivar ao mesmo tempo?

Não como uma única operação simultânea.

O fluxo correto é sequencial:

```text
unidades abertas
      │
      ▼
conclusão de cada unidade
      │
      ▼
nenhum andamento aberto
      │
      ▼
arquivamento
```

Depois de arquivado, o processo continua sem unidades abertas, mas sua situação principal é **arquivado**. Não se usa simplesmente Reabrir; primeiro é necessário Desarquivar.

Assim:

- logicamente, todo processo arquivado pressupõe conclusão operacional anterior;
- funcionalmente, “concluído” e “arquivado” não são dois botões aplicados ao mesmo tempo;
- o estado arquivado adiciona bloqueios e regras de temporalidade que a conclusão comum não possui.

## 7. O arquivamento existe em toda instalação?

A documentação do Módulo de Gestão Documental informa que o SEI passou a possuir recursos nativos relacionados à gestão documental a partir da versão 4.1, mas a disponibilidade depende de:

- recursos habilitados no SIP;
- perfil de arquivamento/avaliação;
- configuração de unidade de arquivo;
- módulo e versão adotados.

Na tela fornecida não aparece ícone ou menu de Arquivo da Unidade/Pendências de Arquivamento. Isso sugere que o recurso não está habilitado para aquele perfil ou ambiente, mas a imagem isolada não permite determinar a causa exata.

## 8. Efeitos do arquivamento formal

Segundo a documentação oficial do módulo:

- inicia contagem dos prazos de guarda;
- registra que o último ato processual foi realizado;
- gera Termo de Arquivamento;
- impede novos documentos e andamentos;
- mantém consulta, PDF, ZIP, comentários, acompanhamento e pesquisa;
- exige desarquivamento para voltar a tramitar;
- alimenta Arquivo da Unidade e etapas de avaliação/destinação.

## 9. Sobrestar, relacionar e anexar

| Operação | Relação entre processos | Reversibilidade | Efeito na árvore |
|---|---|---|---|
| Sobrestar vinculado | Um processo justifica a suspensão de outro. | Sobrestamento pode ser removido. | Árvores permanecem separadas. |
| Relacionar | Vínculo informativo entre processos. | Normalmente gerenciável. | Árvores e andamentos independentes. |
| Anexar | Processo passa a integrar permanentemente outro. | Usuário não desfaz livremente. | Processo anexado fica subordinado e bloqueado para novas alterações. |

## 10. Cancelar, excluir e arquivar não são equivalentes

- **Excluir documento/processo:** corrige inclusão indevida quando as regras ainda permitem.
- **Cancelar documento:** preserva registro e declara o documento sem efeito.
- **Concluir processo:** fecha o trabalho da unidade.
- **Sobrestar:** suspende temporariamente.
- **Arquivar:** inicia a fase arquivística de guarda.
- **Eliminar:** destinação final controlada por gestão documental, após avaliação e procedimentos formais.

## 11. Máquina conceitual de estados

> Modelo de domínio recomendado, não descrição de tabela privada.

```text
PROCESSO
  estado_arquivistico = ATIVO | ARQUIVADO | EM_AVALIACAO | ELIMINADO
  sobrestamentos = 0..N
  unidades_abertas = conjunto de unidades

Situação operacional derivada:
  se unidades_abertas não vazio -> EM_TRAMITACAO_INTERNA
  se unidades_abertas vazio e estado_arquivistico = ATIVO -> TOTALMENTE_CONCLUIDO
  se estado_arquivistico = ARQUIVADO -> ARQUIVADO
```

Não é recomendável representar tudo em uma coluna única, pois:

- conclusão é por unidade;
- sobrestamento possui motivo e escopo;
- arquivamento possui temporalidade e histórico;
- trâmite externo possui estados próprios;
- acesso público/restrito/sigiloso é outra dimensão.

## Fontes principais

- [Operações Básicas com Processos][U2]
- [Outras Operações com Processos][U4]
- [Módulo Gestão Documental][M1]

[U2]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_basicas_com_processos.html
[U4]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Outras_operacoes_com_processos.html
[M1]: https://manuais.processoeletronico.gov.br/pt-br/latest/MODULOS-SEI/Gestao_documental.html
