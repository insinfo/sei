# Roteiro mestre para reimplementar o SEI em Dart com compatibilidade de banco e com o mod-sei-pen

**Data de referência:** 5 de agosto de 2026  
**Baseline inicial recomendado:** SEI 5.0.0 + mod-sei-pen 4.0.3 + Tramita.GOV.BR REST v4  
**Stack-alvo sugerida:** Dart VM no backend, Angel3 na API interna, Shelf na API pública quando necessário, NgDart 8 no frontend, PostgreSQL por adaptadores separados, workers em Dart/isolates e repositório de arquivos compatível com o SEI, seguindo a organização prática do `new_sali`.

---

## 1. Objetivo real do projeto

O objetivo não deve ser apenas criar um sistema “parecido com o SEI”. O projeto deve ser tratado como uma **reimplementação compatível por contrato**, capaz de:

1. abrir e interpretar corretamente uma base oficial do SEI;
2. criar e alterar registros que continuem válidos para o SEI oficial;
3. preservar as regras transacionais, de numeração, tramitação, acesso, assinatura, versionamento, auditoria e armazenamento de arquivos;
4. reproduzir os recursos e permissões mantidos no SIP;
5. reproduzir os comportamentos do módulo de integração ao Tramita.GOV.BR;
6. passar por testes diferenciais, executando os mesmos casos no SEI oficial e na implementação Dart;
7. permitir retorno ao SEI oficial sem conversão destrutiva dos dados.

A expressão **“100% compatível”** precisa ser formalizada. Para este roteiro, ela significa compatibilidade de:

- esquema físico;
- conteúdo e semântica dos dados;
- transações e concorrência;
- arquivos e hashes;
- regras de negócio;
- serviços e integrações externas;
- recursos e permissões do SIP;
- comportamentos do mod-sei-pen;
- atualização e reversibilidade operacional.

Neste projeto, por determinação do requisito, ela também inclui **equivalência da experiência do usuário**. A interface padrão deve reproduzir a hierarquia, a densidade, a localização dos comandos, a árvore do processo, os estados, os textos, os atalhos, o foco, as mensagens e os fluxos observáveis do SEI 5.0.0. Qualquer modernização só poderá existir como tema ou modo alternativo, desabilitado por padrão e sem substituir o modo compatível.

### 1.1 Limite importante: módulo PHP versus sistema Dart

O pacote oficial do mod-sei-pen é escrito em PHP e carrega classes, telas, scripts e pontos de extensão próprios do SEI. Um sistema inteiramente em Dart **não consegue carregar esse pacote PHP sem um runtime PHP ou uma camada de compatibilidade PHP**.

Há três níveis possíveis:

| Nível | Significado | Recomendação |
|---|---|---|

| Compatibilidade de banco e comportamento | Implementar em Dart as mesmas tabelas `md_pen_*`, regras, estados, recibos, telas e tarefas | Meta principal |


A estratégia mais segura é manter o módulo oficial em um ambiente de referência e utilizá-lo como **oráculo de testes**, enquanto o módulo equivalente é portado para Dart.

---

## 2. Evidências obtidas dos arquivos fornecidos

### 2.1 Estrutura do banco principal

A análise dos dumps fornecidos encontrou:

- **194 tabelas funcionais** no dump PostgreSQL da Base de Referência SEI 5.0.0;
- **122 sequências PostgreSQL**;
- **316 tabelas** no dump MySQL, das quais:
  - 194 são as mesmas tabelas funcionais;
  - 122 são tabelas `seq_*` usadas para geração de identificadores no MySQL;
- os nomes e os conjuntos de colunas das 194 tabelas funcionais coincidem entre PostgreSQL e MySQL;
- 42 tabelas apresentam ordem física de colunas diferente entre os dialetos;
- a cópia íntegra da Base de Referência declara e usa `LATIN1`; uma cópia UTF-8 corrompida com caracteres de substituição (`�`) foi isolada e nunca deve ser usada para restauração;
- nenhum dos dumps analisados contém tabelas `md_pen_*`.

Consequências práticas:

1. todos os `INSERT` devem nomear explicitamente as colunas;
2. o gerador de identificadores deve ter implementação diferente para PostgreSQL e MySQL;
3. o backend deve validar o encoding de cada instalação oficial; para a Base de Referência íntegra 5.0.0, a conexão e o banco usam LATIN1;
4. o esquema do módulo PEN deverá ser instalado ou migrado separadamente;
5. não é seguro usar um ORM genérico como fonte da verdade do domínio.

### 2.2 Cadastros confirmados na Base de Referência 5.0.0

A carga de referência contém:

| Cadastro | Quantidade verificada |
|---|---:|
| Tipos de processo (`tipo_procedimento`) | 318 |
| Tipos de documento (`serie`) | 254 |
| Hipóteses legais | 23 |
| Tipos de prioridade | 6 |
| Assuntos arquivísticos | 684 |
| Estilos | 39 |
| Modelos | 69 |
| Cargos | 81 |
| Vocativos | 63 |
| Tratamentos | 4 |
| Extensões cadastradas | 41 |
| Extensões ativas | 20 |

Esses dados fazem parte do comportamento esperado da Base de Referência. Eles não devem ser tratados como simples “seed descartável”; os vínculos, identificadores, flags e relacionamentos precisam ser preservados.

### 2.3 Principais hubs relacionais

As tabelas mais referenciadas por chaves estrangeiras são `unidade`, `usuario`, `protocolo`, `atividade`, `orgao`, `serie`, `documento`, `procedimento` e `tipo_procedimento`. Isso mostra que a arquitetura deve começar pelo núcleo organizacional e processual, e não pela interface.

### 2.4 O que não está presente nos arquivos

Para declarar compatibilidade completa ainda serão necessários:

- adaptador, autenticação, sessão e matriz de autorização do SIP correspondente à mesma versão, embora o dump PostgreSQL de referência já esteja restaurado localmente;
- código-fonte ou instalação autorizada da versão exata do SEI usada como oráculo;
- diretório e configuração de `RepositorioArquivos`;
- configuração do mecanismo de pesquisa e indexação;
- pacote exato do mod-sei-pen e seus scripts de instalação;
- certificado e acesso à homologação do Tramita.GOV.BR;
- corpus anonimizado de processos reais cobrindo todos os fluxos.

---

## 3. Estratégia geral recomendada

A estratégia recomendada é uma reimplementação incremental, mantendo coexistência e reversibilidade.

### 3.1 Não começar pela clonagem da tela

A ordem correta é:

1. congelar o contrato da versão-alvo;
2. criar um laboratório com SEI oficial;
3. construir o comparador de esquema e comportamento;
4. implementar leitura do banco;
5. implementar escrita transacional;
6. implementar arquivos, editor e assinatura;
7. implementar autorização SIP;
8. portar o PEN;
9. executar em modo sombra;
10. realizar corte gradual.

Começar pela interface criaria uma aplicação visualmente convincente, mas incompatível com as invariantes mais difíceis do SEI.

### 3.2 Arquitetura inicial: monólito modular

Para a primeira versão, use um **monólito modular**, não microserviços. O SEI executa operações que atravessam muitas tabelas dentro da mesma transação. Dividir prematuramente em serviços independentes aumentaria o risco de inconsistência.

A separação deve ser lógica, por pacotes Dart, mantendo um único limite transacional para o núcleo.

```text
NgDart 8
   |
   v
API Angel3 / fachada Shelf para integrações públicas
   |
   v
Camada de aplicação
   |
   +--> Núcleo processual
   +--> Documentos e editor
   +--> Acesso e SIP
   +--> Gestão documental
   +--> Publicação e pesquisa
   +--> PEN / Tramita.GOV.BR
   |
   v
Contrato de persistência
   +--> Adaptador PostgreSQL
   +--> Adaptador MySQL
   +--> Futuro: Oracle e SQL Server
   |
   +--> Repositório de arquivos
   +--> Índice de pesquisa
   +--> Workers/agendamentos
```

### 3.3 Estrutura sugerida do monorepositório

```text
apps/
  sei_web/                    # frontend NgDart 8
  sei_api/                    # API e fachada de compatibilidade
  sei_worker/                 # tarefas agendadas e filas
  sei_admin_cli/              # migração, diagnóstico e manutenção

packages/
  sei_domain/                 # entidades, valores, estados e invariantes
  sei_application/            # casos de uso e transações
  sei_db_contract/            # interfaces de sessão, query e dialeto
  sei_db_postgres/            # SQL e alocadores PostgreSQL
  sei_db_mysql/               # SQL e alocadores MySQL
  sei_schema_manifest/        # manifesto gerado das versões suportadas
  sei_sip/                    # recursos, perfis, hierarquias e autorização
  sei_protocol/               # NUP, protocolo, procedimentos e documentos
  sei_workflow/               # atividades, tarefas, tramitação e prazos
  sei_documents/              # documentos, seções, modelos e versões
  sei_editor/                 # editor, estilos, sanitização e HTML compatível
  sei_files/                  # RepositorioArquivos, streaming e hashes
  sei_signatures/             # assinatura eletrônica, certificados e tarjas
  sei_access/                 # nível de acesso, hipótese legal e acesso externo
  sei_catalog/                # assuntos, tipos, séries e cadastros
  sei_publication/            # boletim e veículos de publicação
  sei_records_management/     # arquivamento, avaliação e eliminação
  sei_search/                 # indexação e pesquisa
  sei_audit/                  # auditoria de infraestrutura e de protocolo
  sei_legacy_services/        # SOAP/serviços e rotas legadas
  sei_pen/                    # integração Tramita.GOV.BR
  sei_pen_schema/             # tabelas e migradores md_pen_*
  sei_compatibility_tests/    # testes diferenciais e golden masters
```

### 3.4 Dados auxiliares próprios

Não altere as 194 tabelas oficiais para guardar estado exclusivo da nova aplicação. Quando dados auxiliares forem indispensáveis, use uma das opções:

- outro banco;
- outro schema PostgreSQL;
- tabelas com prefixo próprio claramente separado;
- Redis somente para cache efêmero, nunca como fonte única de verdade.

O banco oficial deve continuar válido para execução do SEI original e dos scripts oficiais de atualização.

---

## 4. Definição formal de compatibilidade

Crie uma matriz de compatibilidade versionada no repositório.

### 4.1 Compatibilidade de esquema

O comparador deve verificar:

- tabelas;
- colunas;
- ordem física, apenas para diagnóstico;
- tipos;
- tamanho;
- precisão e escala;
- nulabilidade;
- valores padrão;
- chaves primárias;
- chaves estrangeiras;
- restrições únicas;
- índices e ordem de colunas;
- sequências;
- collation e encoding;
- funções, gatilhos e views, quando existirem;
- esquema `md_pen_*`;
- recursos do SIP.

O pipeline deve falhar se houver divergência não autorizada.

### 4.2 Compatibilidade de dados

Deve ser possível:

1. restaurar uma base criada pelo SEI oficial;
2. lê-la integralmente com o sistema Dart;
3. editar dados pelo sistema Dart;
4. voltar a abrir a mesma base com o SEI oficial;
5. obter os mesmos resultados de consulta e validação.

### 4.3 Compatibilidade comportamental

Para cada ação de usuário, compare:

- tabelas alteradas;
- linhas inseridas, atualizadas e excluídas;
- atividades geradas;
- identificadores consumidos;
- auditorias registradas;
- arquivos criados;
- mensagens de erro;
- permissões exigidas;
- efeitos em pesquisa, publicação e integração.

### 4.4 Compatibilidade operacional

Inclui:

- backup e restauração;
- jobs agendados;
- execução concorrente em múltiplos nós;
- sincronização de relógio;
- logs e métricas;
- recuperação após falha;
- idempotência de integrações;
- atualização de versão.

### 4.5 Arquivo de lock de compatibilidade

Mantenha um arquivo semelhante a:

```json
{
  "sei": "5.0.0",
  "sip": "versao-validada",
  "modSeiPen": "4.0.3",
  "tramitaApi": "rest-v4",
  "database": ["postgresql", "mysql"],
  "schemaManifest": "sha256-do-manifesto",
  "referenceCorpus": "sha256-do-corpus-anonimizado",
  "compatibilitySuite": "versao-da-suite"
}
```

Nunca declare suporte automático a “SEI 5.x”. Cada patch deve passar por diff e regressão.

---

## 5. Camada de banco de dados

### 5.1 Não usar o ORM como contrato principal

Um ORM pode ser usado em telas administrativas simples, mas não deve controlar o núcleo. As consultas críticas devem ser SQL explícito e revisado.

Motivos:

- o SEI usa herança de chave entre `protocolo`, `procedimento` e `documento`;
- existem muitos status `char(1)` com semântica própria;
- a ordem de colunas varia entre os dumps;
- a alocação de IDs varia por dialeto;
- consultas de tramitação precisam de bloqueios e índices específicos;
- um ORM pode alterar silenciosamente `NULL`, strings vazias, datas ou decimais.

### 5.2 Interface de dialeto

```dart
abstract interface class SeiDbDialect {
  String get name;

  Future<int> nextId(
    SeiDbSession session,
    String sequenceName,
  );

  String limitOffset({required int limit, required int offset});

  String forUpdate({bool skipLocked = false});

  String currentTimestampExpression();

  Object encodeLegacyText(String value);

  String decodeLegacyText(Object value);
}
```

O domínio não deve saber se está em PostgreSQL ou MySQL.

### 5.3 Alocação de identificadores

No PostgreSQL, a base possui sequências nativas. No MySQL, existem tabelas `seq_*` com `AUTO_INCREMENT`. O serviço de IDs deve ser isolado:

```dart
abstract interface class SeiIdAllocator {
  Future<int> nextProtocoloId(SeiDbSession tx);
  Future<int> nextAtividadeId(SeiDbSession tx);
  Future<int> nextDocumentoId(SeiDbSession tx);
  Future<int> next(String logicalSequence, SeiDbSession tx);
}
```

Os testes devem executar a mesma operação no SEI oficial e verificar:

- qual sequência foi consumida;
- quando o ID é obtido;
- se o ID é perdido em rollback;
- comportamento em concorrência;
- limites do tipo numérico.

### 5.4 IDs `bigint` e frontend web

No backend Dart VM, mantenha os IDs dentro do intervalo de 64 bits. Na comunicação JSON com o navegador, serialize `bigint` como **string**, porque a representação numérica do JavaScript não preserva com segurança todos os inteiros de 64 bits.

```json
{
  "idProtocolo": "9876543210123456"
}
```

Nunca transforme IDs em `double`.

### 5.5 Codificação e integridade textual

A aplicação pode trabalhar internamente em Unicode, mas a fronteira com o banco deve respeitar o contrato efetivamente comprovado em cada instalação oficial.

A Base de Referência íntegra 5.0.0 disponível em `backend/referencias/sei-db-ref-executivo/postgresql/v5.0.0/` usa LATIN1 de forma consistente e é a fonte exclusiva de restauração. A cópia UTF-8 com 14.424 caracteres `�` em `backup_sei_bd` é evidência de corrupção anterior e permanece isolada; ela não pode ser usada para validar textos, hashes ou assinaturas.

Implementar:

- validação explícita de `server_encoding`, `client_encoding` e corpus de texto antes de conectar a cada instalação;
- testes de ida e volta com acentos, cedilha, símbolos e caracteres do Windows-1252 encontrados em bases reais;
- proibição de normalização Unicode silenciosa;
- teste byte a byte para textos usados em hash ou assinatura, usando dump oficial íntegro;
- detecção de caracteres que não podem ser representados no banco-alvo;
- mensagem de erro funcional equivalente ao SEI.

### 5.6 Datas e fuso horário

A base usa `timestamp without time zone` no PostgreSQL e `datetime` no MySQL. Não converta automaticamente tudo para UTC sem confirmar o comportamento oficial.

Crie tipos distintos:

- `SeiLocalDateTime`: data/hora civil gravada no banco;
- `UtcInstant`: integrações e telemetria;
- `LocalDate`: prazos e datas sem horário.

Defina uma zona institucional única e sincronize os servidores.

### 5.7 Valores monetários

Campos `numeric/decimal`, como `din_valor`, devem usar decimal exato, jamais `double`.

