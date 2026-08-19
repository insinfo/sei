# 09 — Fontes e rastreabilidade

## Data e escopo da pesquisa

- Data da consolidação: **18 de agosto de 2026**.
- Escopo funcional principal: **SEI 4.0+**, incluindo recursos documentados para 4.1 e 5.0.
- Ambiente visual: instalação de testes SEI/PEN apresentada nas capturas.

## Classificação das afirmações

| Selo | Significado |
|---|---|
| FATO OFICIAL | Está explicitamente descrito em manual ou arquivo oficial. |
| OBSERVAÇÃO | Foi visto diretamente nas capturas ou no Compose fornecido. |
| INFERÊNCIA | Resulta da combinação de fluxo oficial e configuração técnica. |
| RECOMENDAÇÃO | Proposta de arquitetura/teste para outra implementação. |

A afirmação de que a geração nativa de PDF é síncrona foi classificada como **inferência técnica**, porque:

- o manual descreve clique em Gerar seguido de download automático;
- a configuração pública do SEI trata geração de PDF dentro de limites de execução do processo web;
- não foi encontrada, no fluxo nativo oficial consultado, uma interface de fila/job para essa exportação.

## Manual oficial do usuário

1. [Manual do Usuário SEI 4.0+](https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/)
2. [Iniciando Operações](https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Iniciando_operacoes.html)
3. [Operações Básicas com Processos](https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_basicas_com_processos.html)
4. [Operações de Manutenção e Acompanhamento de Processos](https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_de_manutencao_e_acompanhamento_de_processos.html)
5. [Outras Operações com Processos](https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Outras_operacoes_com_processos.html)
6. [Operações Básicas com Documentos](https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_basicas_com_documentos.html)
7. [Outras Operações com Documentos](https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Outras_operacoes_com_documentos.html)
8. [Blocos](https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Blocos.html)
9. [Acompanhando e Recuperando Informações de Processos](https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Acompanhando_e_recuperando_informacoes_de_processos.html)
10. [Usuário Externo](https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Usuario_externo.html)

## Manual oficial do administrador

1. [Manual do Administrador SEI](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/index.html)
2. [Gestão de Permissões](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Configura%C3%A7%C3%A3o_da_estrutura/Man_Adm_SEI_03-Config_Estr_Organizacional-05_Gestao_de_Permissoes.html)
3. [Contatos](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-02_Contatos.html)
4. [Hipóteses Legais](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-04_Hipoteses_Legais.html)
5. [Tipo de Processo](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-05_Tipo_de_Processo.html)
6. [Editor](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-06_Editor.html)
7. [Tipos de Documento](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-07_Tipo_de_Documento.html)
8. [Extensões de Arquivos Permitidos](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-08_Extensoes_de_Arquivos_Permitidos.html)
9. [Ponto de Controle](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-10_Ponto_de_controle.html)
10. [Sistemas e Web Services](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-11_Sistemas.html)
11. [Grupos Institucionais](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-13_Grupos_Institucionais.html)
12. [Tabela de Assuntos](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-17_Tabelas_de_Assuntos.html)
13. [Tipos de Formulários](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-18_Tipos_de_Formul%C3%A1rios.html)
14. [Logs](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-24_Log.html)
15. [Parâmetros](https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-25_Par%C3%A2metros.html)

## Módulos oficiais

1. [Módulo Gestão Documental](https://manuais.processoeletronico.gov.br/pt-br/latest/MODULOS-SEI/Gestao_documental.html)
2. [Módulo de Integração PEN/Tramita.GOV.BR — Uso](https://manuais.processoeletronico.gov.br/pt-br/latest/Manual-de-Integra%C3%A7%C3%A3o-ao-Tramita-GOV.BR/USAGE.html)
3. [Módulo PEN — Instalação](https://manuais.processoeletronico.gov.br/pt-br/latest/Manual-de-Integra%C3%A7%C3%A3o-ao-Tramita-GOV.BR/INSTALL.html)
4. [Módulo de Assinatura Eletrônica](https://manuais.processoeletronico.gov.br/pt-br/latest/MODULOS-SEI/Modulo_assinatura_avancada.html)
5. [Módulo de Login Externo GOV.BR](https://manuais.processoeletronico.gov.br/pt-br/latest/MODULOS-SEI/Login_unico.html)
6. [Módulo de Resposta](https://manuais.processoeletronico.gov.br/pt-br/latest/MODULOS-SEI/Modulo_resposta.html)

## Código/configuração pública de infraestrutura

1. [Projeto `pengovbr/sei-docker`](https://github.com/pengovbr/sei-docker)
2. [Configuração de desenvolvimento do SEI](https://github.com/pengovbr/sei-docker/blob/main/containers/app-php8/app-dev-php8/assets/scripts-e-automatizadores/ConfiguracaoSEI.php)
3. [Imagem JODConverter 4.4.8](https://github.com/pengovbr/sei-docker/blob/main/containers/jod4.4.8/Dockerfile)
4. [Configuração do JODConverter](https://github.com/pengovbr/sei-docker/blob/main/containers/jod4.4.8/assets/application.yaml)
5. [Imagem Solr 9.6.1](https://github.com/pengovbr/sei-docker/blob/main/containers/solr-9.6.1/Dockerfile)
6. [Schema do core `sei-protocolos`](https://github.com/pengovbr/sei-docker/blob/main/containers/solr-9.6.1/assets/solr9.6.1sei/sei-cores-9.6.1/sei-protocolos/conf/schema.xml)
7. [Base de referência de banco do Poder Executivo](https://github.com/pengovbr/sei-db-ref-executivo)

## Referências fornecidas pelo usuário

- [`referencias/docker-compose-testes-pen.yml`](referencias/docker-compose-testes-pen.yml)
- imagens em [`assets/`](assets/)

### Imagens

| Arquivo | Conteúdo |
|---|---|
| `01-processo-aberto-unidade-concluir.png` | Processo aberto somente na unidade e botão Concluir. |
| `02-menu-principal-sei.png` | Menu do perfil básico observado. |
| `03-gerar-pdf-processo.png` | Seleção de documentos para PDF. |
| `04-sobrestamento.png` | Tela de sobrestamento. |
| `05-controle-prazo-opcoes.png` | Modalidades do controle de prazo. |
| `06-controle-prazo-data.png` | Controle de prazo por data certa. |
| `07-lista-controles-prazo.png` | Lista com prazo restante e atrasado. |
| `08-marcadores-processo.png` | Marcador e texto associados ao processo. |

## Lacunas conhecidas

- Não foi realizada inspeção do código-fonte privado integral do SEI usado no ambiente.
- A estrutura exata de tabelas/classes internas pode mudar por versão.
- Módulos de terceiros não estão inventariados.
- Regras locais do órgão podem restringir operações além do comportamento técnico.
- A gestão documental pode ser nativa, modular ou desabilitada conforme implantação.
- O comportamento de conversão de cada formato depende do LibreOffice/JOD e das fontes instaladas.
