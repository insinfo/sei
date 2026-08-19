# 07 — Inventário administrativo do SEI e do SIP

## 1. Separação de responsabilidades

### SIP

O **Sistema de Permissões (SIP)** administra principalmente:

- órgãos;
- unidades e hierarquia;
- usuários;
- sistemas;
- perfis;
- recursos;
- permissões de usuário por unidade.

Uma permissão liga, de forma simplificada:

```text
usuário + sistema + perfil + unidade
```

O SIP define **quem pode entrar, em qual unidade e com quais recursos**.

### SEI

A Administração do SEI define **como processos e documentos funcionam**:

- tipos de processo;
- tipos de documento;
- modelos e estilos;
- hipóteses legais;
- contatos;
- pontos de controle;
- assuntos e temporalidade;
- integrações;
- parâmetros e auditoria.

## 2. Estrutura organizacional e segurança

| Recurso | Finalidade | Risco/limitação |
|---|---|---|
| Órgãos | Representar entidades da instalação. | Alterações afetam numeração, acesso e integrações. |
| Unidades | Representar setores de trabalho. | Unidade não deve ser usada como simples grupo de pessoas; possui efeitos processuais e históricos. |
| Hierarquia de unidades | Organizar estrutura administrativa. | Mudanças precisam preservar histórico e vigência. |
| Usuários | Identificar pessoas internas. | Cadastro duplicado ou sem contato/CPF prejudica assinatura e módulos. |
| Perfis | Agrupar recursos autorizados. | Perfil excessivo viola menor privilégio. |
| Recursos | Representar ações/telas do sistema. | Habilitar recurso sem treinamento pode produzir atos inadequados. |
| Permissões | Conceder perfil ao usuário em unidade. | Permissão global `*` deve ser excepcional. |
| Assinaturas das Unidades | Definir cargos/funções selecionáveis na assinatura. | Cargo disponível não prova competência jurídica do assinante. |
| Autenticação 2FA | Reforçar login. | Depende de política de recuperação e gestão de dispositivos. |

## 3. Cadastros de processo e acesso

| Recurso | Finalidade | Dependências e comportamento |
|---|---|---|
| Tipo de Processo | Categorizar processos com assuntos, temporalidade, acesso e restrição por órgão/unidade. | Deve estar alinhado à classificação documental e ao negócio. |
| Tabela de Assuntos | Classificar processos e definir temporalidade/destinação. | Requer governança arquivística; não deve ser taxonomia improvisada. |
| Hipóteses Legais | Fundamentar acesso restrito ou sigiloso. | Deve usar base legal válida; não apenas norma interna. |
| Ponto de Controle | Definir fases/categorias disponíveis aos tipos de processo. | É classificação gerencial, não workflow obrigatório. |
| Plano de Trabalho | Definir sequência de atividades, a partir da versão 4.1. | Precisa ser mantido pelas áreas responsáveis. |
| Contatos | Manter pessoas, entidades, endereços e dados para metadados/comunicação. | Deduplicação e atualização são essenciais. |
| Tipos/Categorias/Cargos/Títulos/Tratamentos/Vocativos | Estruturar o cadastro de contatos. | Excesso de categorias pode tornar o cadastro inconsistente. |
| Usuários Externos | Permitir consulta e assinatura por pessoas externas. | Exige validação cadastral, escopo de acesso e política LGPD. |

## 4. Documentos e editor

| Recurso | Finalidade | Dependências e comportamento |
|---|---|---|
| Modelos do Editor | Definir estrutura institucional do documento. | Composto por seções; mudanças devem ser versionadas e testadas. |
| Seções | Cabeçalho, título, corpo, assinatura, rodapé e outras. | Ordem, leitura, dinâmica e estilos afetam todos os documentos daquele tipo. |
| Estilos | Padronizar fonte, tamanho, alinhamento e ênfase. | Estilos mal definidos produzem documentos inconsistentes. |
| Tarjas | Configurar informações de assinatura/autenticação e validação. | Conteúdo possui impacto jurídico e deve ser revisado. |
| Formatos de imagem | Controlar imagens permitidas no editor. | Formatos/tamanhos impactam segurança e PDF. |
| Tipos de Documento | Definir espécies, modo interno/externo/formulário, modelo e numeração. | Deve refletir classificação documental, não apenas nomes de telas. |
| Grupos de Tipos de Documento | Organizar espécies internas, externas e gerais. | Grupo é organização, não nível de acesso. |
| Numeração | Configurar sequência automática por órgão/unidade/tipo. | Mudança pode causar colisão ou quebra de padrão. |
| Extensões permitidas | Autorizar formatos de upload. | Deve equilibrar necessidade, segurança, antivírus, tamanho e conversão. |
| Tipos de Formulários | Criar documentos estruturados e validados. | Layout limitado; exclusão de campo é irreversível. |
| Textos Padrão institucionais/locais | Reutilizar conteúdo. | Precisam de revisão de vigência e responsáveis. |

## 5. Comunicação, publicação e grupos

