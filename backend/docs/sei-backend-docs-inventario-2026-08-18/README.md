# Inventário funcional e modelo operacional do SEI

Esta pasta reúne uma análise funcional do **Sistema Eletrônico de Informações (SEI)**, preparada para apoiar a documentação e a modelagem do backend em `C:\MyDartProjects\sei\backend\docs`.

O material foi construído com base em:

- telas do ambiente de testes fornecidas durante a análise;
- Manual oficial do Usuário SEI 4.0+, que também documenta evoluções das versões 4.1 e 5.0;
- Manual oficial do Administrador do SEI;
- documentação oficial do Módulo de Gestão Documental;
- arquivos públicos do projeto `pengovbr/sei-docker`;
- `docker-compose.yml` dos testes funcionais do módulo PEN fornecido como referência.

## Conclusões centrais

1. **O processo do SEI não possui apenas um “status global aberto/concluído”.** A abertura operacional é controlada por unidade. O mesmo processo pode estar aberto simultaneamente em várias unidades.
2. **Concluir Processo significa concluir o trabalho da unidade atual.** Não encerra as outras unidades nas quais o processo permanece aberto.
3. Quando o processo é enviado, a unidade remetente é concluída automaticamente, exceto quando é marcada a opção **Manter processo aberto na unidade atual**.
4. **Arquivamento é diferente de conclusão.** O arquivamento é uma etapa de gestão documental posterior ao encerramento dos andamentos abertos; inicia a contagem de guarda e impede novos atos até o desarquivamento.
5. A exportação nativa do processo para PDF apresenta comportamento **imediato/síncrono** no fluxo padrão: o usuário seleciona os documentos, clica em **Gerar** e aguarda o download. Não foi localizada, no fluxo oficial nativo, uma fila com acompanhamento de job em segundo plano.
6. Recursos como **atribuição, anotações, marcadores e controle de prazo** pertencem à organização interna da unidade; comentários e documentos seguem regras diferentes de visibilidade.

## Arquivos

O inventário estruturado contém **60 recursos nucleares**, enquanto os capítulos detalhados registram recursos adicionais, variações por versão, módulos e funções administrativas.

| Documento | Conteúdo |
|---|---|
| [`sei/INVENTARIO-CONSOLIDADO.md`](sei/INVENTARIO-CONSOLIDADO.md) | Versão única consolidada de toda a documentação funcional. |
| [`sei/00-escopo-e-terminologia.md`](sei/00-escopo-e-terminologia.md) | Escopo, conceitos e diferenças entre instalação, órgão, unidade, processo e documento. |
| [`sei/01-modelo-operacional-processos-e-unidades.md`](sei/01-modelo-operacional-processos-e-unidades.md) | Modelo detalhado de processo aberto em várias unidades, envio, conclusão e reabertura. |
| [`sei/02-inventario-recursos-usuario.md`](sei/02-inventario-recursos-usuario.md) | Inventário dos recursos disponíveis ao usuário básico. |
| [`sei/03-documentos-modelos-contatos-grupos-e-blocos.md`](sei/03-documentos-modelos-contatos-grupos-e-blocos.md) | Documentos, modelos, textos padrão, contatos, grupos e blocos. |
| [`sei/04-conclusao-sobrestamento-arquivamento-e-estados.md`](sei/04-conclusao-sobrestamento-arquivamento-e-estados.md) | Concluir, sobrestar, arquivar, desarquivar, relacionar e anexar. |
| [`sei/05-visibilidade-e-escopo-dos-dados.md`](sei/05-visibilidade-e-escopo-dos-dados.md) | Matriz do que é compartilhado e do que fica restrito à unidade. |
| [`sei/06-pdf-zip-pesquisa-solr-jod-e-processamento.md`](sei/06-pdf-zip-pesquisa-solr-jod-e-processamento.md) | Exportação PDF/ZIP, processamento, pesquisa, Solr e JODConverter. |
| [`sei/07-inventario-administracao-sei-sip.md`](sei/07-inventario-administracao-sei-sip.md) | Inventário de recursos administrativos do SEI e do SIP. |
| [`sei/08-cenarios-e-testes-de-aceitacao.md`](sei/08-cenarios-e-testes-de-aceitacao.md) | Cenários BDD e invariantes úteis para uma reimplementação. |
| [`sei/09-fontes-e-rastreabilidade.md`](sei/09-fontes-e-rastreabilidade.md) | Fontes oficiais, distinção entre fatos, inferências e recomendações. |
| [`sei/inventario-recursos-sei.csv`](sei/inventario-recursos-sei.csv) | Inventário tabular para importação. |
| [`sei/inventario-recursos-sei.json`](sei/inventario-recursos-sei.json) | Inventário estruturado para uso programático. |

## Convenções usadas

- **Fato documentado:** comportamento descrito diretamente no manual oficial ou observado na tela.
- **Inferência técnica:** conclusão obtida ao combinar o fluxo oficial com configurações públicas, explicitamente identificada como inferência.
- **Recomendação de modelagem:** proposta para uma nova implementação; não representa necessariamente a estrutura interna do código privado do SEI.

## Instalação no projeto local

Copie o conteúdo desta pasta para:

```text
C:\MyDartProjects\sei\backend\docs
```

A estrutura relativa de `sei/assets` deve ser preservada para que as imagens continuem aparecendo nos arquivos Markdown.