### 5.8 Flags e estados

Preserve os valores originais `S/N` e códigos de estado. Não grave booleanos nativos em colunas `char(1)`.

Use tipos de valor:

```dart
enum SimNao {
  sim('S'),
  nao('N');

  const SimNao(this.dbValue);
  final String dbValue;
}
```

Para estados cuja semântica ainda não foi completamente mapeada, use wrappers que rejeitem valores desconhecidos apenas em escrita, mas permitam leitura e diagnóstico.

### 5.9 Transações

Cada caso de uso deve declarar explicitamente sua fronteira transacional.

Exemplo de inclusão de documento:

1. iniciar transação;
2. obter ID de protocolo/documento;
3. inserir `protocolo`;
4. inserir `documento`;
5. criar conteúdo e seções;
6. relacionar participantes, assuntos e atributos;
7. gerar atividade;
8. gravar auditorias;
9. preparar escrita do arquivo, se externo;
10. confirmar banco e arquivo por protocolo de escrita atômica;
11. commit.

O comportamento de falha entre banco e sistema de arquivos precisa ser testado. Não pode haver anexo registrado sem arquivo, nem arquivo órfão silencioso.

### 5.10 Concorrência

Criar testes para:

- geração simultânea de NUP;
- numeração de documentos;
- abertura e conclusão de atividades;
- assinatura concorrente;
- inclusão simultânea de documentos no mesmo processo;
- envio PEN duplicado;
- recebimento do mesmo trâmite por dois workers;
- reprocessamento após timeout.

Use bloqueios de linha e `FOR UPDATE`, incluindo `SKIP LOCKED` somente onde o comportamento for controlado e comprovado.

---

## 6. Núcleo de domínio do SEI

### 6.1 Modelo central de protocolo

O banco usa `protocolo` como supertipo. `procedimento` e `documento` compartilham a mesma chave do protocolo por FK.

O modelo Dart deve refletir isso:

```dart
sealed class Protocolo {
  const Protocolo({required this.id, required this.numeroFormatado});
  final int id;
  final String numeroFormatado;
}

final class ProcessoAdministrativo extends Protocolo {
  // dados de procedimento
}

final class DocumentoSei extends Protocolo {
  // dados de documento
}
```

A persistência deve inserir o supertipo e o subtipo na mesma transação.

### 6.2 Processos

Tabelas centrais:

- `protocolo`;
- `procedimento`;
- `tipo_procedimento`;
- `rel_protocolo_assunto`;
- `participante`;
- `rel_protocolo_atributo`;
- `controle_unidade`;
- `atividade`;
- `acesso`;
- `rel_protocolo_protocolo`.

Casos de uso mínimos:

1. autuar processo;
2. alterar metadados permitidos;
3. incluir interessado;
4. classificar por assunto;
5. tramitar entre unidades;
6. receber processo;
7. concluir e reabrir;
8. atribuir usuário;
9. controlar prazo;
10. anotar, marcar, acompanhar e sinalizar;
11. apensar, anexar ou relacionar processos conforme a semântica oficial;
12. arquivar, desarquivar e submeter à gestão documental;
13. conceder acesso externo;
14. consultar histórico completo.

### 6.3 Atividades e tarefas

`atividade` não é apenas um histórico genérico. Ela representa o estado operacional do processo nas unidades e se relaciona com `tarefa` e atributos de andamento.

Crie um catálogo explícito:

```dart
final class SeiTaskDefinition {
  const SeiTaskDefinition({
    required this.id,
    required this.code,
    required this.opensActivity,
    required this.closesActivity,
    required this.requiredAttributes,
  });
}
```

Para cada tarefa oficial, documente:

- pré-condições;
- recursos SIP exigidos;
- tabelas afetadas;
- atividade aberta ou concluída;
- atributos gerados;
- mensagem exibida;
- efeito na árvore e no controle de processos;
- auditoria;
- integração externa disparada.

### 6.4 Organização, usuários e SIP

O SEI depende do SIP para:

- órgãos;
- unidades;
- hierarquias;
- usuários;
- perfis;
- recursos;
- permissões;
- menus.

A implementação deve possuir um adaptador SIP, não uma tabela própria simplificada.

```dart
abstract interface class SipAuthorizationGateway {
  Future<SeiUserContext> loadContext({
    required String login,
    required int unitId,
  });

  Future<bool> hasResource(
    SeiUserContext context,
    String resourceCode,
  );
}
```

Requisitos:

- respeitar múltiplas unidades por usuário;
- permitir mudança de unidade ativa;
- combinar perfis como o SIP oficial;
- manter nomes e códigos de recursos;
- invalidar cache quando permissões mudarem;
- registrar a unidade e o usuário usados em cada ação;
- reproduzir recursos `pen_*` criados pelo módulo.

A disponibilidade do dump SIP não conclui esta parte: ainda são obrigatórios o
adaptador, o login, a sessão, a unidade ativa, a autorização por recurso e os
testes diferenciais contra o SIP oficial.

---

## 7. Base de Referência do Poder Executivo

A Base de Referência deve ser tratada como um produto funcional, não apenas como um conjunto de inserts.

### 7.1 NUP e fórmula de protocolo

Criar um `NumeroProtocoloService` parametrizado pelos valores oficiais do SEI.

Ele deve reproduzir:

- código do órgão;
- código da unidade ou faixa compartilhada;
- sequencial anual;
- quantidade de dígitos;
- ano;
- máscara;
- dígito verificador;
- pesquisa com e sem formatação;
- protocolo invertido para pesquisas específicas;
- reinício anual;
- bloqueio concorrente da numeração.

Não implemente o algoritmo apenas a partir da aparência do número. Extraia a fórmula da instalação oficial e valide milhares de vetores.

### 7.2 Catálogo de processos

Os 318 tipos de processo precisam manter:

- IDs;
- nomes;
- descrições;
- situação;
- acesso sugerido;
- hipótese legal sugerida;
- assunto arquivístico relacionado;
- regras para usuário externo e ouvidoria;
- plano de trabalho, quando aplicável;
- agrupamento semântico por prefixos e macrotemas.

### 7.3 Tipos de documentos

Os 254 tipos de documento precisam manter:

- aplicabilidade interna/externa;
- numeração;
- modelo;
- formulário;
- grupo documental;
- conjunto de estilos;
- necessidade de interessado/destinatário;
- possibilidade de publicação;
- assinatura e restrições;
- uso por usuário externo;
- espécie documental usada pelo PEN.

### 7.4 Assuntos e gestão arquivística

A classificação arquivística deve preservar:

- hierarquia;
- códigos;
- descritores;
- prazos de guarda;
- destinação;
- observações;
- vínculos com tipos de processo;
- regras de avaliação e eliminação.

Não permita que a UI altere automaticamente classificações predefinidas sem autorização específica.

### 7.5 Hipóteses legais e acesso

As 23 hipóteses legais da base devem ser representadas como dados versionados. Cada operação precisa distinguir:

- público;
- restrito;
- sigiloso, quando previsto e permitido;
- nível local, global e original;
- hipótese legal;
- grau de sigilo;
- acesso de usuário interno;
- acesso externo;
- acesso entre unidades;
- comportamento no envio PEN.

### 7.6 Prioridades

Os seis tipos de prioridade devem manter descrição e situação, além das regras de concessão por usuário e processo.

### 7.7 Perfil de colaborador

O perfil de colaborador sem assinatura, descrito na documentação fornecida, deve ser validado contra o SIP da versão-alvo. Sua diferença em relação ao perfil básico deve ser protegida por teste de regressão, especialmente após atualização do SEI.

### 7.8 Modelos e estilos ricos

A Base de Referência utiliza modelos e estilos hierárquicos para numeração automática de itens, parágrafos, alíneas e incisos. A compatibilidade exige reproduzir:

- `conjunto_estilos`;
- `conjunto_estilos_item`;
- `estilo`;
- associação dos estilos às seções do modelo;
- contadores CSS;
- resets entre níveis;
- indentação;
- transformação de estilo em linhas existentes;
- impressão e PDF.

---

## 8. Documentos e editor em Dart

Esta é uma das partes mais complexas do projeto.

### 8.1 Modelo de dados

Tabelas principais:

- `documento`;
- `documento_conteudo`;
- `secao_documento`;
- `versao_secao_documento`;
- `secao_modelo`;
- `modelo`;
- `estilo`;
- `conjunto_estilos`;
- `rel_secao_modelo_estilo`;
- `rel_secao_mod_cj_estilos_item`;
- `assinatura`.

O documento não deve ser reduzido a um único HTML. O editor precisa entender seções com papéis diferentes:

- cabeçalho;
- título;
- corpo;
- anexos textuais;
- assinatura;
- rodapé;
- seção dinâmica;
- seção somente leitura;
- seção editável;
- seção gerada por variável.

### 8.2 Estratégia de editor puro em Dart

Para a primeira versão compatível:

1. usar `contenteditable` e APIs DOM diretamente pelo Dart web;
2. criar uma camada de comandos Dart, sem depender de bibliotecas JavaScript;
3. manter um modelo estruturado de blocos e marcas;
4. importar e exportar o HTML compatível com o SEI;
5. preservar estilos e atributos reconhecidos;
6. sanitizar somente com uma política conhecida e testada;
7. gerar uma representação canônica para comparação.

Uma arquitetura possível:

```text
DOM do navegador
   <-> Adaptador Dart DOM
   <-> Modelo estruturado do documento
   <-> Comandos e histórico
   <-> Serializador HTML SEI
   <-> Secoes e versões no banco
```

### 8.3 Comandos mínimos

- inserir e remover texto;
- negrito, itálico, sublinhado e tachado;
- alinhamento;
- listas;
- estilos hierárquicos da Base de Referência;
- tabelas;
- imagens permitidas;
- links;
- citações;
- caracteres especiais;
- colagem do Word;
- limpar formatação;
- desfazer/refazer;
- localizar/substituir;
- campos dinâmicos;
- quebra de página visual;
- controle de seções somente leitura;
- comparação de versões;
- clonagem de documento.

### 8.4 Clonagem e minutas

A clonagem precisa copiar apenas as seções que o SEI oficial copia. Seções dinâmicas devem ser regeneradas no documento de destino. O teste deve comparar:

- quantidade de seções;
- conteúdo inicial;
- estilos permitidos;
- versão inicial;
- título e numeração;
- anexos textuais;
- partes não clonadas;
- vínculo com modelo e série.

### 8.5 Versionamento

Cada salvamento relevante deve reproduzir a lógica de `versao_secao_documento`:

- autor;
- unidade;
- data;
- conteúdo;
- origem da versão;
- versão ativa;
- comparação;
- bloqueio após assinatura, quando aplicável.

### 8.6 HTML e segurança

O editor é uma superfície de XSS. A política deve:

- bloquear scripts e handlers `on*`;
- bloquear URLs perigosas;
- permitir apenas tags, estilos e atributos aprovados;
- preservar o HTML legado necessário;
- limpar conteúdo colado;
- impedir CSS que escape da área do documento;
- manter teste com corpus malicioso;
- diferenciar conteúdo histórico, que precisa ser exibido com isolamento, de conteúdo novo.

### 8.7 Geração de PDF

Defina dois níveis:

1. equivalência visual e semântica;
2. equivalência byte a byte, somente onde alguma integração realmente exigir.

A geração deve respeitar:

- tamanho da página;
- margens;
- fontes autorizadas;
- cabeçalho e rodapé;
- numeração;
- assinatura e tarjas;
- imagens;
- tabelas;
- links;
- documentos extensos;
- consolidação de processo.

Use um corpus de documentos reais anonimizados, incluindo documentos de centenas de páginas.

---

## 9. Repositório de arquivos

A tabela `anexo` armazena metadados; os bytes ficam no repositório configurado pelo SEI. Sem esse repositório não existe compatibilidade completa.

### 9.1 Interface

```dart
abstract interface class SeiFileRepository {
  Future<StoredFile> putAtomic({
    required Stream<List<int>> bytes,
    required FileMetadata metadata,
  });

  Future<Stream<List<int>>> open(int attachmentId);

  Future<void> verify(int attachmentId);

  Future<void> deleteAccordingToPolicy(int attachmentId);
}
```

### 9.2 Requisitos

- reproduzir a regra de caminho do SEI;
- preservar nome, tamanho e hash;
- escrita temporária seguida de rename atômico;
- evitar arquivo parcial;
- streaming com backpressure;
- suporte a `Range` para PDFs e vídeos;
- validação de MIME pelo conteúdo;
- antivírus;
- limites por extensão e contexto;
- quarentena;
- backup consistente com o banco;
- verificador periódico de arquivos ausentes e órfãos;
- retenção e eliminação auditável;
- imutabilidade após assinatura ou envio externo, conforme a regra.

### 9.3 Hashes

Não suponha o algoritmo apenas pelo tamanho da coluna. Extraia o comportamento do SEI oficial. No PEN, respeite o campo de algoritmo de hash e compare o conteúdo recebido antes de gravar o recibo de conclusão.

---

## 10. Assinaturas

### 10.1 Casos de assinatura

Mapear separadamente:

- assinatura eletrônica por autenticação interna;
- assinatura com certificado;
- autenticação de documento externo;
- múltiplos assinantes;
- bloco de assinatura;
- assinatura por unidade/cargo/função;
- cancelamento permitido;
- assinatura de documento publicado;
- assinatura de documento enviado ao PEN;
- validação histórica de certificado.

### 10.2 Persistência

Preservar os campos de `assinatura`, incluindo:

- usuário;
- unidade;
- atividade;
- cargo/função;
- modo de autenticação;
- data;
- representação PKCS#7/P7S quando existente;
- serial do certificado;
- tarja;
- vínculo com protocolo/documento.

### 10.3 Serviço de assinatura

```dart
abstract interface class DocumentSignatureService {
  Future<SignatureResult> sign(SignatureRequest request);
  Future<SignatureValidation> validate(int signatureId);
  Future<void> renderSignatureMark(int documentId);
}
```

O conteúdo exato assinado deve ser determinado por teste. Qualquer diferença de espaço, encoding ou normalização pode invalidar a assinatura.

---

## 11. Pesquisa e índices

A presença de tabelas como `protocolo_idx`, `publicacao_idx` e `base_conhecimento_idx` não é suficiente para concluir como toda a pesquisa funciona. Obtenha a configuração do indexador da instalação oficial.

A implementação deve suportar:

- indexação assíncrona;
- reindexação total e incremental;
- pesquisa por número formatado e normalizado;
- pesquisa reversa, quando usada;
- descrição;
- interessado;
- assunto;
- unidade;
- usuário;
- conteúdo de documento, conforme permissão;
- controle de acesso aplicado antes da exibição;
- remoção do índice quando documento/processo é eliminado;
- sincronização entre banco e índice.

O índice nunca pode vazar conteúdo restrito devido a uma consulta sem filtro de autorização.

---

## 12. Auditoria e observabilidade

### 12.1 Auditorias compatíveis

Mapear:

- `infra_auditoria`;
- `auditoria_protocolo`;
- `infra_log`;
- `infra_erro_php`, substituído por erro Dart equivalente sem alterar o contrato externo;
- atividades geradas pelas ações;
- IP, usuário, unidade, recurso e operação;
- formato de payload serializado.

A auditoria funcional do SEI deve ser preservada. A telemetria moderna deve ficar separada, por exemplo em OpenTelemetry, Loki ou outro backend.

### 12.2 Proteção de dados

Os dumps operacionais fornecidos contêm dados sensíveis. Para desenvolvimento:

- criar cópia anonimizada;
- substituir nomes, documentos, emails, endereços e IPs;
- manter cardinalidade e formatos;
- não levar dumps reais para notebooks, CI público ou máquinas pessoais;
- armazenar segredos fora do Git;
- registrar acesso aos ambientes de compatibilidade.

---

## 13. Serviços legados e compatibilidade HTTP

O banco possui `servico` e `operacao_servico`. Faça inventário de todas as integrações cadastradas e do código oficial que as implementa.

Criar uma fachada que preserve, quando necessário:

