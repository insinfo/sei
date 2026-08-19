# 03 — Documentos, modelos, contatos, grupos e blocos

## 1. Tipos de conteúdo documental

### Documento interno

É produzido no editor HTML do próprio SEI. O tipo documental define o modelo, a numeração, o grupo e se poderá ser usado como interno, externo ou ambos.

**Vantagens**

- integração nativa com assinaturas;
- variáveis institucionais;
- histórico de versões;
- estilos padronizados;
- pesquisa textual direta;
- tarjas de assinatura e autenticação.

**Limitações**

- não é um arquivo DOCX;
- recursos de paginação, tabelas e layout são mais limitados que Word/LibreOffice;
- a aparência depende dos modelos HTML e estilos administrados;
- edição concorrente em tempo real não é o objetivo do editor.

### Documento externo

É um arquivo enviado por upload. As extensões autorizadas são configuradas pelo administrador.

**Vantagens**

- preserva o formato recebido;
- aceita PDF, imagens e outros formatos habilitados;
- permite registrar remetente, data, número, autenticidade e nível de acesso.

**Limitações**

- pesquisa de conteúdo depende de texto extraível ou OCR;
- tamanho e extensão são limitados por parâmetros;
- conversão para PDF depende do formato e dos serviços disponíveis;
- não possui o mesmo modelo de versões do documento interno.

### Formulário do sistema

Documento composto por campos configuráveis:

- data;
- dinheiro;
- lista;
- inteiro e decimal;
- texto simples/grande;
- texto com máscara;
- opções;
- sinalizadores;
- informações fixas.

**Vantagem:** dados estruturados, validados e consistentes.

**Limitação oficial:** o recurso não permite livre formatação do layout; não é indicado quando a aparência do documento é requisito central.

## 2. Quatro mecanismos que parecem “modelo”, mas são diferentes

| Mecanismo | Escopo | O que reutiliza | Quando usar | Limitação principal |
|---|---|---|---|---|
| Modelo do Editor | Institucional/administrativo | Estrutura: cabeçalho, título, corpo, assinatura, rodapé, estilos e variáveis | Padronizar tipos documentais oficiais | Exige administração e frequentemente conhecimento de HTML. |
| Documento Favorito | Unidade | Conteúdo e formato integral de um documento anterior | Repetir minuta semelhante | A cópia é independente e pode carregar conteúdo desatualizado. |
| Texto Padrão | Unidade | Fragmento de texto editável | Cláusulas, parágrafos e respostas recorrentes | Não define documento completo nem validações. |
| Base de Conhecimento | Associada a tipo de processo | Instrução de trabalho, referências, links e PDF | Explicar como executar o processo | Orienta pessoas, mas não automatiza etapas. |

### Modelo do Editor

Administradores configuram:

- modelos;
- seções do modelo;
- estilos;
- tarjas de assinatura/autenticação;
- formatos de imagem permitidos.

Uma seção pode ser dinâmica, somente leitura, cabeçalho, corpo, assinatura ou rodapé. Variáveis como sigla do órgão/unidade são substituídas pelo sistema.

### Documento Favorito

Salvar um documento nos Favoritos permite utilizá-lo como modelo de um novo documento. O novo conteúdo pode ser editado sem alterar o documento de origem.

Um processo também pode ser favorito, mas apenas como atalho; ele não vira um “modelo de processo”.

### Texto Padrão

É um fragmento editável que pode ser inserido:

- na criação de documento;
- pelo AutoTexto dentro do editor;
- em e-mails produzidos no SEI.

Pode usar variáveis do sistema. Deve ter responsável pela manutenção para evitar textos normativos desatualizados.

### Base de Conhecimento

É associada a um ou mais tipos de processo e pode conter:

- descrição das etapas;
- legislação;
- links de intranet/internet;
- referências a documentos/processos;
- PDF complementar;
- versões liberadas.

A unidade autora prepara nova versão e a libera. Usuários podem pesquisar por palavras-chave e acessar a base associada ao tipo do processo.

## 3. Contatos

Contatos são entidades usadas nos metadados e comunicações do SEI, como:

- interessado do processo;
- remetente de documento externo;
- destinatário;
- usuário externo;
- destinatário de circular ou e-mail.

O cadastro administrativo pode usar classificações correlacionadas:

- tipo de contato;
- categoria;
- cargo;
- título;
- tratamento;
- vocativo.

### Benefícios

- padroniza nomes e dados;
- melhora pesquisa;
- permite geração de circulares e comunicações;
- evita digitação repetida.

### Limitações e riscos

- duplicidade de contatos prejudica pesquisa e relatórios;
- cadastro desatualizado gera documentos e e-mails incorretos;
- contato não é usuário nem permissão;
- um contato não recebe acesso ao processo automaticamente.

