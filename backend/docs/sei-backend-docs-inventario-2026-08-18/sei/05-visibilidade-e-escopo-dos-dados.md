# 05 — Visibilidade e escopo dos dados

## Regra geral

No mesmo SEI, o processo é compartilhado entre as unidades autorizadas, mas vários recursos são deliberadamente locais para evitar que a organização interna de uma equipe seja exposta como conteúdo processual.

## Matriz de visibilidade entre unidades da mesma instalação

| Informação/recurso | Outra unidade vê? | Pode alterar? | Faz parte formal dos autos? | Observação |
|---|---:|---:|---:|---|
| NUP e tipo do processo | Sim, conforme acesso | Limitado | Sim, como metadado | NUP não é livremente alterável. |
| Especificação/descrição | Sim | Unidade autorizada pode alterar conforme regras | Metadado | Boa padronização melhora pesquisa. |
| Interessados/destinatários | Sim, conforme acesso | Conforme permissão | Metadado | Baseado em contatos. |
| Observações desta unidade | Sim, em lista separada | Só a unidade autora | Não é documento formal | Cada unidade mantém sua observação. |
| Documento interno assinado | Sim, conforme acesso | Não após acesso por outra unidade | Sim | Caneta amarela/preta sinaliza possibilidade de edição. |
| Minuta não assinada | Em regra, não para outra unidade | Unidade autora | Ainda não | Bloco de Assinatura/Reunião pode disponibilizar. |
| Documento externo | Sim, conforme acesso | Cadastro pode ter regras; arquivo é preservado | Sim | Pesquisa depende de texto/OCR. |
| Histórico/andamentos | Sim | Novos registros podem ser acrescentados; não se apaga a história comum | Sim como trilha operacional | Erro deve ser retificado por novo registro. |
| Atualização de andamento | Sim | Unidade que atua inclui novo registro | Não substitui documento formal | Útil para informação operacional. |
| Ciência | Sim no histórico | Cada unidade registra a própria | Registro formal de ciência | Não significa concordância. |
| Comentário | Sim, se tiver acesso | Somente conforme autoria/unidade e regras | Não | Em documento não assinado fica local até assinatura. |
| Anotação | Não | Unidade autora | Não | Orientação interna; pode ser marcada como prioridade. |
| Atribuição a usuário | Não | Unidade atual | Não | Não impede outros usuários da mesma unidade. |
| Marcador e texto | Não | Unidade autora | Não | Organização interna. |
| Controle de prazo | Não | Unidade autora | Não | Conclusão do prazo não conclui processo. |
| Retorno Programado | Sim para unidades envolvidas | Remetente define; destinatária devolve | Controle operacional | Vencimento não devolve automaticamente. |
| Acompanhamento Especial | Não como lista da outra unidade | Unidade autora | Não | Permite acompanhar sem manter aberto. |
| Bloco Interno | Não | Unidade autora | Não | Organização local. |
| Bloco de Assinatura | Sim para unidades disponibilizadas | Destinatária pode editar minuta sem assinatura e assinar | Documento assinado integra autos | Compartilhamento temporário. |
| Bloco de Reunião | Sim para unidades disponibilizadas | Consulta/discussão; sem atuação formal normal | Não por si | Permite visualizar minutas. |
| Favorito de processo | Não | Unidade autora | Não | Atalho local. |
| Favorito de documento | Não como cadastro de favorito | Unidade autora | Modelo local; cópia futura vira novo documento | Não altera documento origem. |
| Texto Padrão | Não como biblioteca da outra unidade, salvo configuração institucional | Unidade autora/admin | Não | Fragmento usado para gerar conteúdo. |
| Grupo de contatos/e-mail/envio | Não necessariamente | Unidade/admin | Não | Lista operacional, não ACL. |
| Base de Conhecimento liberada | Sim, conforme associação e acesso | Unidade autora cria nova versão | Não integra automaticamente os autos | Guia de procedimento. |
| Ponto de Controle | Associado ao processo e consultável conforme configuração | Usuários autorizados | Não é documento | Fase/categoria gerencial. |
| Nível de acesso | Sim como regra aplicada | Usuários autorizados, com hipótese legal | Metadado de segurança | Documento restrito/sigiloso pode elevar restrição do processo. |
| Credencial de sigilo | Só usuários credenciados | Gestores de credencial | Não é conteúdo | Controla acesso individual. |