- WSDL e SOAP;
- nomes de operações;
- parâmetros;
- encoding;
- formatos de erro;
- autenticação por sistema/serviço/unidade;
- IDs retornados;
- consultas de procedimento e inclusão de documento;
- rotas e parâmetros `acao=...` usados por links legados;
- callbacks de módulos.

A API moderna pode coexistir, mas não deve substituir a fachada antes de migrar todos os consumidores.

---

## 14. Portabilidade do mod-sei-pen para Dart

### 14.1 Baseline

Use como baseline inicial o mod-sei-pen 4.0.3, compatível com SEI 5.0.0 a 5.0.4 e com endpoints REST v4. Fixe o commit/release utilizado e não siga automaticamente a branch principal.

### 14.2 Esquema próprio do módulo

A documentação atual do repositório lista 42 tabelas `md_pen_*`. Elas devem ser reproduzidas com tipos, chaves, índices e relacionamentos específicos de cada dialeto.

Grupos principais:

- processos eletrônicos e protocolos;
- trâmites;
- componentes digitais;
- recibos;
- pendências e processamentos;
- unidades e órgãos externos;
- mapeamentos de tipo de processo, espécie e hipótese legal;
- blocos e lotes;
- sequências de emulação.

### 14.3 Inventário das 42 tabelas

```text
md_pen_bloco
md_pen_bloco_protocolo
md_pen_componente_digital
md_pen_envio_comp_digitais
md_pen_especie_documental
md_pen_expedir_lote
md_pen_hipotese_legal
md_pen_map_tipo_processo
md_pen_orgao_externo
md_pen_parametro
md_pen_procedimento_andamento
md_pen_processo_eletronico
md_pen_protocolo
md_pen_recibo_tramite
md_pen_recibo_tramite_enviado
md_pen_recibo_tramite_hash
md_pen_recibo_tramite_recebido
md_pen_rel_doc_map_enviado
md_pen_rel_doc_map_recebido
md_pen_rel_expedir_lote
md_pen_rel_hipotese_legal
md_pen_rel_processo_apensado
md_pen_rel_tarefa_operacao
md_pen_rel_tipo_doc_map_rec
md_pen_seq_bloco
md_pen_seq_bloco_protocolo
md_pen_seq_envio_comp_digitais
md_pen_seq_expedir_lote
md_pen_seq_hipotese_legal
md_pen_seq_map_tp_procedimento
md_pen_seq_orgao_externo
md_pen_seq_procedimento_andam
md_pen_seq_recibo_tramite_hash
md_pen_seq_rel_doc_map_enviado
md_pen_seq_rel_doc_map_recebid
md_pen_seq_rel_hipotese_legal
md_pen_seq_tramite_pendente
md_pen_tramite
md_pen_tramite_pendente
md_pen_tramite_processado
md_pen_tramite_recibo_envio
md_pen_unidade
```

### 14.4 Portar por capacidades, não arquivo a arquivo

Divida o módulo em capacidades:

1. configuração e diagnóstico;
2. certificado cliente e comunicação segura;
3. catálogo de repositórios e estruturas;
4. mapeamento de unidades;
5. mapeamento de tipos de processo;
6. mapeamento de espécies documentais;
7. mapeamento de hipóteses legais;
8. validação de processo para expedição;
9. composição dos componentes digitais;
10. envio de metadados;
11. envio de componentes;
12. recebimento;
13. recibos de entrega e conclusão;
14. recusa;
15. acompanhamento;
16. lotes e blocos;
17. reprocessamento;
18. monitoramento de pendências;
19. agendamentos;
20. permissões e telas administrativas.

### 14.5 Máquina de estados

Não invente os estados a partir dos nomes das tabelas. Extraia todos os códigos e transições do código do módulo e da API.

```dart
final class PenTransition {
  const PenTransition({
    required this.from,
    required this.event,
    required this.to,
    required this.sideEffects,
  });
}
```

Cada transição deve indicar:

- evento recebido;
- estado anterior;
- estado seguinte;
- tabela atualizada;
- recibo gerado;
- atividade SEI criada;
- mensagem ao usuário;
- possibilidade de retry;
- idempotency key;
- compensação.

### 14.6 Fluxo detalhado de envio

Fluxo recomendado para implementação e teste:

1. usuário solicita expedição;
2. validar recurso SIP `pen_*`;
3. validar unidade ativa;
4. validar destino e restrições;
5. validar especificação do processo;
6. validar pelo menos um interessado;
7. validar que existe documento interno assinado ou documento externo;
8. impedir envio com documento interno pendente de assinatura;
9. validar nível de acesso e hipótese legal;
10. mapear tipo de processo;
11. mapear espécies documentais;
12. selecionar processos apensados/anexados permitidos;
13. congelar um snapshot lógico do processo;
14. ordenar documentos;
15. decompor cada documento em componentes digitais;
16. calcular tamanho, MIME e hash;
17. registrar `md_pen_processo_eletronico` e `md_pen_tramite`;
18. registrar componentes em `md_pen_componente_digital`;
19. enviar metadados ao Tramita;
20. obter ticket para componentes, quando aplicável;
21. transmitir arquivos por streaming;
22. confirmar hash e tamanho;
23. receber recibo de entrega;
24. receber recibo de conclusão;
25. persistir recibos e hashes;
26. criar andamento no processo;
27. liberar ou concluir a atividade conforme a regra;
28. permitir consulta e reprocessamento seguro.

Todo o fluxo deve ser idempotente. Repetir uma chamada após timeout não pode criar um segundo trâmite.

### 14.7 Fluxo detalhado de recebimento

1. worker consulta pendências ou recebe evento;
2. adquire lock lógico do trâmite;
3. verifica se já foi processado;
4. baixa metadados;
5. valida número de registro e origem;
6. identifica órgão e unidade de destino;
7. aplica mapeamento de tipo de processo;
8. aplica mapeamento de espécie documental;
9. aplica hipótese legal;
10. verifica participantes e interessados;
11. cria ou localiza o processo eletrônico local;
12. baixa cada componente por streaming;
13. valida tamanho, MIME e hash;
14. grava arquivo temporário;
15. cria `protocolo`, `procedimento`, `documento`, `anexo` e relações em transação;
16. move arquivos para o repositório final;
17. registra tabelas `md_pen_*`;
18. cria atividade e andamento;
19. gera recibo de entrega/conclusão;
20. envia recibo;
21. marca o trâmite como processado;
22. libera lock;
23. publica métricas e auditoria.

### 14.8 Recusa

A recusa deve possuir fluxo próprio:

- motivo obrigatório e validado;
- autorização;
- idempotência;
- persistência local;
- comunicação ao remetente;
- atualização do estado;
- atividade/auditoria;
- proteção contra recusa após conclusão.

A homologação oficial exige teste de recusa com status correspondente.

### 14.9 Envio parcial

Depois do primeiro envio, versões atuais da API podem enviar apenas novos documentos/componentes. O sistema deve manter uma identidade imutável para cada documento e componente já enviado e detectar:

- novo documento;
- nova versão permitida;
- componente já transmitido;
- documento cancelado;
- processo apensado novo;
- diferença de hash;
- ordem documental.

### 14.10 Workers

Substitua cron, Supervisor ou Gearman por workers Dart, mas preserve a semântica.

```text
sei_worker
  - poll de pendências
  - recebimento
  - envio de componentes
  - consulta de recibos
  - reprocessamento
  - reconciliação
  - atualização de catálogos
  - verificação de arquivos
```

Requisitos:

- execução a cada minuto ou conexão persistente, conforme configuração;
- lease/lock com vencimento;
- heartbeat;
- retry exponencial com jitter;
- limite de tentativas;
- fila de falhas para intervenção;
- correlação por NRE, número de registro, trâmite e processo local;
- shutdown gracioso;
- nenhuma tarefa perdida após reinício.

### 14.11 Certificado e mTLS

Criar um componente isolado para:

- carregar certificado e chave;
- validar senha e cadeia;
- montar contexto TLS cliente;
- controlar vencimento;
- recarregar sem indisponibilidade longa;
- impedir log de chave ou senha;
- testar conexão de homologação;
- identificar o comitê vinculado ao certificado;
- assinar e validar recibos conforme o protocolo.

### 14.12 Diagnóstico equivalente

Criar um comando Dart equivalente ao verificador oficial:

```bash
dart run sei_admin_cli pen doctor
```

Ele deve verificar:

- versão suportada do SEI;
- hash do manifesto de esquema;
- presença e versão das tabelas `md_pen_*`;
- recursos SIP `pen_*`;
- configuração obrigatória;
- certificado;
- relógio;
- conectividade;
- acesso ao comitê;
- unidade de recebimento;
- worker;
- repositório de arquivos;
- mapeamentos pendentes;
- trâmites presos.

---

## 15. Estratégia de portabilidade do módulo oficial

### 15.1 Ambiente oráculo

Mantenha uma instalação oficial isolada com:

- SEI 5.0.0;
- SIP correspondente;
- mod-sei-pen 4.0.3;
- banco restaurável;
- repositório de arquivos de teste;
- acesso à homologação;
- tráfego e logs controlados.

### 15.2 Teste diferencial

Para cada cenário:

1. restaurar snapshot inicial A e B;
2. executar ação no SEI oficial em A;
3. executar ação equivalente no sistema Dart em B;
4. exportar diff lógico do banco;
5. comparar arquivos;
6. comparar chamadas HTTP;
7. comparar recibos e estados;
8. classificar divergências;
9. aprovar somente divergências intencionais e documentadas.

### 15.3 Captura de chamadas

Em homologação, use proxy de teste autorizado para registrar:

- método;
- path;
- headers não secretos;
- estrutura do payload;
- status;
- tempos;
- correlação;
- sequência de chamadas.

Segredos, certificados e dados pessoais devem ser mascarados.

### 15.4 Estratégia híbrida temporária

Durante o desenvolvimento, há uma alternativa de menor risco:

- sistema Dart controla o núcleo e a UI;
- um sidecar com SEI/mod-sei-pen oficial executa somente a integração PEN;
- ambos compartilham um contrato de comandos e resultados;
- depois, o sidecar é substituído pelo cliente Dart.

Isso reduz o risco de bloquear o projeto inteiro enquanto a portabilidade do PEN ainda não foi homologada.

---

## 16. Suíte de testes

### 16.1 Testes de esquema

- diff de todas as 194 tabelas;
- diff das 122 sequências;
- diff das 42 tabelas PEN;
- tipos, defaults, nulabilidade e índices;
- geração PostgreSQL e MySQL;
- atualização entre versões;
- nenhuma alteração não autorizada.

### 16.2 Testes de round-trip

Para cada tabela relevante:

1. ler registro oficial;
2. serializar para o modelo Dart;
3. escrever em banco limpo;
4. comparar valores;
5. reabrir no SEI oficial.

### 16.3 Testes de regras de negócio

Cobrir no mínimo:

- autuação;
- NUP;
- documento interno;
- documento externo;
- edição e versões;
- assinatura;
- bloco de assinatura;
- tramitação;
- recebimento;
- conclusão;
- reabertura;
- prazo;
- acompanhamento;
- acesso externo;
- restrição;
- publicação;
- arquivamento;
- avaliação;
- eliminação;
- pesquisa;
- apensação/anexação/relacionamento;
- serviços externos;
- PEN.

### 16.4 Testes de concorrência

Executar dezenas ou centenas de operações simultâneas em casos críticos, verificando:

- IDs únicos;
- NUP único;
- ausência de deadlock não tratado;
- retry seguro;
- nenhuma atividade duplicada;
- nenhuma assinatura perdida;
- nenhum envio PEN duplicado.

### 16.5 Testes de compatibilidade do editor

- corpus de HTML oficial;
- abrir e salvar sem mudança;
- colagem do Word;
- estilos multinível;
- tabelas complexas;
- imagens;
- caracteres LATIN1;
- documentos grandes;
- clonagem;
- assinatura;
- PDF;
- proteção contra XSS.

### 16.6 Testes PEN

- envio simples;
- envio com vários documentos;
- componentes múltiplos;
- envio parcial;
- processo apensado;
- acesso restrito;
- hash divergente;
- timeout após envio;
- retry;
- recebimento;
- recusa;
- recibo de entrega;
- recibo de conclusão;
- worker reiniciado no meio;
- certificado vencido ou inválido;
- destino não mapeado;
- documento sem assinatura;
- ausência de interessado;
- ausência de especificação.

### 16.7 Testes de desempenho

Use o SEI oficial como baseline. Meça:

- controle de processos por unidade;
- abertura de processo com milhares de eventos;
- pesquisa;
- carregamento da árvore;
- visualização de PDF;
- inclusão de arquivo grande;
- consolidação;
- envio PEN;
- recebimento PEN;
- jobs por minuto;
- consumo de memória.

A meta inicial deve ser “não pior que o baseline” para as operações críticas, seguida de otimização.

### 16.8 Testes de segurança

- autorização por recurso e unidade;
- IDOR;
- XSS no editor;
- SQL injection;
- upload malicioso;
- path traversal;
- SSRF em URLs externas;
- CSRF;
- sessão e cookies;
- força bruta;
- vazamento em logs;
- assinatura adulterada;
- replay de chamadas PEN;
- certificados;
- acesso ao índice de pesquisa;
- auditoria inviolável.

---

## 17. Roadmap por fases

As durações abaixo são estimativas de engenharia, não promessa de calendário. Várias frentes podem ocorrer em paralelo.

### Fase 0 — Governança e congelamento do baseline

**Duração indicativa:** 2 a 4 semanas.

Entregas:

- decisão formal sobre SEI 5.0.0 como primeiro alvo;
- release/commit fixo do mod-sei-pen;
- hashes dos dumps e pacotes;
- política de acesso aos dados;
- ambiente oficial de referência;
- definição jurídica de uso do código e dos ativos;
- matriz do que significa compatibilidade;
- registro de riscos;
- plano de rollback.

Critério de saída:

- qualquer desenvolvedor consegue reproduzir o laboratório sem depender de conhecimento oral.

### Fase 1 — Laboratório e ferramentas de compatibilidade

**Duração indicativa:** 4 a 6 semanas.

Entregas:

- restauração automatizada PostgreSQL e MySQL;
- carga do SEI/SIP oficial;
- repositório de arquivos de teste;
- extrator de esquema;
- comparador de banco;
- snapshots determinísticos;
- anonimização do corpus;
- captura de ações e efeitos;
- inventário de tabelas, tarefas e recursos.

Critério de saída:

- uma ação simples no SEI oficial gera um relatório completo de diferenças.

### Fase 2 — Contrato de persistência Dart

**Duração indicativa:** 6 a 10 semanas.

Entregas:

- `SeiDbSession`;
- adaptador PostgreSQL;
- adaptador MySQL;
- alocador de IDs;
- encoding LATIN1;
- tratamento de datas e decimais;
- modelos gerados das 194 tabelas;
- repositórios críticos escritos à mão;
- testes de transação e concorrência;
- manifesto de esquema.

Critério de saída:

- leitura integral e round-trip sem alteração semântica dos registros de referência.

### Fase 3 — Aplicação somente leitura

**Duração indicativa:** 6 a 8 semanas.

Entregas:

- login e contexto de unidade;
- controle de processos;
- visualização da árvore;
- metadados;
- histórico;
- documentos e anexos;
- pesquisa básica;
- autorização em leitura;
- auditoria de acesso.

Critério de saída:

- usuários de teste conseguem consultar o mesmo acervo e obter os mesmos resultados do SEI oficial.

### Fase 4 — Escrita do núcleo processual

**Duração indicativa:** 10 a 14 semanas.

Entregas:

- autuação;
- NUP;
- participantes e assuntos;
- tramitação entre unidades;
- recebimento;
- atribuição;
- conclusão e reabertura;
- prazos;
- anotações e marcadores;
- blocos básicos;
- atividades e auditorias.

Critério de saída:

- processos criados e tramitados em Dart continuam operáveis no SEI oficial.

### Fase 5 — Documentos, editor, arquivos e assinaturas

**Duração indicativa:** 14 a 20 semanas.

Entregas:

- tipos e modelos;
- seções;
- editor;
- estilos multinível;
- versionamento;
- clonagem;
- documentos externos;
- repositório de arquivos;
- assinatura eletrônica;
- certificado, se incluído no escopo desta fase;
- PDF e visualização.

