# Análise técnica dos dumps do SEI fornecidos

Este relatório contém somente metadados de esquema; nenhum dado pessoal ou registro operacional foi reproduzido.

## Resultado estrutural

- Base PostgreSQL íntegra: **194 tabelas funcionais** e **122 sequências**, com bytes e diretiva `client_encoding = LATIN1` compatíveis.
- Dump MySQL: **316 tabelas**, sendo **194 funcionais** e **122 tabelas `seq_*`** usadas para geração de identificadores.
- As 194 tabelas funcionais têm os **mesmos nomes e os mesmos conjuntos de colunas** nos dois dialetos.
- **42 tabelas** apresentam ordem física de colunas diferente; por isso, qualquer `INSERT` deve nomear explicitamente as colunas.
- Nenhum dos dumps contém tabelas com prefixo `md_pen_`; o esquema do módulo PEN precisa ser instalado/portado separadamente.

## Nota crítica sobre a codificação do dump PostgreSQL

Há duas cópias locais do dump 5.0.0. A cópia em `backup_sei_bd` é UTF-8 válida, embora declare `SET client_encoding = 'LATIN1';`, e contém 14.424 caracteres literais de substituição (`�`): ela está corrompida e foi preservada somente para análise forense.

A cópia íntegra está em `../referencias/sei-db-ref-executivo/postgresql/v5.0.0/`, proveniente do remoto `https://github.com/pengovbr/sei-db-ref-executivo`. Ela não é UTF-8 porque seus bytes são LATIN1, declara `client_encoding = 'LATIN1'` e não contém a sequência UTF-8 de substituição. A restauração local e a API Dart usam exclusivamente essa fonte íntegra em banco LATIN1.

## Principais hubs por chaves estrangeiras recebidas

| Tabela | FKs de entrada |
|---|---:|
| `unidade` | 73 |
| `usuario` | 52 |
| `protocolo` | 21 |
| `atividade` | 15 |
| `orgao` | 15 |
| `serie` | 13 |
| `documento` | 10 |
| `instalacao_federacao` | 9 |
| `procedimento` | 9 |
| `tipo_procedimento` | 9 |
| `contato` | 5 |
| `controle_interno` | 5 |
| `plano_trabalho` | 5 |
| `protocolo_federacao` | 5 |
| `assunto` | 4 |

## Distribuição funcional aproximada

| Categoria | Tabelas |
|---|---:|
| Relacionamentos | 36 |
| Outros | 26 |
| Classificação e catálogo | 16 |
| Infraestrutura e auditoria | 13 |
| Tramitação e atividades | 13 |
| Identidade e organização | 12 |
| Federação | 11 |
| Comunicação | 9 |
| Modelos e conhecimento | 8 |
| Publicação | 8 |
| Blocos e grupos | 7 |
| Gestão documental | 7 |
| Contatos e participantes | 6 |
| Acesso e segurança | 5 |
| Documentos | 5 |
| Assinaturas | 3 |
| Editor e versões | 3 |
| Integrações e serviços | 3 |
| Núcleo processual | 2 |
| Arquivos | 1 |

## Arquivos derivados

- `inventario_schema_sei_5_0_0.csv`: inventário por tabela.
- `manifesto_compatibilidade_sei_dart.json`: manifesto de compatibilidade em formato legível por máquina.