## Comentário não é despacho

Comentários podem ser vistos por outras unidades autorizadas, mas o manual é explícito: **não fazem parte da instrução processual**.

Não use comentário para:

- decisão;
- autorização;
- parecer;
- ordem;
- manifestação que precise ser preservada como peça dos autos.

Nesses casos, crie documento interno e assine.

## Observações desta unidade

Processo e documento possuem campo de observação por unidade. Outras unidades podem consultar essas observações em lista separada, mas não alterá-las.

Isso é diferente de:

- anotação, que permanece invisível a outras unidades;
- comentário, que pode ser compartilhado;
- documento formal, que integra os autos.

## Acesso por nível

### Público

Documentos assinados ficam disponíveis aos usuários do órgão, conforme configuração e mecanismos de consulta.

### Restrito

Conteúdo fica disponível às unidades pelas quais o processo tramitou. É obrigatória uma hipótese legal adequada.

### Sigiloso

Somente usuários com credencial específica acessam. Pesquisa comum não recupera processos/documentos sigilosos.

## O que ocorre no envio interno

Enviar para outra unidade transmite o **acesso ao mesmo processo**, não um pacote contendo organização interna da origem.

A destinatária recebe:

- processo e documentos permitidos;
- histórico e metadados compartilhados;
- regras de acesso;
- retorno programado, quando definido.

Não recebe:

- marcador da origem;
- anotação da origem;
- atribuição da origem;
- controle de prazo da origem;
- lista de acompanhamento especial da origem;
- bloco interno da origem.

## O que ocorre no Tramita.GOV.BR

O envio externo não equivale ao envio entre unidades da mesma instalação. O módulo PEN valida e transmite o processo/documento por meio do modelo de interoperabilidade, com documentos, componentes digitais, metadados e recibos de trâmite.

Como regra de projeto, não se deve presumir transmissão de recursos locais do SEI, como:

- marcadores;
- anotações;
- atribuições;
- controles de prazo;
- blocos internos;
- favoritos.

Informação que precisa chegar oficialmente a outro órgão deve estar em **documento assinado** ou metadado previsto no padrão de integração.

## Regra de ouro

```text
Precisa orientar apenas minha equipe?
  → anotação, marcador, atribuição, controle de prazo

Precisa ser visto por outra unidade, mas não integrar os autos?
  → comentário, com cautela

Precisa produzir efeito administrativo e permanecer formalmente registrado?
  → documento assinado
```

## Recomendações de modelagem

- Separar tabelas/coleções por escopo: global do processo, unidade e usuário.
- Exigir `id_unidade` em marcador, anotação, atribuição e controle de prazo.
- Não serializar esses recursos na API de trâmite externo.
- Fazer comentários terem política explícita de visibilidade, autoria e exclusão.
- Modelar observações como coleção por unidade, não como campo único sobrescrito.
- Aplicar acesso ao conteúdo antes da pesquisa e da geração de PDF.

## Fontes principais

- [Iniciando Operações][U1]
- [Operações Básicas com Processos][U2]
- [Operações de Manutenção e Acompanhamento][U3]
- [Operações Básicas com Documentos][U5]
- [Blocos][U7]
- [Módulo PEN — Uso][P1]

[U1]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Iniciando_operacoes.html
[U2]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_basicas_com_processos.html
[U3]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_de_manutencao_e_acompanhamento_de_processos.html
[U5]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_basicas_com_documentos.html
[U7]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Blocos.html
[P1]: https://manuais.processoeletronico.gov.br/pt-br/latest/Manual-de-Integra%C3%A7%C3%A3o-ao-Tramita-GOV.BR/USAGE.html