Critério de saída:

- corpus completo de documentos passa nos testes diferenciais e de segurança.

### Fase 6 — SIP, acesso e serviços

**Duração indicativa:** 8 a 12 semanas, em paralelo com fases 4 e 5.

Entregas:

- recursos e perfis;
- hierarquias;
- usuários multiunidade;
- nível de acesso;
- hipótese legal;
- acesso externo;
- serviços legados;
- menus administrativos.

Critério de saída:

- matriz de autorização equivalente ao SIP oficial.

### Fase 7 — Funcionalidades amplas do SEI

**Duração indicativa:** 12 a 18 semanas.

Entregas:

- publicação;
- base de conhecimento;
- pesquisa avançada;
- gestão documental;
- avaliação e eliminação;
- planos de trabalho;
- federação, se utilizada;
- ouvidoria, se utilizada;
- integrações específicas da instalação.

Critério de saída:

- backlog funcional da instalação-alvo integralmente coberto.

### Fase 8 — Portabilidade do PEN

**Duração indicativa:** 12 a 20 semanas.

Entregas:

- migradores `md_pen_*`;
- recursos SIP `pen_*`;
- configurações;
- mapeamentos;
- envio;
- recebimento;
- recibos;
- recusa;
- envio parcial;
- blocos/lotes;
- workers;
- diagnóstico;
- homologação.

Critério de saída:

- envio, recebimento e recusa aprovados no ambiente oficial de homologação e equivalentes ao módulo oficial.

### Fase 9 — Operação sombra e corte

**Duração indicativa:** 10 a 16 semanas.

Entregas:

- leitura sombra em produção;
- comparação de consultas;
- simulação de escrita;
- piloto por unidades;
- monitoramento;
- backup final;
- janela de corte;
- rollback testado;
- documentação e treinamento;
- observação pós-corte.

Critério de saída:

- ausência de divergências críticas durante o período acordado e retorno ao SEI oficial comprovadamente possível.

---

## 18. Primeiros 90 dias

### Semanas 1 e 2

- congelar versões;
- calcular hashes;
- catalogar arquivos;
- obter SIP;
- criar banco limpo PostgreSQL e MySQL;
- documentar RepositorioArquivos;
- configurar SEI oficial em laboratório;
- criar corpus anonimizado inicial.

### Semanas 3 e 4

- gerar manifesto das 194 tabelas e 122 sequências;
- gerar manifesto das tabelas PEN;
- criar comparador de esquema;
- mapear `protocolo`, `procedimento`, `documento`, `atividade`, `usuario` e `unidade`;
- registrar os primeiros fluxos oficiais.

### Semanas 5 e 6

- implementar sessão e transação PostgreSQL;
- implementar alocação de IDs;
- implementar encoding;
- criar modelos de leitura;
- construir API de consulta de processos;
- validar IDs como string no frontend.

### Semanas 7 e 8

- implementar adaptador MySQL;
- executar round-trip;
- implementar controle de processos somente leitura;
- abrir árvore, metadados, atividades e documentos;
- comparar consultas com o SEI oficial.

### Semanas 9 e 10

- implementar autuação em ambiente descartável;
- gerar NUP;
- criar protocolo/procedimento;
- incluir participantes e assuntos;
- comparar todas as linhas alteradas.

### Semanas 11 e 12

- implementar primeira tramitação entre unidades;
- criar e concluir atividades;
- validar concorrência;
- iniciar adaptador SIP;
- publicar relatório de compatibilidade do trimestre;
- decidir se o próximo trimestre prioriza editor ou autorização.

Resultado esperado dos 90 dias:

- laboratório reproduzível;
- inventário completo do esquema;
- leitura funcional;
- primeira escrita compatível de processo;
- riscos desconhecidos reduzidos;
- nenhuma tentativa prematura de substituir produção.

---

## 19. Backlog de épicos

| Épico | Escopo | Dependências | Definição de concluído |
|---|---|---|---|
| E00 Baseline | versões, hashes, ambiente e corpus | nenhuma | laboratório reproduzível |
| E01 Manifesto de esquema | 194 tabelas, sequências e PEN | E00 | diff automático no CI |
| E02 Sessão DB | transação, prepared statements e erros | E01 | testes PG/MySQL |
| E03 IDs | sequências e `seq_*` | E02 | concorrência equivalente |
| E04 Encoding | LATIN1 e Unicode | E02 | corpus byte-safe |
| E05 SIP | usuários, unidades, recursos e perfis | E00 | matriz de permissão aprovada |
| E06 Autenticação | sessão, unidade ativa e auditoria | E05 | login equivalente |
| E07 Protocolo | supertipo e número | E02-E04 | registros reabertos no SEI |
| E08 Processo | autuação e metadados | E07 | golden master aprovado |
| E09 Atividades | tramitação e tarefas | E08 | histórico equivalente |
| E10 Contatos | interessados e participantes | E08 | validações e pesquisa |
| E11 Acesso | níveis, hipóteses e acesso externo | E05-E08 | nenhum vazamento |
| E12 Arquivos | repositório e streaming | E02 | verificador sem órfãos |
| E13 Editor | DOM, comandos e HTML | E04 | corpus compatível |
| E14 Modelos | seções, variáveis e estilos | E13 | modelos da base renderizam |
| E15 Versões | histórico e comparação | E13-E14 | round-trip de versões |
| E16 Assinaturas | assinatura e tarjas | E12-E15 | validação equivalente |
| E17 Blocos | assinatura, interno e reunião | E09-E16 | fluxos oficiais cobertos |
| E18 Pesquisa | índice e autorização | E08-E16 | resultados equivalentes |
| E19 Publicação | boletim e veículos | E16-E18 | publicação externa válida |
| E20 Gestão documental | arquivo, avaliação e eliminação | E08-E19 | trilha auditável completa |
| E21 Auditoria | infra e protocolo | todos | diff de auditoria aprovado |
| E22 Serviços legados | SOAP/rotas/integrações | E05-E16 | consumidores migrados ou compatíveis |
| E23 Schema PEN | 42 tabelas e migradores | E01-E03 | verificador aprovado |
| E24 Mapeamentos PEN | unidades, espécies e hipóteses | E05-E23 | catálogo sem pendência |
| E25 Envio PEN | snapshot e transmissão | E12-E16-E24 | status de sucesso em homologação |
| E26 Recebimento PEN | importação idempotente | E25 | processo recebido íntegro |
| E27 Recibos/recusa | recibos, hashes e recusa | E25-E26 | cenários oficiais aprovados |
| E28 Workers PEN | agendamento, retries e reconciliação | E25-E27 | reinício sem perda |
| E29 Administração PEN | telas e diagnóstico | E23-E28 | operação autônoma |
| E30 Teste diferencial | banco, arquivo, HTTP e UI | todos | zero divergência crítica |
| E31 Corte | sombra, piloto e rollback | E30 | produção reversível |

---

## 20. Equipe recomendada

Para buscar paridade ampla em prazo razoável:

- 1 arquiteto técnico com domínio de Dart e bancos;
- 1 especialista funcional em SEI/SIP;
- 1 arquivista ou especialista em gestão documental;
- 1 DBA;
- 4 a 6 desenvolvedores backend Dart;
- 2 a 3 desenvolvedores frontend/editor;
- 2 engenheiros de testes/automação;
- 1 especialista em segurança, certificados e assinatura;
- 1 profissional DevOps/SRE;
- apoio de gestores de protocolo e usuários-chave.

Uma equipe muito menor pode avançar, mas deverá reduzir o escopo inicial e aceitar um cronograma significativamente maior.

### 20.1 Frentes paralelas

```text
Frente A: contrato de banco e compatibilidade
Frente B: núcleo processual e workflow
Frente C: editor, arquivos, PDF e assinatura
Frente D: SIP, segurança e serviços legados
Frente E: PEN e homologação
Frente F: QA diferencial, performance e operação
```

---

## 21. Migração e corte

### 21.1 Etapas

1. inventário de integrações;
2. backup completo;
3. restauração validada;
4. modo somente leitura Dart;
5. comparação de consultas;
6. shadow traffic sem efeitos;
7. piloto em base clonada;
8. piloto por unidade em ambiente controlado;
9. congelamento de mudanças de esquema;
10. corte;
11. reconciliação;
12. janela de rollback;
13. encerramento gradual do legado.

### 21.2 Evitar dual-write ingênuo

Gravar simultaneamente por dois sistemas na mesma base é arriscado. Se houver coexistência, defina propriedade por operação ou use uma camada única de comandos.

Alternativas:

- Dart em leitura e SEI oficial em escrita;
- Dart como fachada chamando o SEI oficial para ações ainda não portadas;
- filas de comandos idempotentes;
- CDC apenas para comparação, não como substituto de transação;
- corte por módulo funcional completo.

### 21.3 Rollback

O rollback precisa ser ensaiado e medir:

- tempo de retorno;
- restauração de arquivos;
- restauração do banco;
- trâmites PEN em andamento;
- filas pendentes;
- certificados;
- DNS/proxy;
- sessões;
- reconciliação de operações feitas durante a janela.

---

## 22. Registro de riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| Falta do banco SIP | autorização incompleta | tornar SIP um gate da Fase 0 |
| Regras escondidas no código PHP | dados aparentemente válidos, mas semanticamente errados | golden master e instrumentação do SEI oficial |
| Encoding LATIN1 inconsistente | corrupção de textos e hashes | testes byte a byte e corpus real anonimizado |
| Repositório de arquivos desconhecido | documentos inacessíveis | obter configuração e validar path/hash antes da escrita |
| Editor incompatível | perda de formatação ou assinatura | modelo por seções e corpus diferencial |
| Assinaturas | invalidade jurídica/técnica | especialista PKI e testes com vetores oficiais |
| Atualização do SEI | quebra do contrato | matriz por versão e manifesto bloqueado |
| Mudança da API Tramita | falha de integração | cliente versionado e contrato OpenAPI congelado |
| Retry PEN duplicado | processo/trâmite duplicado | idempotência e reconciliação |
| Pesquisa vaza restritos | incidente grave | autorização aplicada no índice e testes de segurança |
| Dump real em desenvolvimento | incidente de dados pessoais | anonimização e controle de acesso |
| Microserviços prematuros | transações distribuídas frágeis | monólito modular inicialmente |
| ORM alterando semântica | divergências silenciosas | SQL explícito no núcleo |
| Performance da árvore | UX ruim em processos longos | paginação, índices e benchmarks |
| Scripts oficiais alterando tabelas | quebra de coexistência | nunca modificar tabelas oficiais fora de migradores aprovados |

---

## 23. Critérios de aceite para declarar compatibilidade

A versão só pode ser chamada de compatível quando:

1. o comparador de esquema não encontra divergências críticas;
2. todas as 194 tabelas são lidas corretamente;
3. IDs e sequências funcionam em PostgreSQL e MySQL;
4. textos LATIN1 fazem round-trip;
5. processos criados no Dart abrem no SEI oficial;
6. processos criados no SEI oficial abrem no Dart;
7. tramitações geram atividades equivalentes;
8. documentos internos e externos mantêm conteúdo e arquivos;
9. modelos, seções, estilos e versões são preservados;
10. assinaturas continuam verificáveis;
11. permissões SIP são equivalentes;
12. pesquisa não vaza dados restritos;
13. auditorias necessárias são produzidas;
14. serviços legados cobertos continuam operando;
15. backup e restauração foram ensaiados;
16. o módulo PEN envia com sucesso;
17. o módulo PEN recebe com sucesso;
18. a recusa é homologada;
19. recibos, hashes e componentes são íntegros;
20. reprocessamento não duplica trâmites;
21. o sistema suporta reinício de workers;
22. a carga de produção está dentro do baseline;
23. o rollback para o SEI oficial foi demonstrado;
24. todas as divergências conhecidas estão documentadas e aprovadas.

---

## 24. Recomendação final de execução

A implementação deve começar como um **projeto de compatibilidade**, não como um projeto comum de CRUD.

A sequência de maior probabilidade de sucesso é:

1. SEI 5.0.0 como alvo congelado;
2. PostgreSQL como primeiro dialeto;
3. laboratório oficial e teste diferencial;
4. leitura completa;
5. autuação e tramitação básica;
6. documentos e arquivos;
7. SIP e autorização;
8. editor e assinatura;
9. serviços amplos;
10. PEN usando o módulo oficial como oráculo;
11. MySQL consolidado;
12. operação sombra e corte;
13. somente depois adicionar suporte a 5.0.1–5.0.4 ou outra versão.

O maior erro seria tentar desenvolver “todas as telas do SEI” antes de provar que uma única autuação, inclusão de documento, assinatura e tramitação geram exatamente os registros, arquivos e efeitos esperados.

---

## 25. Arquivos complementares gerados nesta análise

- `analise_tecnica_dumps_sei.md`: resumo estrutural sem dados pessoais;
- `inventario_schema_sei_5_0_0.csv`: inventário das 194 tabelas;
- `manifesto_compatibilidade_sei_dart.json`: manifesto legível por máquina com hashes e estatísticas;
- `arquitetura_backend.md`: regra de implementação de `backend/lib/src`;
- `inventario_funcional_sei.md`: inventário funcional do SEI com comportamento,
  vantagem e limitação de cada recurso, provado no corpus local;
- `evidencias_controle_processos.md`: provas da separação entre Recebidos e
  Gerados;
- `evidencias_processo_detalhe.md`: provas dos códigos de domínio de
  `sta_protocolo`, `sta_estado`, `sta_associacao`, `sta_participacao` e do
  catálogo de tarefas, com as lacunas que permanecem;
- `sei-backend-docs-inventario-2026-08-18/`: pacote de inventário funcional
  recebido, com capturas de tela, CSV e JSON estruturados;
- `roteiro_mestre_sei_dart_mod_pen.md`: este documento.

---

## 26. Contrato obrigatório de equivalência da experiência do usuário

O requisito de experiência igual não pode ficar descrito apenas como “tela
parecida”. Ele deve virar um contrato verificável. O produto terá um **modo de
compatibilidade SEI 5**, habilitado por padrão, no qual mudanças de posição,
nome, sequência ou comportamento de um comando são tratadas como quebra de
compatibilidade.

### 26.1 Dimensões de equivalência

Cada tela será comparada em seis dimensões:

| Dimensão | O que deve permanecer equivalente | Como medir |
|---|---|---|
| Funcional | comandos disponíveis, pré-condições, validações e efeitos | cenários diferenciais no SEI oficial e no Dart |
| Informacional | rótulos, ajuda, alertas, ordenação, agrupamentos e estados | contrato da tela e revisão lado a lado |
| Interacional | quantidade e ordem de passos, foco, teclado, seleção e confirmação | automação Puppeteer e roteiro manual |
| Visual | posição relativa, densidade, cores semânticas, ícones e hierarquia | imagens de referência e comparação visual |
| Temporal | carregamento, bloqueio, atualização, retorno e preservação de contexto | marcas de tempo e testes de latência percebida |
| Acessível | nome acessível, ordem de tabulação, contraste, zoom e leitor de tela | axe, inspeção manual e testes de teclado |

“Equivalente” não exige reproduzir defeitos técnicos do PHP, HTML inválido ou
falhas de acessibilidade. Quando uma correção for necessária, ela deve preservar
o modelo mental do usuário e ser registrada como divergência deliberada.

### 26.2 Baselines visuais obrigatórios

Criar baselines para, no mínimo:

- Chrome estável em Windows, resolução 1366 × 768 e escala de 100%;
- Chrome estável em Windows, resolução 1920 × 1080 e escala de 100%;
- viewport de tablet com 1024 × 768;
- viewport móvel definido pelo manual 4.0+, sem esconder operação essencial;
- tema claro padrão;
- zoom de 200% para verificação de acessibilidade;
- usuário comum, administrador, usuário externo e gestor PEN;
- unidade com poucos processos e unidade com milhares de processos;
- processo curto, processo com centenas de documentos e processo restrito.

Os dados variáveis — número do processo, horário, nome do usuário e identificador
de sessão — devem ser fixados por fixture ou mascarados na comparação. Não use
uma tolerância visual alta para esconder desalinhamentos reais.

