# 00 — Escopo, versões e terminologia

## Escopo da análise

O Manual oficial do Usuário utilizado como referência cobre funcionalidades do **SEI 4.0+**, incluindo evoluções incorporadas nas versões **4.1 e 5.0**. A disponibilidade real de uma funcionalidade depende de quatro fatores:

1. versão instalada;
2. perfil e recursos concedidos no SIP;
3. tipo e configuração da unidade;
4. módulos habilitados pelo órgão.

Assim, a ausência de um botão na tela não prova que a instalação não possui o recurso: ele também pode estar desabilitado para o perfil ou para a unidade. De modo inverso, módulos podem acrescentar menus e botões que não pertencem ao núcleo padrão.

## Entidades conceituais

| Conceito | Significado operacional |
|---|---|
| Instalação | Uma implantação do SEI, com código, banco, repositório de arquivos e configuração próprios. |
| Órgão | Entidade administrativa existente dentro da instalação; uma instalação pode ser mono ou multiórgão. |
| Unidade | Contexto organizacional de trabalho. O usuário atua no SEI sempre dentro de uma unidade selecionada. |
| Usuário | Pessoa autenticada, vinculada a perfis e unidades pelo SIP. |
| Processo | Agregador eletrônico identificado por NUP, com metadados, documentos, andamentos e relações. |
| Documento interno | Documento criado no editor HTML do SEI, com modelo, versões e assinaturas. |
| Documento externo | Arquivo produzido fora do SEI e incluído por upload. |
| Formulário | Documento estruturado em campos definidos pelo administrador. |
| Andamento | Registro de uma ação no histórico, associado a data, unidade e usuário. |
| Processo aberto na unidade | Indica que aquela unidade possui um contexto ativo de trabalho sobre o processo. |
| Processo concluído na unidade | Indica que a unidade encerrou seu contexto ativo; não significa necessariamente que todas as outras unidades também concluíram. |
| Processo arquivado | Processo submetido a uma etapa formal de gestão documental, sem andamentos abertos e bloqueado para novos atos até desarquivamento. |

## Princípio fundamental: uma pasta compartilhada, vários contextos de trabalho

O melhor modelo mental é:

```text
                         PROCESSO ÚNICO
                 NUP + árvore + histórico comum
                              │
               ┌──────────────┼──────────────┐
               │              │              │
          Unidade A       Unidade B       Unidade C
          aberta           aberta          concluída
          marcadores A     marcadores B    sem contexto ativo
          prazo A          prazo B
          atribuição A     atribuição B
```

Não são três cópias do processo. É um processo único, acompanhado por contextos operacionais independentes por unidade.

## Dados compartilhados e dados locais

### Compartilhados, conforme o nível de acesso

- NUP e metadados gerais;
- documentos assinados e documentos externos;
- histórico de andamentos;
- relações e anexações;
- comentários, conforme regras de acesso;
- ciência e atos formais;
- alterações globais de nível de acesso.

### Pertencentes à unidade

- atribuição a usuário;
- anotação;
- marcador e texto do marcador;
- controle de prazo;
- acompanhamento especial;
- bloco interno;
- observação inserida pela unidade, embora outras unidades possam vê-la separadamente sem editá-la.

A matriz detalhada está em [`05-visibilidade-e-escopo-dos-dados.md`](05-visibilidade-e-escopo-dos-dados.md).

## Telas analisadas

A tela fornecida informa explicitamente **“Processo aberto somente na unidade TESTE”**, o que evidencia que o SEI apresenta as unidades abertas como uma propriedade operacional do processo:

![Processo aberto somente na unidade TESTE](assets/01-processo-aberto-unidade-concluir.png)

O menu principal observado contém os principais recursos do perfil básico:

![Menu principal do SEI](assets/02-menu-principal-sei.png)

## Limites desta documentação

O código-fonte integral e privado da versão do SEI utilizada no ambiente não foi fornecido. Por isso:

- esta documentação descreve o **comportamento funcional**, não tenta reproduzir nomes exatos de tabelas ou classes privadas;
- modelos de banco apresentados como sugestão são **recomendações de arquitetura**, e não afirmações sobre a implementação interna do SEI;
- detalhes que variam por versão ou módulo estão marcados explicitamente.

## Fontes principais

- [Manual do Usuário SEI 4.0+][U0]
- [Iniciando Operações][U1]
- [Operações Básicas com Processos][U2]
- [Manual do Administrador SEI][A0]

[U0]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/
[U1]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Iniciando_operacoes.html
[U2]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_basicas_com_processos.html
[A0]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/index.html