## 4. Grupos

### Grupo de Contatos

Agrupa contatos cadastrados. Serve para selecionar pessoas/entidades em lote.

### Grupo de E-mail

Agrupa endereços eletrônicos. Serve para envio de mensagens.

### Grupo de Envio

Agrupa unidades administrativas. Serve para enviar processos a diversas unidades sem selecioná-las uma a uma.

### Grupo de Blocos

Organiza blocos de assinatura, reunião ou internos, conforme a tela e o contexto.

### Grupos institucionais e grupos locais

A administração pode criar grupos institucionais reutilizáveis pelo órgão. Usuários/unidades também podem ter grupos operacionais conforme permissões. A disponibilidade exata depende da configuração.

### O que grupos não fazem

- não concedem perfil;
- não atribuem processo a pessoas;
- não criam uma unidade;
- não tornam contatos usuários;
- não implementam workflow;
- não garantem que tarefas paralelas sejam adequadas.

## 5. Blocos

### Bloco de Assinatura

Disponibiliza minutas para usuários de outras unidades ou agrupa documentos para assinatura em lote.

Permite à unidade destinatária:

- visualizar a minuta;
- editar enquanto não houver assinatura;
- consultar o processo;
- assinar individualmente ou em lote;
- devolver o bloco.

**Vantagem:** colher assinatura sem tramitar formalmente o processo.

**Limitação:** bloco não transfere a responsabilidade pelo processo. O processo pode continuar aberto somente na unidade de origem.

### Bloco de Reunião

Disponibiliza processos para conhecimento/discussão de outra unidade, permitindo visualizar minutas não assinadas sem atuação formal.

**Vantagem:** apoio a reunião e decisão colegiada.

**Limitação:** não equivale a envio e não autoriza a unidade receptora a executar atos processuais normais.

### Bloco Interno

Agrupa processos relacionados para organização da unidade e permite acompanhar atualizações posteriores de processos públicos ou restritos que já tramitaram nela.

**Vantagem:** organização temática ou por carteira de trabalho.

**Limitações:**

- só a unidade criadora vê;
- o processo precisa estar aberto na unidade para ser incluído inicialmente;
- não substitui Acompanhamento Especial quando o objetivo é apenas acompanhar um processo fora da unidade.

## 6. Escolha rápida

| Necessidade | Recurso |
|---|---|
| Criar padrão institucional de ofício | Modelo do Editor + Tipo de Documento |
| Reaproveitar um ofício anterior | Documento Favorito |
| Inserir cláusula recorrente | Texto Padrão/AutoTexto |
| Explicar o procedimento de contratação | Base de Conhecimento |
| Coletar dados estruturados | Formulário do Sistema |
| Obter assinatura de outra unidade sem enviar processo | Bloco de Assinatura |
| Mostrar minuta para reunião | Bloco de Reunião |
| Agrupar processos da carteira da equipe | Bloco Interno/Marcador |
| Enviar processo para várias unidades | Grupo de Envio, com cautela sobre paralelismo |
| Enviar circular a muitas pessoas | Grupo de Contatos + Circular |

## 7. Implicações para uma nova implementação

> Recomendações de arquitetura.

- Separar claramente **template institucional**, **modelo favorito**, **snippet** e **procedimento de conhecimento**.
- Versionar modelos e textos padrão.
- Evitar copiar dados de contato sem chave estável; aplicar deduplicação.
- Tratar grupos como listas de seleção, não como ACL.
- Modelar bloco como compartilhamento temporário com estado: rascunho, disponibilizado, recebido, devolvido, concluído.
- Impedir edição de documento assinado após ciência/acesso por outra unidade, preservando integridade.

## Fontes principais

- [Operações Básicas com Documentos][U5]
- [Outras Operações com Documentos][U6]
- [Blocos][U7]
- [Base de Conhecimento][U8]
- [Editor — Administração][A4]
- [Tipos de Documento][A5]
- [Tipos de Formulários][A7]
- [Contatos][A8]
- [Grupos Institucionais][A9]

[U5]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_basicas_com_documentos.html
[U6]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Outras_operacoes_com_documentos.html
[U7]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Blocos.html
[U8]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Acompanhando_e_recuperando_informacoes_de_processos.html
[A4]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-06_Editor.html
[A5]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-07_Tipo_de_Documento.html
[A7]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-18_Tipos_de_Formul%C3%A1rios.html
[A8]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-02_Contatos.html
[A9]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/Administracao_sei/Man_Adm_SEI_04-Administra%C3%A7%C3%A3o_SEI-13_Grupos_Institucionais.html