### 26.3 Estados que toda tela deve documentar

O contrato de uma tela só está completo quando cobre:

1. estado inicial vazio;
2. carregamento;
3. sucesso com um item;
4. sucesso com muitos itens;
5. ausência de permissão;
6. validação de formulário;
7. conflito concorrente;
8. falha temporária de rede;
9. sessão expirada;
10. operação concluída;
11. operação parcialmente concluída, quando o domínio admitir;
12. retorno pelo botão do navegador;
13. atualização da página;
14. abertura direta por URL;
15. uso exclusivo por teclado.

### 26.4 Regra para modernização

Uma melhoria de UX pode ser implementada somente se:

- não substituir o modo compatível;
- estiver atrás de preferência explícita ou feature flag;
- compartilhar os mesmos casos de uso e regras de autorização;
- produzir exatamente os mesmos efeitos de banco, arquivos e auditoria;
- possuir teste próprio e teste de não regressão do modo compatível;
- não alterar URLs públicas, atalhos ou automações legadas sem adaptador.

---

## 27. Corpus público de referência visual e funcional

Foi criado o diretório
`backend/referencias/manuais_sei_publicos`. Ele contém:

- espelho em HTML do Manual do Usuário SEI 4.0+, que também contempla
  evoluções das versões 4.1 e 5.0;
- páginas centrais e coleta incremental do Manual do Administrador;
- imagens PNG e animações GIF usadas pelos manuais;
- compilação PDF completa e atual do portal de manuais do PEN, além de três
  manuais publicados pela Polícia Federal, Fundação Biblioteca Nacional e
  Instituto Nacional de Educação de Surdos;
- manifesto CSV com URL, caminho local, tamanho, data e SHA-256;
- coletor reproduzível e limitado às áreas públicas dos manuais.

Na coleta de 5 de agosto de 2026 foram catalogados **674 artefatos de
referência**: 4 PDFs, 25 páginas HTML e 645 imagens/animações, totalizando cerca
de 104 MiB. O Manual do Usuário e a compilação PDF de todo o portal ficaram
completos. A coleta de imagens individuais da área administrativa pode ser
retomada de forma incremental porque o portal aplica limitação temporária após
muitas requisições; o manifesto sempre representa exatamente os arquivos já
obtidos.

O código do `mod-sei-pen` já fornecido acrescenta 18 imagens próprias do fluxo
PEN em `backend/referencias/mod-sei-pen/docs/imagens`.

### 27.1 Hierarquia de confiança das referências

Use as fontes nesta ordem:

1. instalação autorizada do SEI 5.0.0 usada como oráculo;
2. manual público atual do PEN para funcionalidades 4.0, 4.1 e 5.0;
3. manual e imagens da versão exata do `mod-sei-pen` adotada;
4. PDFs de órgãos públicos;
5. dump da Base de Referência do Poder Executivo;
6. memória operacional de usuários, sempre confirmada no oráculo;
7. inferência técnica, marcada explicitamente como hipótese.

Captura de manual não prova uma regra de banco. Dump não prova a sequência de
cliques. Código do módulo não prova o comportamento de uma instalação com outra
configuração. A rastreabilidade deve sempre distinguir esses tipos de evidência.

### 27.2 Catálogo de capturas

Criar `backend/docs/ux/catalogo_telas_sei_5.csv` com as colunas:

```text
id_tela,versao,perfil,unidade,viewport,estado,acao_origem,
arquivo_referencia,url_manual,fixture,mascaras,observacoes,validado_por,data_validacao
```

Cada captura deve ter um identificador estável, por exemplo:

```text
SEI5-CP-001-controle-processos-padrao-1366x768
SEI5-PR-014-arvore-documento-restrito-selecionado
SEI5-PEN-009-envio-confirmacao-destinatario
```

### 27.3 Restrições de propriedade intelectual e privacidade

- Não colocar processo real, nome, CPF, e-mail, certificado ou documento
  funcional nas fixtures e imagens.
- Usar marcas e logotipos no produto somente quando houver autorização.
- Usar as imagens baixadas como referência e evidência de teste, não como
  substituto da implementação.
- Preservar autoria, URL e hash dos manuais.
- Antes de distribuição comercial ou pública, submeter marcas, ícones, fontes,
  textos extensos e documentação a revisão jurídica.

---

## 28. Arquitetura concreta alinhada ao `new_sali`

A estrutura inicial sugerida na seção 3 é conceitual. A implementação física
adota o bom padrão do `C:\MyDartProjects\new_sali` — fábrica de repositório no
DI do Angel e conexão no escopo da requisição — sem reproduzir seus trechos
legados que criam repositórios diretamente em controllers ou services.

```text
backend/lib/src/
  app/
    sei_app_config.dart
    sei_application.dart          # cria Angel; só chama DI e rotas
  di/
    sei_dependency_injector.dart  # registra singletons e fábricas Angel
  routes/
    sei_routes.dart               # agrega rotas e middlewares globais
  shared/
    middlewares/                  # CORS e conexão por requisição
    models/                       # DTOs exclusivos do backend
    services/                     # infraestrutura compartilhada
    utils/                        # extensões e utilitários genéricos
  modules/
    catalogos/
      controllers/
      repositories/
      routes/catalogos_routes.dart
    contexto/
      controllers/
      repositories/
      routes/contexto_routes.dart
    controle_processos/
      controllers/
      repositories/
      routes/controle_processos_routes.dart
    processos/
      controllers/
      repositories/
      routes/processos_routes.dart
    sip/
      controllers/
      repositories/
      routes/sip_referencia_routes.dart
```

Todo módulo novo segue a mesma topologia: `controllers/`, `repositories/` e
`routes/<modulo>_routes.dart`. A pasta `services/` só é criada quando existir
uma regra de negócio, transação, coordenação entre repositórios, integração
externa ou outro efeito que justifique uma camada própria. Um service que só
delega uma chamada para repository é proibido.

O guia executável da arquitetura está em
[`arquitetura_backend.md`](arquitetura_backend.md).

### 28.1 Responsabilidade das camadas

| Camada | Responsabilidade | Não pode fazer |
|---|---|---|
| Model/DTO | contrato tipado, `fromMap()`, `toMap()`, enums e invariantes locais | abrir conexão ou conhecer HTTP |
| Repository | SQL, filtros, locks, mapeamento de linhas e persistência | decidir fluxo de tela, emitir resposta HTTP ou abrir conexão |
| Service opcional | regra de negócio, transação, coordenação de vários repositories e efeitos externos | conter SQL literal ou existir apenas para delegar uma chamada |
| Controller | transporte HTTP, validação superficial, resolução de dependência da requisição e serialização | construir repository, executar SQL ou duplicar regra de domínio |
| Middleware | preocupação transversal, como CORS, autenticação e ciclo de conexão | conter regra de negócio de módulo |
| Frontend service | cliente HTTP tipado, cache e adaptação do contrato | decidir permissão sem confirmação do backend |
| Componente | estado visual estável e eventos de intenção | executar SQL, regra compartilhada ou parsing complexo |
| Página de rota | ler rota, carregar agregado-base e ligar componentes | concentrar árvore, editor, PDF, PEN e modais em uma classe |

### 28.2 Modelos compartilhados

Todo DTO compartilhado entre backend e frontend deve:

- ficar em `core/lib/src/models`;
- implementar `BaseModel`;
- possuir `fromMap()` e `toMap()` centralizados;
- expor `toInsertMap()` e `toUpdateMap()` pelo contrato base; DTO de leitura
  deve recusar explicitamente escrita sem semântica, e entidade persistível
  deve sobrescrever os mapas removendo a chave primária;
- possuir `==` e `hashCode`; para DTO imutável a comparação é por conteúdo,
  enquanto entidade mutável futura deve sobrescrever por identidade de domínio;
- usar tipos explícitos;
- representar enums persistidos com `value` e `fromValue()`;
- ser exportado em `core/lib/sei_core.dart`;
- evitar `Map<String, dynamic>` fora da borda JSON/SQL;
- permitir mutabilidade quando usado diretamente por binding ou estado de UI.

Modelos de uma única tabela usam somente `tableName` e `fqtn`. Não criar
constantes redundantes como `assuntoTableName`. DTOs de `JOIN` não têm uma
única tabela: usam apenas os `fqtn` qualificados de cada origem, por exemplo
`atividadeFqtn` e `usuarioFqtn`. Factories `nova()`/`vazia()` e `clone()` ou
`copyWith()` são obrigatórias quando uma tela precisa iniciar ou copiar estado
editável; não criar esses contratos artificiais para páginas e projeções de
leitura.

Criar desde o início identificadores semânticos para evitar misturar `id_protocolo`,
`id_procedimento`, `id_documento` e números exibidos. Se wrappers de ID causarem
problema de interoperabilidade com o Eloquent ou NgDart, manter `int` no wire,
mas nunca reutilizar a mesma variável para chaves de entidades diferentes.

### 28.3 Backend: DI nativa do Angel, conexão e rotas

O Angel é o contêiner oficial do backend. Não usar `get_it` para as requisições
HTTP e não encapsular a resolução em callbacks como
`RepositorioInjetado.executar(...)`.

1. `SeiDependencyInjector.configurar()` registra configurações, serviços de
   banco, controladores sem estado e fábricas de repositories no contêiner da
   aplicação.
2. `MiddlewareConexaoBanco` abre uma conexão para a rota SEI ou SIP, registra
   `Connection` no contêiner-filho de `RequestContext` e a libera ao término da
   requisição quando não há pool.
3. A fábrica registrada recebe essa conexão atual, por exemplo
   `CatalogoRepository(container.make<Connection>())`.
4. O controller resolve a dependência tipada com
   `request.make<CatalogoRepository>()` e chama o método de repository.

SEI e SIP usam middlewares de conexão distintos. Isso impede que uma rota SIP
consuma por engano a conexão da Base de Referência SEI. Nenhuma conexão é aberta
em preflight `OPTIONS`: o middleware CORS global responde `204` antes de uma
rota de negócio.

Para conexão sem pool, o middleware registra diretamente
`request.shutdownHooks.add(connection.disconnect)`. O comportamento não é
presumido: `backend/test/middlewares/conexao_banco_middleware_test.dart` envia
uma requisição pelo `TestClient` do Angel e verifica o `disconnect()` após a
resposta, além de confirmar que a conexão de pool não é desconectada pelo fim
da requisição.

`sei_application.dart` não recebe lógica de módulo. Seu único papel é criar o
`Angel`, configurar DI e registrar rotas. `routes/sei_routes.dart` agrega os
arquivos de rota dos módulos; não contém SQL, regra de negócio ou controller
grande.

O CORS fica exclusivamente em `shared/middlewares/cors_middleware.dart`,
registrado uma vez no agregador. É proibido atribuir cabeçalhos CORS em
controller, repository ou service e é proibido recriar
`_aplicarCabecalhosCors(response)`.

### 28.3.1 Regras SOLID e Clean Code obrigatórias

- **Responsabilidade única:** app, DI, rota, middleware, controller,
  repository e service têm as responsabilidades definidas acima.
- **Aberto para extensão:** adicionar módulo exige seu arquivo de rota,
  repository e registro de fábrica; não exige editar um controlador genérico.
- **Inversão de dependência:** controllers dependem de contratos resolvidos no
  contêiner da requisição, não de `Repository(connection)` criado manualmente.
- **Segregação de interfaces:** infraestrutura de conexão expõe somente o
  contrato necessário ao middleware; repository não conhece HTTP.
- **Substituição segura:** uma implementação de serviço de conexão deve manter
  o mesmo ciclo de vida da conexão registrado no `RequestContext`.
- **Services por necessidade:** criar service apenas para regra de negócio,
  transação, múltiplos repositories, auditoria, fila ou integração externa.
  Para leitura simples, usar `controller → repository`.
- **Legibilidade:** não misturar resolução do DI, chamada assíncrona,
  transformação de lista e resposta HTTP em uma expressão densa. Usar variáveis
  locais tipadas quando elas tornam o fluxo mais claro. Listas de `BaseModel`
  usam `RespostaApiHttp.responderLista()` para não repetir callbacks de
  serialização nos controllers.
- **Sem repetição:** a fábrica de cada repository fica apenas no DI e o CORS
  apenas no middleware global. Não repetir cabeçalhos, criação de conexão ou
  `Repository(connection)` nas camadas de negócio.
- **Fronteiras tipadas:** repository retorna model/DTO; controller chama
  `toMap()` apenas ao serializar a resposta. `Map<String, dynamic>` fica na
  borda de SQL, JSON e resposta.

Reaproveitar ainda:

- Angel3 para a API interna autenticada;
- Shelf apenas onde a API pública ou integração isolada justificar;
- `eloquent` como construtor de query, sem permitir que ele defina o contrato;
- Redis para sessão, cache e sinalização, nunca como fonte única de verdade;
- filas persistidas em banco para operações que não podem ser perdidas;
- Prometheus para métricas;
- logs estruturados com identificador de requisição e correlação do trâmite;
- `belatuk_range_header` ou equivalente para streaming de documentos;
- workers com reserva transacional, lease, heartbeat, retry e dead letter.

SQL permanece exclusivamente em repositories. Transações pertencem a services
quando um fluxo realmente coordenar mais de uma operação; em uma consulta
simples, não criar service artificial.

### 28.4 Frontend AngularDart

Adotar NgDart 8 e `limitless_ui`, porém criar uma camada de tema compatível com o
SEI 5. Os componentes de `limitless_ui` devem ser configurados para reproduzir
densidade e comportamento do SEI, sem impor aparência moderna no modo padrão.

**Estrutura de pastas e SCSS: seguir `C:\MyDartProjects\new_sali\frontend`.**
É um padrão sólido, comprovado em produção, e o `sei/frontend` deve replicá-lo
em vez de inventar uma organização própria:

```text
frontend/
  web/
    style.scss              # entrada única; @use nos parciais de tema
    blu_theme.scss          # parcial de tema (equivalente ao tema SEI)
    fancytree.scss          # parcial de biblioteca de terceiro
  lib/src/
    modules/
      <modulo>/              # ex.: processos, documentos, blocos
        components/<nome>/   # peça reutilizável dentro do módulo
        pages/<nome>/         # página de rota, container
        models/               # DTO específico da tela, quando não é do core
        services/              # chamada HTTP e regra de tela do módulo
    shared/
      components/ di/ directives/ exceptions/ extensions/
      js_interop/ models/ pipes/ routes/ services/ utils/
```

Consequências diretas desse padrão:

- **Um único `style.scss`** como raiz de estilos, com `@use '<parcial>' as *;`
  para cada arquivo de tema — não múltiplos SCSS por componente. O NgDart 8
  deste projeto não isola estilo por componente da forma que frameworks mais
  recentes fazem; centralizar evita regra duplicada ou cascata imprevisível.
- **Página de rota mora em `pages/`, peça reutilizável mora em
  `components/`** — a mesma distinção que a seção seguinte já exige
  ("página de rota como container"), agora também expressa na pasta.
- **`models/` e `services/` de módulo são exceção, não regra.** DTO
  compartilhado com `backend`/`core` vai para `core/lib/src/models`, como já
  determina a seção "Arquitetura, modelos e DTOs" do `AGENTS.md`; `models/` do
  módulo do frontend só existe para estado de tela que não cruza pacote.
- **`shared/` do frontend espelha o vocabulário do `new_sali`**: um
  componente, diretiva, pipe ou serviço realmente reutilizável por mais de um
  módulo vai lá; o que serve a um módulo só fica dentro dele.

Regras obrigatórias:

- página de rota como container;
- componentes separados para cabeçalho, barra de ações, árvore, documento,
  andamento, painel lateral, filtros e modais;
- `@Input()` e `@Output()` tipados;
- `AfterChanges` para reagir a entradas;
- nenhum método de cálculo em binding;
- listas de template cacheadas;
- estado de permissão já calculado;
- `NgZone.run()` para callbacks nativos;
- `markForCheck()` quando `OnPush` depender de resultado assíncrono;
- cancelamento de subscriptions, observers e timers em `ngOnDestroy()`;
- URL como estado recuperável para aba, documento selecionado, página e filtro;
- retorno pelo navegador sem perder seleção, rolagem ou contexto.