| Recurso | Finalidade | Limitações |
|---|---|---|
| Grupos Institucionais de Contato | Agrupar contatos. | Não concedem acesso. |
| Grupos Institucionais de E-mail | Agrupar endereços. | Dependem de qualidade do cadastro e limites SMTP. |
| Grupos Institucionais de Envio | Agrupar unidades. | Paralelismo precisa respeitar dependências do processo. |
| Veículos de Publicação | Configurar meios de publicação. | Publicação efetiva pode depender de serviço externo. |
| Feriados | Apoiar cálculos de dias úteis. | Calendário precisa ser mantido por localidade/órgão. |
| E-mails do Sistema | Definir remetentes e mensagens institucionais. | Erro pode gerar comunicação externa inadequada. |
| Notícias | Exibir comunicados no SEI. | Não substitui canal formal de governança. |
| Localidades | Apoiar contatos, endereços e parametrizações. | Base desatualizada prejudica correspondência. |

## 6. Integrações, auditoria e infraestrutura

| Recurso | Finalidade | Limitações/riscos |
|---|---|---|
| Sistemas/Web Services | Cadastrar sistemas externos e operações autorizadas. | Chaves, IPs, tipos e unidades devem seguir menor privilégio. |
| Monitoramento de Serviços | Acompanhar chamadas de integração. | Não substitui observabilidade central. |
| Regras de Auditoria | Definir eventos a auditar. | Cobertura insuficiente dificulta investigação; excesso gera volume. |
| Auditoria | Consultar atos relevantes. | Deve ter retenção e acesso restrito. |
| Logs | Diagnosticar erros/configuração. | Contêm detalhes técnicos e podem expor dados sensíveis. |
| Parâmetros | Alterar comportamento do sistema e módulos. | Mudança direta sem controle pode quebrar produção. |
| Sequências | Controlar numerações internas. | Ajuste incorreto causa duplicidade ou saltos. |
| Histórico administrativo | Registrar alterações cadastrais/configurações. | Deve ser preservado e consultável. |

## 7. Dependências técnicas usuais

| Componente | Papel |
|---|---|
| Servidor web + PHP | Executar interface e regras do SEI. |
| Banco relacional | Persistir metadados, documentos lógicos, permissões e histórico. |
| Repositório de arquivos | Armazenar conteúdo de documentos externos e artefatos. |
| SIP | Estrutura, usuários, perfis e permissões. |
| Memcached | Cache e, conforme configuração, sessões. |
| Solr | Indexação e pesquisa. |
| JODConverter + LibreOffice | Conversão de formatos de escritório. |
| SMTP | E-mails, acessos externos e notificações. |
| Agendamentos/cron/workers | Tarefas periódicas, indexação e módulos como PEN. |
| Proxy/load balancer | TLS, roteamento e escala horizontal. |
| Antivírus/antimalware | Recomendado para uploads externos. |
| Backup e monitoramento | Recuperação, disponibilidade e observabilidade. |

## 8. Módulos oficiais relevantes

A lista abaixo não é exaustiva; módulos variam por órgão e versão.

| Módulo | O que acrescenta | Dependências principais |
|---|---|---|
| Integração PEN/Tramita.GOV.BR | Envio/recebimento externo, mapeamentos, recibos e monitoramento. | Certificado, API Tramita, filas/agendamentos, mapeamentos de unidades/documentos/hipóteses. |
| Assinatura Eletrônica gov.br | Assinatura avançada/qualificada via gov.br/nuvem. | CPF de usuário, conta gov.br, integração e certificados. |
| Login Externo gov.br | Autenticação de usuário externo com Conta gov.br. | Adesão e configuração OIDC/SSO. |
| Gestão Documental | Arquivar, desarquivar, prazos de guarda, avaliação e eliminação. | Tabela de temporalidade, unidades de arquivo, perfis e procedimentos arquivísticos. |
| Resposta ao Protocolo.GOV.BR | Responder solicitações capturadas do Protocolo.GOV.BR. | Integração com Protocolo.GOV.BR e configurações específicas. |
| Peticionamento Eletrônico | Protocolização e atuação externa. | Usuários externos, tipos de processo/documento e regras de conferência. |

## 9. Governança recomendada

- Separar perfis de negócio, administração e informática.
- Versionar modelos, parâmetros e configurações em repositório.
- Homologar alterações com banco e arquivos representativos.
- Registrar quem aprovou cada hipótese legal, tipo e modelo.
- Preferir desativação a exclusão quando houver histórico de uso.
- Manter dicionário de tipos de processo e documento.
- Revisar contatos duplicados e usuários inativos.
- Testar PDF, pesquisa, assinatura e integração após atualização.
- Não expor Solr, JOD, banco ou Memcached à internet.

## Fontes principais

- [Manual do Administrador SEI][A0]
- [Gestão de Permissões no SIP][A11]
- [Tipo de Processo][A2]
- [Hipóteses Legais][A3]
- [Editor][A4]
- [Tipos de Documento][A5]
- [Extensões Permitidas][A6]
- [Tipos de Formulários][A7]
- [Contatos][A8]
- [Grupos Institucionais][A9]
- [Tabela de Assuntos][A10]

[A0]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/index.html
[A11]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Configura%C3%A7%C3%A3o_da_estrutura/Man_Adm_SEI_03-Config_Estr_Organizacional-05_Gestao_de_Permissoes.html
[A2]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-05_Tipo_de_Processo.html
[A3]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-04_Hipoteses_Legais.html
[A4]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-06_Editor.html
[A5]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-07_Tipo_de_Documento.html
[A6]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-08_Extensoes_de_Arquivos_Permitidos.html
[A7]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-18_Tipos_de_Formul%C3%A1rios.html
[A8]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-02_Contatos.html
[A9]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-13_Grupos_Institucionais.html
[A10]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-17_Tabelas_de_Assuntos.html