#### Estado de execução local em 19 de agosto de 2026 — realinhamento estrutural

Primeira rodada de realinhamento do `frontend` ao padrão desta seção,
inspecionado diretamente em `new_sali/frontend`. Três frentes:

**Estrutura de pastas.** `lib/src/modules/processos` ganhou a distinção
`pages/` versus `components/`: o antigo `ProcessoDetalheComponent` virou
`ProcessoDetalhePage` em `pages/processo_detalhe/`, container que só carrega
o cabeçalho (o processo base) e delega cada seção a um componente próprio em
`components/`. Documentos e andamentos mantiveram o carregamento sob demanda
que já tinham; as oito seções novas (abaixo) carregam ao receber o processo,
por serem projeções pequenas. `ProcessoDetalheService` ganhou um método por
seção nova, todos reaproveitando o `_buscarLista`/`_buscarObjeto` já
existente. `shared/` **não** foi criado ainda — nenhum componente, diretiva
ou serviço deste módulo é reutilizado por outro módulo por enquanto, e a
seção 28.4 já registra que `shared/` só nasce quando isso passar a ser
verdade.

**SCSS.** `web/style.scss` passou a ser a entrada única, compilada pelo
`sass_builder` (adicionado como dev dependency) para `web/style.css`,
referenciado pelo `index.html` — confirmado com `styleUrls: [...css]`
apontando para `.scss` de origem, exatamente como `new_sali/frontend` faz
(`sass_builder` compila para `.css` dentro do grafo de build; a inspeção do
`new_sali` mostrou que **não** existe `.css` fisicamente ao lado do `.scss`
no repositório, só como artefato do build). Os `.css` que já existiam nos
componentes foram renomeados para `.scss` sem mudar `styleUrls`. O cartão
visual repetido pelas dez seções da tela do processo (`.secao-detalhe`,
tabela de rolagem, textos de carregando/vazio/erro) foi centralizado no
`style.scss` global em vez de duplicado em cada `.scss` de componente — a
mesma razão que a introdução desta seção já dava para um único `style.scss`.

**Novas seções de dados ligadas ao backend**, todas como componente próprio
com loading/erro/vazio no padrão de `AtividadesEmAbertoComponent`:
unidades abertas (com destaque visual de que o estado aberto/concluído é por
unidade, não do processo — `ProcessoUnidadeAberta` é lista, não booleano),
relacionados, participantes, marcadores, acompanhamentos, controles de prazo
e anotações (as duas últimas dependem de `idUnidade`, agora propagado de
`AppComponent` até a página) e retornos programados. Ficou de fora nesta
rodada o conteúdo de documento
(`GET /documentos/:idDocumento/conteudo`) — o método já existe em
`ProcessoDetalheService`, mas falta decidir a estratégia seria de exibição do
HTML interno sem risco de XSS, e falta integrar a seleção com a árvore de
documentos. `ngrouter` também não entrou nesta rodada: a navegação continua
por `*ngIf`/booleano em `AppComponent`, sem URL como estado recuperável, que
a seção acima exige — mudança maior, deixada como próximo passo para não
introduzir router pela metade.

Validado com `dart analyze` (sem apontamentos), `dart test` (13 testes,
todos verdes) e `dart run build_runner build --delete-conflicting-outputs`
(sucedido, `web/style.css` e o `.template.dart` de `ProcessoDetalhePage`
confirmados no `.dart_tool/build/generated`).

### 28.5 API interna e API de compatibilidade

Separar dois contratos:

1. **API interna tipada**, otimizada para a aplicação AngularDart;
2. **fachada de compatibilidade**, que preserva serviços, formatos e códigos
   esperados por clientes do SEI.

Não obrigar a interface nova a consumir payload legado cru. A fachada converte
entre contratos e possui testes próprios de round-trip.

---

## 29. Contrato de tela versionado

Cada tela deve possuir um arquivo em `backend/docs/ux/contratos`. Exemplo:

```yaml
id: SEI5-CP-001
nome: Controle de Processos
baseline: 5.0.0
rota: /sei/controlador.php?acao=procedimento_controlar
rota_dart: /sei/controle-processos
perfis: [usuario_interno]
viewports: [1366x768, 1920x1080, 1024x768]
regioes:
  - cabecalho_global
  - seletor_unidade
  - menu_principal
  - recebidos
  - gerados
  - barra_acoes_lote
  - paginacao
acoes:
  - receber
  - atribuir
  - enviar
  - concluir
  - incluir_bloco
estados:
  - vazio
  - carregando
  - com_processos
  - sem_permissao
atalhos:
  - tecla: Tab
    resultado: percorre controles na ordem visual
evidencias:
  - ../referencias/manuais_sei_publicos/imagens/1-IO_tela_controle_processos.png
testes:
  - controle_processos_visual_test.dart
  - controle_processos_fluxo_test.dart
```

O contrato deve registrar também:

- textos exatos;
- ícone semântico e tooltip;
- regras de habilitação;
- confirmação e mensagem final;
- requisições disparadas;
- entidades alteradas;
- auditoria gerada;
- foco após sucesso ou erro;
- comportamento durante clique duplo;
- comportamento com resposta atrasada;
- diferenças autorizadas.

---

## 30. Inventário mínimo de telas e fluxos

O inventário abaixo não substitui a leitura completa do manual. Ele define a
primeira linha de cobertura funcional e visual.

| ID | Tela ou fluxo | Elementos indispensáveis | Onda |
|---|---|---|---:|
| UX-001 | Login | órgão, usuário, senha, 2FA, erro e recuperação | 1 |
| UX-002 | Controle de Processos | recebidos, gerados, seleção em lote, cores e filtros | 1 |
| UX-003 | Menu principal | opções por perfil, recolhimento e atalhos | 1 |
| UX-004 | Iniciar processo | tipo, pesquisa, especificação, interessados, assunto e acesso | 2 |
| UX-005 | Tela do processo | cabeçalho, ações, árvore, unidades abertas e relacionados | 2 |
| UX-006 | Receber processo | lote, atualização de cor e andamento | 2 |
| UX-007 | Atribuir processo | usuário, filtro e redistribuição | 2 |
| UX-008 | Enviar processo | destino, manter aberto, retorno programado e lote | 2 |
| UX-009 | Concluir/reabrir | confirmação, permissões e situação por unidade | 2 |
| UX-010 | Incluir documento | tipo, interno/externo, nível, nato-digital e upload | 3 |
| UX-011 | Editor | seções, estilos, autotexto, links, imagens, salvar e versões | 3 |
| UX-012 | Tela do documento | conteúdo, tarjas, assinatura, publicação e ações | 3 |
| UX-013 | Assinar documento | cargo/função, senha/certificado, confirmação e estado | 3 |
| UX-014 | Versões | histórico, comparação e recuperação | 3 |
| UX-015 | Pesquisa | rápida, estruturada, no processo e restrição de acesso | 4 |
| UX-016 | Histórico/andamento | eventos, unidade, usuário, data e atualização manual | 4 |
| UX-017 | Bloco de assinatura | criação, disponibilização, assinatura e retorno | 4 |
| UX-018 | Bloco de reunião | disponibilização, visualização e devolução | 4 |
| UX-019 | Bloco interno | inclusão, consulta, reutilização e exclusão | 4 |
| UX-020 | Acompanhamento especial | grupo, observação e remoção | 4 |
| UX-021 | Marcadores/anotações | cor, texto, responsável, histórico e filtros | 4 |
| UX-022 | Restrito e sigiloso | hipótese, credenciais, cassação e auditoria | 5 |
| UX-023 | Acesso externo | convite, validade, documentos liberados e revogação | 5 |
| UX-024 | Usuário externo | cadastro, validação, login, assinatura e peticionamento | 5 |
| UX-025 | Relacionar/anexar processo | pesquisa, irreversibilidade e visualização | 5 |
| UX-026 | Sobrestar | motivo, processo relacionado e remoção | 5 |
| UX-027 | Gerar PDF/ZIP | seleção, ordem, limites e processamento | 5 |
| UX-028 | Publicar | veículo, data, resumo, cancelamento e comprovante | 6 |
| UX-029 | Estatísticas | filtros, totalização, exportação e autorização | 6 |
| UX-030 | Administração SIP | órgão, unidade, hierarquia, usuário, perfil e permissão | 6 |
| UX-031 | Administração SEI | catálogos, extensões, modelos, estilos e formulários | 6 |
| UX-032 | Configuração PEN | unidades, repositórios, espécies e hipóteses | 7 |
| UX-033 | Envio externo PEN | validação, destino, urgência, bloqueio e confirmação | 7 |
| UX-034 | Recebimento PEN | entrada em vermelho, recibo, documentos e andamento | 7 |
| UX-035 | Recibos PEN | consulta, integridade, envio e conclusão | 7 |
| UX-036 | Recusa/cancelamento PEN | motivo, estados, histórico e reprocessamento | 7 |

### 30.1 Tela de Controle de Processos

É a primeira tela operacional e deve ser implementada como vertical slice. O
aceite exige:

- mesma separação entre recebidos e gerados;
- mesma semântica de cores e números;
- seleção individual e seleção em lote;
- comandos exibidos conforme perfil e estado;
- ordenação equivalente;
- atribuição visível;
- retorno programado, marcador, anotação e ponto de controle;
- preservação do scroll após operação em lote;
- atualização sem duplicar ou perder linha;
- paginação e tempo de resposta aceitáveis com volume de produção;
- navegação completa por teclado.

### 30.2 Tela do Processo

Tratá-la como composição, não como um componente monolítico:

```text
ProcessoPage
  ProcessoCabecalhoComponent
  ProcessoAcoesComponent
  ProcessoArvoreComponent
    ProcessoArvorePastaComponent
    ProcessoArvoreItemComponent
  ProcessoConteudoComponent
    DocumentoInternoComponent
    DocumentoExternoComponent
  ProcessoUnidadesAbertasComponent
  ProcessoRelacionadosComponent
  ProcessoModalService
```

A seleção na árvore deve atualizar conteúdo, URL e ações de forma atômica. Ao
recarregar a URL, o mesmo item precisa reaparecer selecionado. Processo longo deve
usar carregamento incremental sem alterar a ordem observada no SEI.

Estado da API que sustenta esta composição:

| Componente | Rota | Situação |
| --- | --- | --- |
| `ProcessoCabecalhoComponent` | `GET /api/v1/processos/:id/cabecalho` | pronta |
| `ProcessoArvoreComponent` | `GET /api/v1/processos/:id/documentos` | pronta, com cursor |
| Consultar Andamento | `GET /api/v1/processos/:id/andamentos` | pronta, com cursor |
| `ProcessoUnidadesAbertasComponent` | `GET /api/v1/processos/:id/unidades-abertas` | pronta |
| `ProcessoRelacionadosComponent` | `GET /api/v1/processos/:id/relacionados` | pronta, nos dois sentidos |
| Interessados no cabeçalho | `GET /api/v1/processos/:id/participantes` | pronta |
| Anotações | `GET /api/v1/processos/:id/anotacoes?idUnidade=` | pronta, filtrada por unidade |
| Marcadores | `GET /api/v1/processos/:id/marcadores` | pronta, só os vigentes |
| Acompanhamento Especial | `GET /api/v1/processos/:id/acompanhamentos` | pronta, sem exigir processo aberto |
| Controle de Prazos | `GET /api/v1/processos/:id/controles-prazo?idUnidade=` | pronta, filtrada por unidade |
| Retorno Programado | `GET /api/v1/processos/:id/retornos-programados` | pronta, com `cumprido` calculado |
| `ProcessoConteudoComponent` | `GET /api/v1/processos/:id/documentos/:idDocumento/conteudo` | pronta; ponteiro de arquivo para externo, sem o byte |
| Blocos (Assinatura, Reunião, Interno) | `GET /api/v1/processos/:id/blocos` | pronta, blocos que contêm o protocolo |
| Base de Conhecimento | `GET /api/v1/processos/:id/bases-conhecimento` | pronta, associada ao tipo do processo |
| `ProcessoAcoesComponent` | comandos por perfil e estado | pendente, depende de autorização SIP |

Faltam ainda, para a tela ficar equivalente em leitura: processos anexados e
Ponto de Controle (sem linha real nas fontes locais para comprovar o
domínio).

### 30.3 Editor

O editor é um projeto dentro do projeto. Além da aparência, validar:

- round-trip do HTML;
- seções editáveis e não editáveis;
- estilos institucionais;
- variáveis do SEI;
- imagens incorporadas;
- links internos para processo e documento;
- autotexto e texto padrão;
- salvamento e criação de versão;
- comparação entre versões;
- assinatura e invalidação controlada após edição;
- impressão e PDF;
- colagem de Word/LibreOffice com sanitização determinística;
- proteção contra XSS sem destruir conteúdo válido legado.

---

## 31. Método forense para reproduzir cada fluxo

Para cada item do inventário:

1. preparar fixture mínima no oráculo;
2. registrar versão, banco, navegador, perfil, unidade e parâmetros;
3. executar o fluxo manualmente e anotar cada ação;
4. capturar tela antes e depois de cada ação;
5. registrar requisições HTTP e respostas sem credenciais;
6. tirar snapshot das linhas afetadas no banco;
7. registrar arquivos criados, alterados e hashes;
8. registrar auditorias e atividades;
9. repetir com erro de validação;
10. repetir sem permissão;
11. repetir com duas sessões concorrentes;
12. implementar o mesmo caso no Dart;
13. comparar UI, HTTP, banco, arquivos e auditoria;
14. classificar qualquer divergência;
15. aprovar o contrato e congelar o golden master.

### 31.1 Classificação de divergências

| Classe | Exemplo | Tratamento |
|---|---|---|
| Crítica | processo não abre no SEI oficial | bloqueia a entrega |
| Alta | permissão ou nível de acesso diferente | bloqueia a entrega |
| Média | passo, mensagem ou ordenação diferente | corrigir antes da homologação |
| Visual | espaçamento, cor ou ícone divergente | corrigir conforme orçamento visual |
| Autorizada | melhoria acessível documentada | registrar decisão e teste |
| Não determinística | horário ou identificador variável | mascarar de forma explícita |

### 31.2 Comparação visual

O teste visual deve:

- produzir PNG no mesmo viewport e escala;
- aguardar fontes, animações e requisições;
- desabilitar cursor piscante;
- mascarar apenas regiões declaradas;
- gerar imagem de diferença;
- medir percentual de pixels e SSIM;
- manter limiar por componente, não um limiar global permissivo;
- anexar baseline, resultado e diferença ao relatório de CI;
- exigir revisão humana para atualização de baseline.

Baseline nunca deve ser atualizado automaticamente porque o teste falhou.

---

## 32. Pacotes de trabalho implementáveis

### PT-00 — Governança, licenças e baseline

Entregáveis:

- termo exato da versão suportada;
- autorização de uso do SEI oficial como oráculo;
- revisão de marcas e ativos;
- matriz de versões SEI, SIP, mod-sei-pen e Tramita;
- responsáveis por domínio;
- processo de decisão de divergências;
- política de anonimização;
- Definition of Done deste roteiro adotada pela equipe.

### PT-01 — Laboratório reprodutível

Entregáveis:

- SEI 5.0.0 e SIP isolados;
- PostgreSQL e MySQL restauráveis;
- repositório de arquivos de teste;
- relógio, locale, timezone e encoding fixos;
- usuários e perfis de teste;
- captura de banco antes/depois;
- proxy de observação sem armazenar segredos;
- reset em um comando;
- checksum de todos os artefatos.

### PT-02 — Núcleo Dart e convenções

Entregáveis:

- monorepo `backend/core/frontend` compilando;
- DI, configuração e logging;
- erro de domínio tipado;
- envelope HTTP padronizado;
- paginação tipada;
- autenticação mínima;
- conexão PostgreSQL;
- lint, format, testes e cobertura no CI;
- modelo exemplo atravessando repository, service, controller e frontend.

### PT-03 — Manifesto e adaptadores de banco

Entregáveis:

- gerador de manifesto;
- diff de esquema;
- constantes de tabela e coluna;
- alocador de sequência PostgreSQL;
- emulação de sequência MySQL;
- normalização de tipos sem conversão desnecessária;
- teste das 194 tabelas;
- round-trip LATIN1;
- teste de datas, decimais, flags e `bigint`.

### PT-04 — Identidade, organização e SIP

Entregáveis:

- órgão, unidade, hierarquia, usuário, perfil e recurso;
- seleção de unidade corrente;
- sessão e expiração;
- middleware de autorização;
- cache invalidável de permissões;
- auditoria de acesso;
- telas administrativas equivalentes;
- testes de negação por padrão.

### PT-05 — Leitura processual

Entregáveis:

- Controle de Processos somente leitura;
- tela do processo;
- árvore completa;
- visualização de documento interno e externo;
- andamento;
- relacionados e unidades abertas;
- arquivos com Range;
- filtros e paginação;
- baselines visuais UX-002, UX-003 e UX-005.

### PT-06 — Escrita processual

Entregáveis:

- iniciar, receber, atribuir, enviar, concluir e reabrir;
- atividades equivalentes;
- numeração transacional;
- locks e conflitos 409;
- idempotência para clique duplo;
- auditoria;
- rollback por falha induzida;
- abertura do resultado no SEI oficial.

### PT-07 — Documentos e arquivos

Entregáveis:

- documento interno;
- documento externo;
- upload em streaming;
- extensão, MIME, limite e hash;
- versionamento;
- movimentação e exclusão conforme regra;
- geração de PDF/ZIP;
- antivírus quando aplicável;
- verificação recíproca SEI ↔ Dart.

### PT-08 — Editor

Entregáveis:

- motor por seções;
- estilos, modelos, textos padrão e autotexto;
- sanitização;
- links internos;
- imagens;
- comparação de versões;
- impressão/PDF;
- corpus de pelo menos 100 documentos representativos;
- teste byte a byte onde a equivalência exigir e teste semântico nos demais.

### PT-09 — Assinaturas

Entregáveis:

- assinatura com senha;
- certificado digital quando contratado;
- assinatura GOV.BR se estiver no escopo autorizado;
- múltiplos assinantes;
- tarjas e validação;
- preservação de evidências;
- revogação e verificação temporal;
- validação no SEI oficial e em ferramenta independente.

### PT-10 — Colaboração e gestão documental

Entregáveis:

- blocos;
- acompanhamento especial;
- marcadores e anotações;
- retorno programado e prazo;
- relacionamento, anexação e sobrestamento;
- publicação;
- avaliação, arquivamento e eliminação conforme baseline;
- casos concorrentes e em lote.

### PT-11 — Pesquisa e relatórios

Entregáveis:

- pesquisa rápida, estruturada e dentro do processo;
- indexação incremental;
- autorização aplicada antes da exposição;
- reindexação;
- estatísticas e relatórios;
- exportação;
- teste contra vazamento de restritos e sigilosos;
- benchmark com volume representativo.

### PT-12 — Usuário externo

Entregáveis:

- cadastro e aprovação;
- recuperação de acesso;
- acesso externo ao processo;
- assinatura externa;
- peticionamento, se incluído no baseline contratado;
- recibo;
- expiração e revogação;
- proteção contra enumeração e abuso.

### PT-13 — PEN em Dart

Entregáveis:

- migrations das 42 tabelas `md_pen_*` compatíveis;
- parâmetros;
- catálogos e mapeamentos;
- cliente Tramita versionado;
- envio, recebimento, recibos, recusa e cancelamento;
- envio parcial e em lote;
- workers idempotentes;
- tela e diagnóstico equivalentes;
- homologação oficial.

### PT-14 — Coexistência, migração e operação

Entregáveis:

- leitura sombra;
- comparação online sem expor dados;
- backup e restore;
- observabilidade;
- plano de corte;
- ensaio de rollback;
- runbooks;
- capacitação baseada na mesma experiência do SEI;
- aceite operacional e jurídico.

---

## 33. Plano detalhado de compatibilidade de banco

### 33.1 Regra de ouro

As tabelas oficiais são um contrato externo. Não renomear, “corrigir”, adicionar
colunas próprias ou mudar defaults para facilitar a aplicação Dart. Estado
exclusivo do Dart fica em banco ou schema auxiliar claramente separado.

### 33.2 Ordem de implementação das entidades

1. `orgao`, `unidade`, `usuario` e tabelas de relacionamento;
2. `protocolo`;
3. `procedimento`;
4. `documento`;
5. `atividade` e `tarefa`;
6. `serie`, `tipo_procedimento`, `assunto` e hipóteses;
7. arquivos, versões e assinaturas;
8. acesso e credenciais;
9. blocos e acompanhamentos;
10. publicação e gestão documental;
11. serviços e federação;
12. tabelas `md_pen_*`.

### 33.3 Checklist por tabela

- nome e schema;
- colunas e ordem física;
- tipo por dialeto;
- nulabilidade;
- default;
- chave primária;
- sequence ou tabela `seq_*`;
- chaves estrangeiras;
- índices e unicidade;
- triggers;
- comentários;
- valores de domínio;
- factory Dart;
- `toMap()`;
- consulta de leitura;
- insert com colunas explícitas;
- update otimista ou pessimista;
- delete físico/lógico conforme regra;
- teste de round-trip;
- teste diferencial;
- volume esperado em produção.

### 33.4 Transações críticas

Definir e testar explicitamente limites transacionais para:

- autuação e numeração;
- inclusão de documento;
- salvamento de versão;
- assinatura;
- recebimento;
- envio interno;
- conclusão e reabertura;
- concessão de credencial;
- anexação de processo;
- publicação;
- reserva e processamento de trabalho PEN.

Falha injetada após cada etapa deve provar rollback integral. Efeito externo não
transacional deve usar outbox ou estado persistido reconciliável.

---

## 34. Portabilidade verificável do `mod-sei-pen`

O pacote local contém 297 arquivos PHP, 77 testes funcionais, 19 testes unitários,
42 descrições de tabela e 18 imagens de uso. Esses números devem virar itens de
rastreabilidade, não apenas material de leitura.

### 34.1 Matriz de portabilidade

Criar `backend/docs/pen/matriz_portabilidade.csv`:

```text
origem_php,tipo,capacidade,rota_ou_tarefa,tabela_principal,
classe_dart,teste_origem,teste_dart,status,divergencia,observacao
```

Status permitidos:

- `NAO_ANALISADO`;
- `MAPEADO`;
- `IMPLEMENTADO`;
- `TESTE_UNITARIO`;
- `TESTE_DIFERENCIAL`;
- `HOMOLOGADO`;
- `NAO_APLICAVEL`, sempre com justificativa.

### 34.2 Subdomínios PEN

- configuração e parâmetros;
- repositórios de estruturas;
- unidades e hierarquia externa;
- espécies documentais;
- hipóteses legais;
- tipos de processo;
- restrições de componentes digitais;
- protocolo eletrônico;
- componente digital;
- blocos e lotes;
- tarefa e operação;
- recibos de envio e conclusão;
- pendências;
- monitoramento;
- recusa;
- cancelamento;
- reprocessamento;
- diagnóstico.

### 34.3 Máquina de estados persistida

Não representar o fluxo somente por chamadas encadeadas em memória. Cada etapa
deve possuir estado persistido, contador de tentativa, próxima execução, último
erro sanitizado, correlação externa, lease e timestamps sem fuso, conforme o
contrato do banco adotado.

Regras mínimas:

- reservar com lock que impeça dois workers;
- renovar lease em trabalho longo;
- considerar sucesso repetido como idempotente;
- não reenviar componente confirmado;
- não criar segundo processo ao repetir recebimento;
- guardar recibo antes de marcar conclusão;
- reconciliar estado local com o Tramita;
- permitir intervenção manual auditada;
- nunca registrar certificado, senha ou payload documental sensível em log.

### 34.4 Gates de homologação PEN

1. todos os mapeamentos configurados;
2. certificado válido em homologação;
3. relógio sincronizado;
4. conectividade e mTLS validados;
5. envio simples;
6. envio com múltiplos documentos;
7. envio em lote;
8. recebimento simples;
9. recebimento com processo apensado;
10. recusa;
11. cancelamento;
12. indisponibilidade durante upload;
13. reinício do worker;
14. repetição da mesma notificação;
15. hash divergente;
16. espécie sem mapeamento;
17. hipótese sem mapeamento;
18. tamanho não suportado;
19. recibos conferidos nas duas pontas;
20. reconciliação sem pendência órfã.

---

## 35. Estratégia de testes por camada

| Camada | Objetivo | Frequência |
|---|---|---|
| Unitário | enum, parser, regra e máquina de estados | todo commit |
| Model/DTO | `fromMap()`/`toMap()` e round-trip | todo commit |
| Repository | SQL real nos dois dialetos | todo merge |
| Service | transação, conflito e efeito coordenado | todo merge |
| Controller | HTTP, autenticação, status e serialização | todo merge |
| Componente | estado, evento e lifecycle | todo merge |
| Visual | layout nos viewports congelados | todo merge relevante |
| E2E | fluxo do usuário completo | diário e release |
| Diferencial | SEI oficial versus Dart | diário e release |
| Segurança | autorização, upload, XSS e segredo | diário e release |
| Desempenho | volume e concorrência | semanal e release |
| Recuperação | backup, restore, fila e rollback | por release |

### 35.1 Casos mínimos de concorrência

- dois usuários recebem o mesmo processo;
- dois usuários atribuem o mesmo processo;
- envio e inclusão de documento simultâneos;
- duas assinaturas no mesmo documento;
- edição após assinatura;
- exclusão enquanto outra sessão visualiza;
- dois workers processam a mesma tarefa PEN;
- retry após timeout cuja operação externa pode ter concluído;
- troca de unidade durante operação aberta;
- sessão expira após confirmação e antes da resposta.

### 35.2 Massa de desempenho

Preparar massas sintéticas com:

- 10 mil processos na unidade;
- 1 milhão de atividades;
- processo com 10 mil documentos;
- arquivos pequenos e arquivos no limite permitido;
- milhares de usuários/unidades;
- fila PEN represada;
- pesquisa com documentos restritos misturados;
- histórico de auditoria grande.

Nenhuma massa deve conter dado pessoal real.

---

## 36. Segurança e validade documental

### 36.1 Ameaças prioritárias

- IDOR em processo e documento;
- enumeração de protocolo;
- bypass de unidade ou perfil;
- vazamento por pesquisa, cache, PDF ou ZIP;
- XSS persistente no editor;
- upload poliglota ou MIME falso;
- path traversal no repositório;
- SSRF em integrações;
- replay de assinatura ou recibo;
- segredo em log;
- tarefa PEN forjada;
- acesso após revogação;
- race condition de credencial;
- sessão fixada ou roubada.

### 36.2 Controles

- autorização no backend em toda leitura e escrita;
- negação por padrão;
- checagem de acesso dentro da mesma transação da operação;
- streaming sem expor caminho físico;
- nomes físicos não previsíveis;
- hash na gravação e na leitura crítica;
- CSP e sanitização por allowlist;
- cookies seguros e rotação de sessão;
- proteção CSRF quando aplicável;
- rate limit específico por fluxo;
- cofre de segredos;
- auditoria imutável o suficiente para investigação;
- dependências e imagens verificadas;
- pentest antes do piloto.

---

## 37. Observabilidade e operação

### 37.1 Métricas

- latência e erro por rota;
- conexões e espera do pool;
- deadlocks e conflitos;
- tempo da tela de controle;
- tempo da árvore;
- primeiro byte de documento;
- geração de PDF/ZIP;
- tamanho e idade das filas;
- tentativas PEN;
- lease expirado;
- recibos pendentes;
- falhas de hash;
- login e 2FA sem registrar credenciais.

### 37.2 Correlação

Propagar identificadores distintos:

- `request_id` para requisição;
- `session_id_hash` não reversível;
- identificador do processo sem expor assunto em log;
- `trabalho_id` para fila;
- `tramite_id` e correlação externa PEN;
- `audit_id` para evento persistido.

### 37.3 Runbooks obrigatórios

- banco indisponível;
- repositório de arquivos indisponível;
- índice atrasado;
- documento com hash divergente;
- fila parada;
- Tramita indisponível;
- certificado próximo de vencer;
- processo PEN órfão;
- restauração de backup;
- rollback para SEI oficial;
- incidente de acesso indevido;
- rotação de segredo.

---

## 38. Definition of Done por história

Uma história só termina quando:

1. regra e evidência de origem estão ligadas;
2. contrato tipado está no `core`, se compartilhado;
3. SQL está no repository;
4. transação está no service;
5. controller apenas transporta;
6. componente possui estado estável;
7. textos estão em português correto;
8. autorização foi testada;
9. auditoria foi testada;
10. teste unitário passou;
11. teste de integração passou;
12. teste diferencial passou, quando aplicável;
13. teste visual passou, quando há UI;
14. concorrência foi considerada;
15. desempenho foi medido em consulta crítica;
16. documentação e matriz de rastreabilidade foram atualizadas;
17. dados criados abrem no SEI oficial;
18. rollback local foi demonstrado;
19. `dart format` foi executado;
20. análise estática e build passaram.

---

## 39. Sequência executável das primeiras entregas

### Entrega E1 — Laboratório e manifesto

Resultado demonstrável: restaurar a Base de Referência, gerar o manifesto e
obter diff zero após nova restauração.

### Estado de execução local em 5 de agosto de 2026

O laboratório local possui as bases oficiais de referência `sei_5_0_0` e
`sip_5_0_0`, restauradas em PostgreSQL 16.7 com codificação `LATIN1`. A fonte
canônica é o clone local de `sei-db-ref-executivo`, espelhado byte a byte em
`resources/`; a cópia UTF-8 que contém
caracteres `�` permanece somente como evidência de corrupção e não participa de
leitura, testes ou restauração.

O script reproduzível é
`backend/referencias/backup_sei_bd/restaurar_referencia_postgresql.ps1`. Ele
cria primeiro uma base LATIN1, exige confirmação explícita para substituição e
valida texto acentuado ao final.

Já existe uma primeira fatia somente leitura em Dart:

- DTOs compartilhados para catálogo, contexto de desenvolvimento, unidades e
  fila de atividades;
- API para catálogos, contexto de desenvolvimento, Recebidos e Gerados;
- conexão SIP independente e rota somente leitura para sistemas ativos, sem
  autenticar, criar sessão ou interpretar permissões;
- interface AngularDart que carrega o usuário de referência e permite escolher
  uma unidade real da base antes de consultar a fila;
- separação comprovada entre as abas Recebidos (`atividade.sin_inicial = 'N'`)
  e Gerados (`atividade.sin_inicial = 'S'`), usando o índice nativo
  `i03_atividade`; as fontes e limites estão em
  `backend/docs/evidencias_controle_processos.md`;
- ausência intencional de processos sintéticos na base de referência.

Esta fatia **não é autenticação SIP** e não afirma autorização equivalente. A
E2 ainda depende de autenticação, autorização por recurso, fixture anonimizada
ou instalação autorizada com processo real, paginação completa, filtros e
baseline visual diferencial.

### Estado de execução local em 18 de agosto de 2026

O inventário funcional do SEI foi consolidado a partir do corpus local e está
em `backend/docs/inventario_funcional_sei.md`, com as provas dos códigos de
domínio em `backend/docs/evidencias_processo_detalhe.md`. Ele substitui a
pesquisa em manuais de terceiros como referência de comportamento: o manual
oficial do usuário, o manual do administrador, o código do `mod-sei-pen` e a
Base de Referência 5.0.0 já estão em `backend/referencias/`.

#### Modelo operacional por unidade, agora executável

A afirmação central do SEI — **o estado aberto não pertence ao processo, e sim
ao par processo e unidade** — deixou de ser texto e virou consulta, DTO e
teste:

- `ProcessoUnidadeAberta` agrega `atividade` por unidade com `dth_conclusao`
  nula, preserva a contagem de atividades abertas, separa unidade geradora de
  recebedora e resolve a atribuição da atividade mais recente;
- `GET /api/v1/processos/:id/unidades-abertas` é a projeção que sustenta o
  `ProcessoUnidadesAbertasComponent` previsto na seção 30.2;
- `GET /api/v1/processos/:id/relacionados` percorre os dois sentidos de
  `rel_protocolo_protocolo`, porque o vínculo é gravado uma única vez e é
  direcionado, embora a tela o exiba nos dois processos;
- `GET /api/v1/processos/:id/participantes` traz interessados, remetentes e
  destinatários com o código bruto preservado.

#### Catálogo de tarefas como contrato de comportamento

`GET /api/v1/catalogos/tarefas` expõe as 119 tarefas da Base de Referência com
as quatro marcações que governam o estado do processo. É a partir delas que se
reproduz, sem adivinhação, por que **enviar não conclui por si só**: a tarefa
32 não fecha andamentos abertos, e quem conclui na origem é a tarefa 41,
lançada apenas quando a opção de manter o processo aberto não é marcada. O
teste `catalogo_repository_test.dart` trava esse comportamento contra a base
restaurada.

Códigos de domínio comprovados e implementados nesta etapa: `TipoProtocolo`
(`P`, `G`, `R`), `EstadoProtocolo` (`0`, `2`, `4`, `5`), `AssociacaoProtocolo`
(`1`, `3`), `ProcessoParticipacao` (`I`, `R`, `D`) e `TarefaSei`.

#### Fixture transacional: dado real sem sujar a Base de Referência

A restrição de não criar processo sintético na base oficial permanece, mas
deixou de bloquear a cobertura. `EscopoRepositorioTeste.emTransacaoRevertida`
abre uma transação, registra a conexão dela em um contêiner-filho do Angel — de
modo que os repositórios saem das mesmas fábricas do DI de produção — e força o
`rollback` ao final por exceção sentinela. `FixtureProcessoSei` monta o cenário
completo e o último teste do arquivo confere que a base volta ao estado
anterior.

Isso destrava a verificação que faltava desde a E1: as consultas por unidade
passaram a ser exercitadas contra linhas reais, e não apenas contra página
vazia.

#### Primeiras entidades graváveis do núcleo processual

Com a fixture surgiu a primeira escrita do projeto, e com ela a regra agora
registrada em `AGENTS.md`: **todo model que grava dados em tabela do banco deve
sobrescrever `toInsertMap()` e `toUpdateMap()`**, e o mapa de escrita nunca é
montado à mão no repositório, no service ou no teste.

`Protocolo`, `Procedimento`, `Atividade`, `Participante` e `RelacaoProtocolo`
são as primeiras entidades persistíveis do `core`. Todas atribuem o
identificador na aplicação, porque nenhuma dessas colunas tem `DEFAULT` na
Base de Referência — o que já antecipa a decisão da seção 5.3 sobre alocação de
identificadores. Elas são a base da Fase 4.

### Estado de execução local em 18 de agosto de 2026 — sinalizações da unidade

Continuando a leitura de `backend/docs` e `backend/referencias`, a segunda
rodada do dia cobriu os cinco recursos que a §30.2 já apontava como pendentes:
**anotação, marcador, acompanhamento especial, controle de prazo e retorno
programado**. Ponto de Controle ficou de fora — `situacao` e
`andamento_situacao` têm esquema claro, mas zero linhas tanto na Base de
Referência quanto no dump histórico, sem nenhuma linha real para cruzar.

Cinco entidades persistíveis novas no `core` (`Anotacao`, `Marcador`,
`AndamentoMarcador`, `GrupoAcompanhamento`, `Acompanhamento`, `ControlePrazo`,
`RetornoProgramado` — sete, na verdade, contando o catálogo de grupo) seguem a
mesma regra de `toInsertMap()`/`toUpdateMap()`, e cinco projeções de leitura
(`ProcessoAnotacao`, `ProcessoMarcador`, `ProcessoAcompanhamento`,
`ProcessoControlePrazo`, `ProcessoRetornoProgramado`) resolvem nome de unidade
e de usuário via `join`. Rotas novas:

- `GET /api/v1/processos/:id/anotacoes?idUnidade=` — filtra por unidade, porque
  a anotação nunca tramita e é exclusiva de quem a criou;
- `GET /api/v1/processos/:id/marcadores` — só os vigentes;
- `GET /api/v1/processos/:id/acompanhamentos` — todas as unidades, sem exigir
  processo aberto ali;
- `GET /api/v1/processos/:id/controles-prazo?idUnidade=` — filtra por unidade;
- `GET /api/v1/processos/:id/retornos-programados` — com `cumprido` calculado.

**Achado que corrige uma suposição do roteiro.** O histórico de marcador
(`andamento_marcador`) não é só *append*: uma remoção real também **rebaixa a
linha até então corrente**, mudando o `sin_ultimo` dela de `S` para `N`. Isso
foi descoberto porque o teste "marcador removido não aparece como vigente"
falhou na primeira tentativa — inserir só a linha de remoção não bastava, a
leitura continuava enxergando a inclusão antiga. A prova ficou registrada no
próprio teste e em `backend/docs/evidencias_processo_detalhe.md`; deve
orientar o service de remoção quando ele existir, para não repetir o erro em
produção.

**Achado sobre Acompanhamento Especial.** A fixture provou empiricamente, e não
só por leitura de manual, que o recurso funciona com o processo já concluído
na unidade que acompanha: o cenário de teste usa deliberadamente a unidade que
concluiu o processo principal, e a leitura retorna o acompanhamento
normalmente.

### Estado de execução local em 18 de agosto de 2026 — conteúdo de documento

Terceira rodada do dia: leitura do corpo do documento, a peça central do
`ProcessoConteudoComponent` que a §30.2 listava como pendente.

O cruzamento de `documento.sta_documento` com `protocolo.sta_protocolo`,
`documento.sta_editor` e `documento.sin_versoes` no dump histórico é exato
para os dois códigos principais (535 e 306 ocorrências, zero exceção),
confirmando o mecanismo: documento interno tem corpo HTML em
`documento_conteudo.conteudo`; documento externo não tem linha ali — o
ponteiro para o arquivo vem de `anexo`, cruzado por
`anexo.id_protocolo = documento.id_documento`, sempre 1:1. Há um terceiro
código, `A`, com uma única ocorrência, insuficiente para significado seguro e
por isso não declarado.

Três entidades persistíveis novas no `core` (`Documento`, `DocumentoConteudo`,
`Anexo`) e uma projeção de leitura (`ProcessoDocumentoConteudo`) que une os
dois caminhos com `LEFT JOIN` duplo — só um lado vem preenchido, conforme o
estado do documento. Rota nova:

- `GET /api/v1/processos/:idProcesso/documentos/:idDocumento/conteudo` —
  devolve o HTML para documento interno ou o ponteiro do anexo (nome, tamanho,
  hash, data) para documento externo, nunca os dois.

**O byte do arquivo em si não está no banco.** `anexo` só guarda metadados;
servir o arquivo depende do `SeiFileRepository` da seção 9, ainda não
implementado. Este endpoint entrega o ponteiro, não o conteúdo binário.

Achado de modelagem: `documento.sta_editor` é `NOT NULL` no banco, mas sua
correlação com interno/externo (`'2'`/`'0'`) pode refletir apenas "documento
externo não tem editor", não um domínio de tipos de editor — por isso
`Documento.editor` é campo obrigatório mas sem enum.

### Estado de execução local em 19 de agosto de 2026 — Blocos e Base de Conhecimento

Quarta rodada: os dois últimos recursos que a §30.2 listava como pendentes,
Blocos (Assinatura, Reunião, Interno) e Base de Conhecimento, agora têm
leitura na tela do processo.

**Blocos.** O manual do usuário descreve os três tipos e cinco rótulos de
estado, mas nenhum deles tinha código de banco comprovado antes desta rodada.
O cruzamento das 113 linhas de `bloco`, 83 de `rel_bloco_protocolo` e 204 de
`rel_bloco_unidade` do dump histórico fechou os dois domínios com cobertura
de 100% dos dados observados:

- `bloco.sta_tipo`: `A` (95, Assinatura), `I` (16, Interno) e `R` (2,
  Reunião) — confirmado não só pela inicial, mas pelo conteúdo: bloco `A` só
  contém protocolo `G` (documento), blocos `I`/`R` só contêm protocolo `P`
  (processo), sem exceção;
- `bloco.sta_estado`: `A` (48, Gerado), `D` (64, Disponibilizado) e `C` (1,
  Concluído). O quarto rótulo do manual, "Recebido", não é um código à
  parte — é o mesmo `D` visto pela unidade destinatária, conforme o próprio
  texto do manual. O quinto, "Retornado", **não foi declarado**: zero linhas
  do dump gravam esse estado, e a única fonte de código literal
  (`TramiteEmBlocoRN::$TE_RETORNADO = 'R'`) descreve uma tabela distinta do
  módulo PEN (`md_pen_bloco`), não `public.bloco`.

Seis entidades persistíveis novas no `core` (`Bloco`, `RelacaoBlocoProtocolo`,
`RelacaoBlocoUnidade`, `GrupoBloco`, `BaseConhecimento`,
`BaseConhecimentoTipoProcedimento`) seguem a mesma regra de
`toInsertMap()`/`toUpdateMap()` — três delas com chave primária composta por
duas colunas atribuídas pela aplicação, sem coluna de identidade própria. Uma
projeção de leitura nova, `ProcessoBloco`, resolve unidade geradora e usuário
via `join`; o Grupo do bloco ficou de fora dela porque vive em
`rel_bloco_unidade.id_grupo_bloco` (atributo por unidade, não do bloco).

**Base de Conhecimento.** Zero linhas em `base_conhecimento` e
`rel_base_conhec_tipo_proced`, tanto na Base de Referência quanto no dump
histórico — sem nenhum dado real, `sta_estado` e `sta_documento` ficaram sem
enum, código bruto preservado, no mesmo padrão de `Anotacao.situacao`. A
leitura estrutural não teve ambiguidade: a associação é ao **tipo de
processo**, não ao processo, via `rel_base_conhec_tipo_proced`, e a projeção
`ProcessoBaseConhecimento` parte de `procedimento` para resolver o tipo do
processo consultado antes de juntar `base_conhecimento`.

Rotas novas:

- `GET /api/v1/processos/:id/blocos` — blocos que contêm este protocolo;
  como `rel_bloco_protocolo.id_protocolo` é genérico, o filtro já cobre
  processo e documento;
- `GET /api/v1/processos/:id/bases-conhecimento` — bases associadas ao tipo
  do processo, não ao processo em si, reproduzindo por que o SEI mostra o
  ícone "B" para todo processo daquele tipo.

#### O que a E2 ainda exige

Autenticação e autorização por recurso do SIP, paginação e filtros completos do
Controle de Processos, e baseline visual diferencial. A fixture transacional
cobre a verificação de consulta, mas **não** substitui uma instalação
autorizada com processo real para a comparação de tela.

### Entrega E2 — Primeira linha na tela

Resultado demonstrável: autenticar, escolher unidade e exibir um processo real
anonimizado na posição correta da tela de controle, sem escrita.

### Entrega E3 — Processo completo somente leitura

Resultado demonstrável: abrir árvore, documentos e andamento, com arquivos e
restrição de acesso equivalentes.

### Entrega E4 — Primeira operação reversível

Resultado demonstrável: receber ou atribuir um processo, comparar banco e
auditoria e repetir sem inconsistência.

### Entrega E5 — Vertical slice de autuação

Resultado demonstrável: criar processo no Dart, abrir no SEI oficial, incluir
documento simples, assinar e enviar internamente.

### Entrega E6 — Editor e documento completo

Resultado demonstrável: criar documento a partir de modelo, editar, versionar,
assinar e gerar PDF equivalente.

### Entrega E7 — Fluxos amplos

Resultado demonstrável: blocos, pesquisa, acesso externo, publicação e gestão
documental conforme matriz.

### Entrega E8 — PEN homologado

Resultado demonstrável: tramitar ida e volta com recibos, falha induzida, retry
idempotente e reconciliação sem órfãos.

### Entrega E9 — Operação sombra

Resultado demonstrável: comparar leituras e decisões sem escrever pelo Dart,
gerando relatório diário de divergências.

### Entrega E10 — Piloto reversível

Resultado demonstrável: uma unidade piloto opera no Dart e retorna ao SEI
oficial dentro do RTO aprovado, sem conversão de dados.

---

## 40. Artefatos de rastreabilidade a criar

```text
backend/docs/
  arquitetura/
    decisoes/ADR-*.md
    modulos.md
    transacoes.md
  compatibilidade/
    matriz_tabelas.csv
    matriz_fluxos.csv
    matriz_servicos.csv
    divergencias.md
  ux/
    catalogo_telas_sei_5.csv
    contratos/*.yaml
    baselines/
    relatorios_diff/
  pen/
    matriz_portabilidade.csv
    maquina_estados.md
    homologacao.md
  operacao/
    runbooks/*.md
    backup_restore.md
    corte_rollback.md
```

Toda linha das matrizes deve apontar para teste automatizado, evidência manual ou
justificativa explícita de pendência.

---

## 41. Gates para usar a expressão “100% compatível”

A expressão só poderá aparecer em material de entrega quando:

- o escopo disser exatamente “SEI 5.0.0 + SIP correspondente + versão fixada do
  mod-sei-pen + dialetos homologados”;
- não houver divergência crítica ou alta aberta;
- todas as tabelas e sequências do baseline tiverem cobertura;
- todos os fluxos do inventário contratado tiverem teste diferencial;
- todas as telas do modo compatível tiverem contrato e baseline;
- serviços legados contratados tiverem contrato;
- PEN estiver homologado no ambiente oficial aplicável;
- backup, restauração, corte e rollback tiverem sido ensaiados;
- segurança, acessibilidade e desempenho tiverem aceite;
- a instituição titular tiver aprovado as divergências deliberadas.

Até esse ponto, prefira a formulação precisa: **“reimplementação Dart em processo
de compatibilidade com o baseline SEI 5.0.0”**.

---

## 42. Próxima ação recomendada

Não iniciar dezenas de telas em paralelo. Começar por dois vertical slices:

1. **Controle de Processos somente leitura**, para provar autenticação, SIP,
   autorização, banco, DTO, API, AngularDart, densidade visual e desempenho.
2. **Autuação + documento simples + assinatura + envio**, para provar escrita,
   sequência, transação, arquivo, auditoria e abertura recíproca no SEI oficial.

Depois desses dois slices, recalibrar estimativa, equipe e riscos com evidência
real. Se qualquer um não puder ser comparado contra uma instalação autorizada do
SEI 5.0.0, o projeto ainda estará produzindo uma interpretação do SEI, não uma
implementação comprovadamente idêntica.

---

## 43. Fontes públicas consultadas

Consulta realizada em 5 de agosto de 2026:

- documentação oficial do SEI no MGI:
  <https://www.gov.br/gestao/pt-br/assuntos/gestaoeinovacao/informacoes-sistemas-e-servicos-de-gestao/processo-eletronico-nacional/servicos/documentacao>;
- Manual do Usuário SEI 4.0+:
  <https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/>;
- Manual do Administrador:
  <https://manuais.processoeletronico.gov.br/pt-br/latest/SEIADM/>;
- Manual do Usuário publicado pela Polícia Federal:
  <https://www.gov.br/pf/pt-br/acesso-a-informacao/sei/manual_do_usuario_sei.pdf/view>;
- Manual do Usuário publicado pela Fundação Biblioteca Nacional:
  <https://www.gov.br/bn/pt-br/central-de-conteudos/producao/documentos/downloads/manual-usuario-sistema-eletronico-informacoes-4250-cleaned.pdf/view>;
- Manual de Uso SEI 4.0 publicado pelo INES:
  <https://www.gov.br/ines/pt-br/sistemas/sei-1/ManualdeUsoSEI4.0.pdf>;
- projeto público do `mod-sei-pen`:
  <https://github.com/pengovbr/mod-sei-pen>;
- código local de inspiração arquitetural:
  `C:\MyDartProjects\new_sali`.

As páginas online podem mudar. Para comparações reprodutíveis, use as cópias e
os hashes registrados em
`backend/referencias/manuais_sei_publicos/manifesto_downloads.csv`.
