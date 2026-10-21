# Regras para agentes no SEI

Este arquivo é a fonte única de instruções do repositório.

## Idioma e comunicação

- Responda sempre em português do Brasil; nunca responda em inglês.
- Mensagens de commit devem usar português do Brasil, com acentuação, ortografia e gramática corretas.
- **Todo texto que o projeto escreve em português vai acentuado**, sem exceção: Dartdoc (`///`), comentários de código (`//`, `/* */`), `COMMENT ON TABLE`/`COLUMN`, comentários de migration e de script SQL, mensagens de erro e de log, textos de tela, e o conteúdo dos roteiros em `backend/doc`. Escreva `função`, `transação`, `usuário`, `é`, `só`, `após`, `já`, `não`, `histórico`, `código`, `índice`, `número`, `próprio`, `único`, `disponível`, `serviço`, `negócio`, `vínculo`, `concorrência`, `memória`, `período`. Nada de `funcao`, `transacao`, `usuario`, `e` no lugar de `é`.
- A única exceção são **identificadores** (nomes de classe, método, variável, tabela, coluna, chave de `.env`, valor de enum persistido), que continuam sem acento e sem cedilha por serem lidos por máquina — `data_atualizacao`, `TrabalhoStatus.concluido`, `bg_manutencao_habilitado`. O texto ao redor deles é acentuado normalmente.
- **Nome de teste (`test('...')`, `group('...')`) também vai SEM acento**, em português simples: `test('vinculo duplicado e recusado com 409')`. Motivo: o nome é impresso no console do runner e usado para filtrar execução (`--name`), onde acento atrapalha a leitura e o casamento do filtro. O `reason:` das asserções e os comentários do arquivo de teste continuam acentuados normalmente.

## Git e publicação

- Nunca use o GitHub CLI (`gh`) nem fluxos, skills ou ferramentas de publicação do GitHub neste repositório.
- Para operações remotas, use exclusivamente os comandos nativos do Git e os remotos já configurados.
- Quando o pedido for somente commit e push, não crie pull request nem execute ações adicionais de publicação.

## Execução de comandos

- Execute testes e ferramentas com `timeout-cli` de 60, 120 ou 240 segundos, conforme o custo esperado, para evitar processos presos.
- Não execute `./start.ps1` para validar compilação; esse comando é iniciado manualmente pelo usuário.
- Para validar o frontend, use `Set-Location frontend; timeout-cli 240 dart run build_runner build --delete-conflicting-outputs`.
- Não use `Push-Location frontend; timeout-cli 120 dart c:\MyDartProjects\webdev\webdev\bin\webdev.dart serve --spa-fallback web:8081 --hostname 127.0.0.1 --auto refresh; Pop-Location` como validação de build.
- Não rode `build_runner build` em paralelo com `./start.ps1` ou `webdev`. Se o usuário informar que a compilação já está correta, aceite esse resultado e não dispare outro build.

## Arquitetura, modelos e DTOs

- Classes de modelo ou DTO compartilhadas entre `backend`, `frontend` e `core` devem ficar no pacote `core`.
- Todo modelo ou DTO criado no `core/lib/src/models` deve implementar `BaseModel`.
- **Todo model que grava dados em tabela do banco deve sobrescrever `toInsertMap()` e `toUpdateMap()`.** Um model é considerado persistível quando alguma escrita — `insert`, `insertGetId`, `insertMany`, `update` — recebe os campos dele, inclusive em fixture de teste e em script de carga. Nesse caso, é proibido montar o `Map<String, dynamic>` de escrita à mão no repository, no service ou no teste: o mapa vem do model.
- `toInsertMap()` retorna as colunas aceitas em uma inserção e **omite a chave primária gerada pelo banco**; quando o identificador é atribuído pela aplicação, ele entra no mapa e isso fica registrado no Dartdoc do model. `toUpdateMap()` retorna somente as colunas atualizáveis e **nunca inclui a chave de identidade**, que pertence ao filtro da query.
- As chaves dos dois mapas são as **constantes de coluna do próprio model** (`idProcessoCol`, `dataAberturaCol`), nunca literais soltos, e correspondem aos nomes reais das colunas da tabela — diferentemente de `toMap()`, que é contrato de transporte da API e pode expor nomes de projeção.
- Projeção de consulta, envelope de página, filtro e DTO de resposta **não** são persistíveis: eles mantêm a implementação herdada de `BaseModel`, que lança `UnsupportedError`. Isso é intencional e impede que uma projeção incompleta seja gravada em tabela por acidente.
- Model persistível que a tela edita também deve oferecer construtor de instância nova (`nova()`/`vazia()`) e cópia independente (`clone()`/`copyWith()`), conforme já fazem `Serie` e `TipoProcedimento`.
- Exporte novos modelos/DTOs em `core/lib/sei_core.dart`.
- Ao usar DTOs/modelos do `core` fora do pacote, importe `package:sei_core/sei_core.dart` explicitamente quando o barrel local nao exportar esses tipos.
- Prefira modelos/DTOs tipados em assinaturas de services, repositories, controllers e paginas.
- Evite expor `Map<String, dynamic>` como contrato entre camadas quando for possivel criar ou reaproveitar um modelo/DTO.
- Use `Map<String, dynamic>` apenas nas bordas onde ele e inevitavel, como parsing de JSON, serializacao, SQL bruto ou snapshots genericos de auditoria.
- Evite `List<dynamic>.from`; prefira listas tipadas, factories `fromMap` e conversoes centralizadas dentro dos DTOs.

- O sistema é orientado a objetos: repository retorna DTO/model, controller serializa com `toMap()` e o frontend reconstrói com `fromMap()`.
- DTOs/models usados por binding ou estado mutável da UI podem ter campos mutáveis; não force value objects `const` quando a tela precisa atualizar a instância.

### Reuso e parsing

- Antes de criar helper de parsing, conversão, formatação ou validação, procure nesta ordem: `package:essential_core`, `SaliCoreUtils` em `core/lib/src/utils/core_utils.dart` e utilitários compartilhados do backend/frontend.
- Use `SaliCoreUtils.parseInt`, `parseBool` e `parseDouble` somente para origens ambíguas. Linhas do PostgreSQL já chegam tipadas; nelas, use o valor diretamente ou apenas o cast estreito exigido pelo analyzer, sem converter novamente.
- Utilitário genérico novo e reutilizável deve ficar em `SaliCoreUtils` ou no utilitário compartilhado adequado, nunca repetido como função privada.

### Dart

- Rode `dart format` nos arquivos Dart alterados.
- Use tipos explicitos em APIs publicas, services, repositories, controllers, DTOs e view models.
- Prefira `final` para variaveis que nao mudam.
- Evite `dynamic` fora de bordas inevitaveis como JSON, SQL cru e interoperabilidade com DOM/biblioteca externa.

- Trate `null` de forma explicita. Evite `!` quando houver caminho claro para validar ou retornar erro.
- Para enums vindos de banco/API, crie helpers `fromValue`/`fromName` com fallback controlado e erro claro quando o valor for invalido.
- Comentarios DartDoc (`///`) devem explicar contrato, regra de negocio, invariantes ou efeito colateral publico. Nao documente obviedades.
- Classes e metodos novos de dominio, services e controllers devem receber DartDoc sucinto quando forem parte de fluxo importante ou reutilizavel.

## Backend Dart e acesso a dados

- As consultas do backend (`query.get()`, `first()`, `select()`) já retornam `Map<String, dynamic>` com valores nos tipos Dart correspondentes ao banco, como `String`, `bool`, `int`, `double` e `DateTime`.

- Não faça cópias defensivas desnecessárias como:

```dart
final rows = (await query.get())
    .map((row) => Map<String, dynamic>.from(row))
    .toList();
```

- Use diretamente:

```dart
final rows = await query.get();
```

- Parsing/mapeamento de linha de banco para objeto de domínio deve ficar no model ou DTO, por exemplo `MeuModel.fromMap(row)` ou uma factory específica como `MeuModel.fromConsultaXRow(row)`.
- Repositórios devem montar a query, aplicar filtros/regras de consulta e chamar factories dos models/DTOs. Evite blocos grandes de `items.add(Model(... row['campo'] ...))` dentro do repositório quando o mapeamento pertence ao contrato de dados.
- Só use `Map<String, dynamic>.from(...)` quando houver motivo técnico explícito, como converter um mapa não tipado vindo de JSON externo ou proteger uma estrutura imutável antes de mutação. Não use isso como padrão para resultado de query interna.
- Não materialize iteráveis com `.toList()` quando a API consumidora aceita `Iterable` ou quando o resultado será usado apenas em `whereIn`, `join`, `isEmpty`, `toSet` ou `join(',')`. Use `List` somente quando a ordem/materialização concreta for parte do contrato ou quando a coleção será indexada/mutada.
- Em métodos internos ou públicos com argumentos obrigatórios, prefira parâmetros posicionais obrigatórios. Reserve parâmetros nomeados para opções, contexto e dependências opcionais, como `{Connection? connection}`.
- DTOs/models usados por tela, binding AngularDart ou estado mutável não devem ser modelados como value objects imutáveis com campos `final` e construtor `const`. Use campos mutáveis quando a instância puder ser atualizada pela UI ou por um fluxo de estado, evitando cópias só para alterar um valor.
- Parse de filtros é responsabilidade do model de filtro. Não espalhe helpers em repositórios/controladores para interpretar `additionalFilters`, booleanos textuais ou valores como `'arvore'`, `'setor_arvore'`, `'entrada'` e `'saida'`. Quando o filtro tiver significado de negócio, crie propriedade tipada em `SaliFilters` e, quando houver conjunto fechado de valores, use enum com `.value`, `fromString` e getters semânticos.
- Evite strings mágicas para chaves de filtros, opções de enum, nomes de status e modos de tela. Use constantes como `SaliFilters.k...` e enums/constantes do model correspondente. `additionalFilters` deve ser fallback para filtros realmente dinâmicos ou compatibilidade, não o contrato principal de filtros conhecidos.

### Camadas: SQL só em repository, nunca em service/controller/worker

- **Toda execução de query pertence à camada repository.** `conn.select(...)`, `conn.statement(...)`, `conn.table(...)`, `insertGetId`, `update`, `delete` e SQL literal **não podem aparecer** em service, controller, handler de fila, worker, componente ou página. Foi para isso que a camada de repositório existe.
- Service orquestra regra de negócio, transação e efeitos; ele **chama métodos de repository** e recebe model/DTO tipado. Controller cuida só de transporte HTTP.
- **Se não existir repository adequado para a consulta, crie um** (ou acrescente o método ao repositório da entidade dona daquele dado). Não resolva "só desta vez" com SQL embutido no service — é assim que a regra de acesso a dados se espalha e deixa de ser auditável.
- O repository recebe `Connection` no construtor e aceita `{Connection? connection}` por método, para participar da transação aberta pelo service.
- O retorno do repository é model/DTO tipado. Quando a consulta é específica de um fluxo e não é compartilhada com frontend/core, o DTO pode ser uma classe pública no próprio arquivo do repositório; `Map<String, dynamic>` fica restrito à fronteira do driver.
- Vale igualmente para transação: quem abre `conn.transaction((ctx) async { ... })` é o service, mas cada operação dentro dela é uma chamada de repository com `connection: ctx`.

### Tabelas, colunas e aliases

- Models e DTOs devem centralizar constantes de tabela e coluna usadas por queries: `tableName`, `fqtn`, `idCol`, `idFqCol`, `codProcessoCol`, `codProcessoFqCol`, e equivalentes necessários.
- Repositórios não devem espalhar strings mágicas como `'sw_andamento.cod_processo'`, `'d.id'`, `'anexo.data_cadastro'` ou aliases curtos em `where`, `join`, `selectRaw`, `count` e `orderByRaw`. Use as constantes do model/DTO.
- **Evite alias ao máximo.** Enquanto a tabela aparecer uma única vez na query, não use alias nenhum: `conn.table(Model.fqtn)` e colunas por `Model.campoFqCol` resolvem. Alias é exceção, não estilo.
- Alias só é aceitável quando **não há jeito**: autojoin, a mesma tabela lida mais de uma vez, ou `joinRaw`/`selectRaw` em que a expressão exige um rótulo curto. Nesse caso o alias é descritivo e declarado como constante, por exemplo `aliasPessoaAndamento = 'pessoa_andamento'`, nunca `a`, `d`, `x` ou nomes soltos no repositório.
- **Armadilha do eloquent ao usar alias**: em `from()`/`join()`/`leftJoin()` o alias precisa da forma **`'<tabela> as <alias>'`**. Sem o `as`, o builder trata a string inteira como nome de tabela e o PostgreSQL responde `42P01: não existe a relação "public.sw_processo p"`. Isso não aparece no `dart analyze` — só em teste de integração ou em produção. Em `joinRaw`/`whereRaw`/`selectRaw`, que são SQL literal, o alias sem `as` funciona normalmente.
- DTOs que representam uma consulta específica devem definir as chaves de saída consumidas por suas factories, por exemplo `dataEventoCol`, `usuarioNomeCol` e `tipoDocumentoCol`. O `selectRaw` deve emitir esses mesmos nomes e a factory deve ler pelas constantes.
- Continue preferindo constructors/factories de models e DTOs no retorno da repository. `Map<String, dynamic>` deve ficar restrito à fronteira do driver/query ou a payloads realmente dinâmicos.

## Banco de dados e migrations

### Nomenclatura: schema, tabela e coluna sempre em português

- **Todo objeto novo de banco — schema, tabela, coluna, índice, constraint — usa nome em português**, sem exceção: `data_cadastro`, `data_atualizacao`, `tentativas`, `ultimo_erro`, `prioridade`, `fila`, `tipo`, `motivo`, `ativo`, `status`. **Proibido** criar `created_at`, `updated_at`, `expires_at`, `job`, `queue_name`, `payload_json`, `max_attempts`, `locked_by` e equivalentes.
- Valores de domínio fechado (status, tipo, modo) também em português e em MAIÚSCULAS, como já ocorre em `processo_lembrete` e `processo_digital_economia_recalculo_pendente`: `PENDENTE`, `PROCESSANDO`, `CONCLUIDO`, `ERRO`, `CANCELADO`. Nunca `pending`/`processing`/`failed`.
- Convenções vigentes a seguir: data de criação = `data_cadastro`; data de alteração = `data_atualizacao`; chave estrangeira = `id_<entidade>` (`id_processo`, `id_organograma`); marcações pontuais de evento aceitam o sufixo `_em` (`processado_em`, `cancelado_em`) quando já houver irmãs assim na mesma tabela.
- **Nomes em inglês que existem hoje no schema (`created_at`, `updated_at`, `expires_at`, `signed_at`, `valid_from`/`valid_to`, `page_count`, `fisical_filename` e afins) são erro herdado, não convenção.** Serão renomeados para português no futuro. Não os use como referência ao criar tabela nova e não os replique "por consistência com a tabela vizinha".
- Roteiro/documento de `backend/doc` também segue esta regra: exemplo de DDL com coluna em inglês é defeito do documento e deve ser corrigido antes de virar migration.

### Comentários obrigatórios em tabela e coluna

- Toda tabela nova recebe `COMMENT ON TABLE` explicando **para que serve** e, quando não for óbvio, qual o ciclo de vida da linha. Schema novo recebe `COMMENT ON SCHEMA`.
- Toda coluna nova recebe `COMMENT ON COLUMN` explicando o que armazena. Para coluna de domínio fechado, liste os valores possíveis e o significado de cada um; para coluna de data, diga que evento ela marca; para chave estrangeira ou identificador externo, diga o que ela referencia.
- O comentário descreve a **intenção de negócio**, não o tipo: `'Momento a partir do qual o trabalho pode ser reservado'` é útil; `'timestamp'` ou `'campo data_disponivel'` é ruído.
- Os comentários fazem parte da migration e entram no mesmo commit; o `schema_sali.sql` do CI já preserva `COMMENT ON` no dump, então divergência entre migration e schema de CI é erro a corrigir.
- Vale igualmente para coluna adicionada por `ALTER TABLE` em tabela legada: comente a coluna nova (não é obrigatório comentar as antigas no mesmo commit, mas é bem-vindo quando o significado for conhecido).

### Chave primária: sempre sequence, nunca IDENTITY

- **Proibido `GENERATED ALWAYS AS IDENTITY` (e `GENERATED BY DEFAULT AS IDENTITY`)** em qualquer tabela do SALI. Use **sequence**: `bigserial`/`serial` na criação, ou `bigint NOT NULL DEFAULT nextval('<sequence>')` quando a sequence precisar ser explícita.
- Motivo: o schema inteiro do SALI usa sequences; o driver, os `insertGetId`, os `setval` dos seeds de CI (`sincronizar_sequences_ci.sql`) e os scripts de manutenção presumem uma sequence nomeada e manipulável. Coluna IDENTITY quebra esse ferramental e obriga `OVERRIDING SYSTEM VALUE` em carga de dados.
- O mesmo vale para exemplo de DDL em roteiro de `backend/doc`: DDL com IDENTITY é defeito do documento e deve ser corrigido antes de virar migration.

### Tipos e evolução

- Nunca crie campos novos como `timestamp with time zone` ou `timestamptz` em migrations, roteiros SQL ou exemplos de DDL do SALI.
- Use obrigatoriamente `timestamp without time zone` para campos de data/hora.
- `DEFAULT now()` é aceito quando a coluna de destino é `timestamp without time zone` e o banco/sessão está com `TimeZone = America/Sao_Paulo`; o PostgreSQL grava o valor local sem fuso nessa coluna. Confirme com `SHOW TimeZone;` ao preparar migration para outro ambiente.
- `LOCALTIMESTAMP` também pode ser usado para deixar a intenção explícita, mas a regra obrigatória é o tipo da coluna permanecer sem fuso.
- Migrations devem preservar dados existentes: prefira `ALTER TABLE`, `RENAME`, `ALTER COLUMN TYPE ... USING` e backfill validável. Não recrie tabela histórica com dados sem plano explícito de cópia e conferência.

- **Este projeto ainda não tem pasta de migrations numeradas nem `schema_sali.sql`/`seed_sali_ci*.sql`** — essas referências também são herança do template `new_sali` (que está na versão 6.3.0) e não existem aqui (`backend/scripts/` hoje só tem `restaurar_sei_5_0_0_postgresql.ps1`). Tabela nova que o próprio projeto SEI cria (não faz parte do schema real do SEI/SIP restaurado) deve ganhar uma migration em `backend/scripts/migrations/`, numerada sequencialmente (ex. `0001_...sql`); crie a pasta se for a primeira. Nunca altere estruturalmente uma tabela que pertence ao schema real do SEI/SIP (as que aparecem em `\d` contra `sei_5_0_0`/`sip_5_0_0`) — isso quebraria a comparabilidade com instalações reais do SEI.

### Performance de consultas

- **Antes de adicionar qualquer `JOIN`, subquery correlacionada ou agregação (`COUNT`/`SUM`/`DISTINCT`) a uma query de listagem, verifique o TAMANHO das tabelas envolvidas.** Tabelas transacionais do SALI são **gigantes em produção** mesmo quando dev/CI tem poucas linhas: `sw_assunto_atributo_valor`, `sw_andamento`, `sw_processo`, `sw_processo_anexos`, `organograma_historico`, `administracao.auditoria`, entre outras. Nunca avalie o custo só pelo tempo no seed local — raciocine sobre o volume de produção. Uma query que passa rápido no seed **não prova que escala**.
- **Proibido**: subquery correlacionada (executada **por linha** do resultado) que varra uma tabela grande só para exibir contagem/uso. O custo é `N linhas × varredura da tabela grande` — e como o padrão `all()` do projeto chama `query.count()` **e** `query.get()`, a subquery ainda roda **duas vezes** por request.
- **Regressão real (6.2.0)**: a listagem de Atributo de Assunto (`AtributoProtocoloRepository.all`) ganhou `COUNT(DISTINCT (exercicio, cod_processo))` correlacionado sobre `sw_assunto_atributo_valor` só para mostrar "quantos processos usam o atributo" → **6-7s com apenas 4 atributos** (e travava também Alterar Assunto, que carrega o mesmo endpoint). Corrigido removendo a subquery. Protegido por `backend/test/integration/atributo_protocolo_listagem_test.dart`.
- **Regra de decisão — onde a checagem "está em uso" pertence**: a validação de uso (bloquear troca de tipo, impedir exclusão de item referenciado, etc.) é feita **no momento de salvar/excluir**, onde o backend valida com **uma** query barata sobre a chave. **Não** é feita na listagem. Listagem deve ser `SELECT colunas FROM tabela` + filtros + paginação, e nada mais.
- **Se realmente precisar de um dado agregado numa listagem**, em ordem de preferência: (1) só quando a tabela é comprovadamente pequena/limitada; (2) `EXISTS (...)` quando o dado é booleano (curto-circuita no primeiro match, não varre tudo como `COUNT(DISTINCT ...)`); (3) contador materializado mantido na escrita; (4) buscar sob demanda apenas para o **item selecionado** (1 query barata), nunca para a página inteira.
- Antes de confiar em `EXISTS`/`JOIN`, confirme que existe **índice** na coluna de junção/filtro. Sem índice, mesmo `EXISTS` pode varrer a tabela.

### Criação de índices

- Antes de propor/criar um índice, **consulte a base de dados local** para: (1) ver se um índice equivalente **já existe** (`SELECT indexname, indexdef FROM pg_indexes WHERE tablename = '...'`); (2) medir o **tamanho da tabela** (`SELECT count(*) ...`); (3) validar o **plano** com `EXPLAIN (ANALYZE, BUFFERS)` antes e depois, confirmando index-only scan / ausência de sort; (4) **avaliar o impacto na escrita**, principalmente no **cadastro de processo** e outros fluxos de INSERT quentes — um índice a mais é mantido a cada insert.
- Conexão local (do `backend/.env`): `db_name=sei_5_0_0`, `db_host=localhost`, `db_port=5432`, `db_user=dart`, `db_pass=dart`. Ex.: `PGPASSWORD=dart psql -U dart -h localhost -p 5432 -d sei_5_0_0 -c "..."`. A base SIP é separada: `sip_5_0_0`, mesmo usuário e senha.
- Prefira o índice **mais estreito que resolve** e que **cobre** a query (index-only scan). Para tabelas grandes em produção, crie com `CREATE INDEX CONCURRENTLY IF NOT EXISTS` (fora de transação) para **não bloquear** gravações durante o build.

- Caso real (6.2.0): a rota de uso de atributo filtra `sw_assunto_atributo_valor` (~1M linhas) por `cod_atributo`, que era a 3ª coluna da PK → seq scan. Como para bloquear a troca de tipo **basta saber se é usado ao menos uma vez** (`EXISTS`, não `COUNT`), o índice de **coluna única** `(cod_atributo)` já deixa o EXISTS instantâneo — inclusive para o atributo **não usado** (index lookup não acha nada, sem varrer 1M linhas) — com impacto desprezível no cadastro. Migration `15_acao_rota_atributo_protocolo_uso_e_index.sql`.

### Autorização de rotas

- **Este projeto não tem `acao_rota`.** Esse mecanismo é de outro projeto
  (template `new_sali`) e nunca existiu no schema do SEI/SIP — não crie essa
  tabela nem se refira a ela.
- O modelo real de autorização do SEI é o do SIP, já investigado e
  implementado: `permissao` (concede `perfil` a `usuario`×`unidade`×`sistema`
  com janela `dta_inicio`/`dta_fim`) → `perfil` → `rel_perfil_recurso` → `recurso`
  (`recurso.caminho` guarda o identificador funcional da tela/ação, herdado do
  SEI em PHP, ex. `controlador.php?acao=sistema_cadastrar`). Ver
  `SipReferenciaRepository.resolverAutorizacao` e `AutorizacaoUsuario` em
  `core/lib/src/models/autorizacao_usuario.dart`, e o achado completo em
  `backend/docs/evidencias_processo_detalhe.md` (seção "SIP — autorização por
  recurso").
- Autenticação é separada de autorização: login local valida
  `sei_5_0_0.usuario.senha` (hash bcrypt); LDAP/AD é integração opcional por
  órgão via `servidor_autenticacao`/`rel_orgao_autenticacao`. Nenhum dos dois
  usa `acao_rota`.
- Rota nova que precisa checar permissão deve consultar `recurso.caminho`
  (ou o identificador equivalente já resolvido por
  `resolverAutorizacao`) contra os recursos liberados do usuário/unidade —
  nunca inventar coluna, tabela ou convenção de código de ação que não tenha
  sido confirmada por `\d` direto no banco ou por cross-tab no dump
  histórico.

## CGM

- Funcionalidades de CGM devem ficar no modulo CGM quando houver acao/menu/permissao correspondente.
- Para itens de menu, `administracao.acao.tipo` deve seguir o padrao do sistema para acao de menu.
- Rotas do frontend devem mapear a acao correspondente em `RoutePaths`.

## AngularDart: documentação e arquitetura

- Consulte a documentacao local de AngularDart em `C:\MyDartProjects\limitless_ui\site_ngdart` quando a tarefa envolver template, componente, DI, forms, styles, lifecycle, router ou testes. Paginas mais uteis:
  - `guide/architecture.html`
  - `guide/template-syntax.html`
  - `guide/forms.html`
  - `guide/dependency-injection.html`
  - `guide/component-styles.html`
  - `guide/lifecycle-hooks.html`
  - `guide/server-communication.html`
  - `guide/testing/component/basics.html`
  - `cheatsheet/index.html`
- Componentes AngularDart devem controlar a view e coordenar interacao. Logica de negocio, acesso HTTP, validacao complexa, cache, conversao de dados e efeitos externos devem ficar em services, repositories, models ou view models.
- Mantenha componentes enxutos: o template consome estado pronto; o componente orquestra eventos; services fazem trabalho reutilizavel.
- Sempre declare no `@Component` apenas as `directives` e `pipes` usadas pelo template. Ao usar componentes do `limitless_ui`, importe `package:limitless_ui/limitless_ui.dart` com alias `as li` e declare explicitamente o componente/diretiva usado.
- Prefira `templateUrl` e `styleUrls` com arquivos ao lado do componente (`*_component.dart`, `*_component.html`, `*_component.scss/css`).
- Ao criar um componente com `@Input()` e `@Output()`, trate esses membros como contrato publico. Use tipos fortes e streams tipadas, por exemplo `Stream<TramiteProcesso>`, nao `Stream<dynamic>`.
- `@Input()` deve receber dados prontos ou view models; evite passar mapas crus para templates.
- `@Output()` deve emitir eventos de intencao da UI, nao executar regra de negocio dentro do filho quando a decisao pertence ao pai.

### Estrutura de pastas: uma pasta por componente, uma pasta por página

- `sei/frontend` segue a estrutura de pastas e o padrão de SCSS já comprovados em `C:\MyDartProjects\new_sali\frontend`. Não invente organização própria; ao ter dúvida, inspecione o projeto de referência diretamente.
- Dentro de `lib/src/modules/<modulo>/`: `components/` para peça reutilizável, `pages/` para container de rota. `models/` e `services/` de módulo são exceção, só para estado de tela que não cruza pacote — DTO compartilhado com `backend`/`core` vai em `core/lib/src/models`.
- **Cada componente e cada página moram na própria subpasta — nunca soltos direto em `components/` ou `pages/`.** Confirmado em `new_sali/frontend/lib/src/modules/protocolo/components/processo_header/` (contém `processo_header_component.dart` + `.html` + `.scss`, os três juntos na subpasta) e em `.../pages/visualiza_processo/`, que também aninha `components/<subseção>/` própria para as seções da página, por exemplo `pages/visualiza_processo/components/interessados/interessados_section_component.dart`.
- **Nome da pasta = prefixo do arquivo.** Uma pasta de página `<nome>/` contém `<nome>_page.dart` + `.html` + `.scss` (ver `pages/home/home_page.*`, `pages/main_page/main_page.*`, `pages/visualiza_cgm/visualiza_cgm_page.*`). Uma pasta de componente `<nome>/` contém `<nome>_component.dart` + `.html` + `.scss`. Arquivo auxiliar que só serve àquela página/componente (helper de formulário, serviço local) fica dentro da mesma pasta, sem o sufixo `_page`/`_component` — ver `pages/visualiza_cgm/cgm_form_select_options.dart`.
- **Nunca** crie `components/<nome>_component.dart` (ou `pages/<nome>_page.dart`) direto na raiz de `components/`/`pages/`, com os irmãos `.html`/`.scss` soltos ao lado — isso já aconteceu por engano nesta base (módulos `catalogos`, `contexto_desenvolvimento`, `controle_processos`) e deve ser corrigido para a subpasta própria sempre que for tocado.
- Estilo: entrada única `web/style.scss`, com `@use '<parcial>' as *;` por tema (ver `new_sali/frontend/web/style.scss`), não uma folha CSS por componente solta na raiz do módulo.

### Composição de páginas grandes

Página de rota deve ser container, não dona de toda regra visual. Para telas grandes:

- a página lê rota, carrega o processo base e conecta eventos globais;
- cada aba carrega seus dados locais quando isso reduz acoplamento;
- componentes de aba possuem filtros, paginação, loading, colapsos e listas cacheadas;
- serviços/facades cuidam de URL, autorização, impressão, PDF e seleção quando a regra é compartilhada;
- view models carregam labels, ícones, classes CSS e flags prontas para o template.

Sinal de alerta: se a página possui estado de árvore, timeline, preview, modais, PDF, autorização e filtros ao mesmo tempo, extraia um componente ou serviço. A meta é que cada componente tenha uma razão clara para mudar.

## AngularDart: templates e change detection

Estas regras foram consolidadas da documentação local do ngdart 8 e das seguintes fontes do runtime:

- `package:ngdart/angular.dart`
- `src/meta/lifecycle_hooks.dart`
- `src/meta/change_detection_constants.dart`
- `src/meta/directives.dart`
- `src/runtime/check_binding.dart`
- `src/core/linker/views/view.dart`
- `src/core/linker/views/component_view.dart`
- `src/core/linker/views/host_view.dart`
- `src/core/linker/view_ref.dart`
- `src/core/zone/ng_zone.dart`

### Regra central: binding deve ser estável

Em modo dev, o ngdart executa uma verificação extra para garantir que uma expressão de template não mudou durante o mesmo ciclo de change detection. O erro:

```text
An expression bound in an AngularDart template returned a different value the second time it was evaluated.
Expression has changed after it was checked.
```

acontece quando o valor de uma expressão muda entre a primeira avaliação e a verificação de estabilidade do mesmo ciclo.

Evite no template qualquer expressão que possa mudar enquanto a view está sendo criada, medida, projetada ou atualizada:

```html
<!-- Evitar -->
<processo-header [canPrintSelectedAnexo]="timelineTab?.canPrintSelectedAnexo == true">
</processo-header>
```

Use campos estáveis atualizados por eventos explícitos:

```dart
bool canPrintSelectedAnexo = false;

void showAnexo(ProcessoAnexo anexo) {
  isShowAnexo = true;
  canPrintSelectedAnexo = true;
  canPrintSelectedDespacho = false;
}
```

```html
<processo-header [canPrintSelectedAnexo]="canPrintSelectedAnexo">
</processo-header>
```

### Não chame métodos no template para cálculo

Métodos chamados por binding são reexecutados a cada ciclo. Isso pesa e pode retornar outro valor sem intenção.

Evite:

```html
<button [disabled]="calcularDisabled(item)">
  {{ labelDinamico(item) }}
</button>
```

Prefira preparar view models ou campos:

```dart
class ProcessoActionVm {
  final String label;
  final bool disabled;
  const ProcessoActionVm({required this.label, required this.disabled});
}
```

```html
<button [disabled]="action.disabled">
  {{ action.label }}
</button>
```

Para listas grandes, não use getters que criam lista:

```dart
// Evitar em binding/*ngFor
List<Item> get itensVisiveis => itens.where((i) => i.visible).toList();
```

Use campo cacheado:

```dart
List<Item> itensVisiveis = const [];

void rebuildItensVisiveis() {
  itensVisiveis = itens.where((i) => i.visible).toList();
}
```

- Expresse bindings com leitura de campos, safe navigation (`?.`), comparações simples, booleanos preparados e pipes leves.
- Use métodos no template somente em event bindings de ação do usuário.
- Nunca escreva múltiplos statements separados por `;` em um event binding. Passe `$event` para um método do componente e chame `preventDefault()`/`stopPropagation()` dentro dele.
- Use `*ngIf` com estado estável e para proteger nulos; não use `!` para esconder falhas do ciclo de carregamento.
- Use pipes apenas para transformações pequenas e declarativas; o pipe `json` é permitido somente durante depuração e deve ser removido.
- Opções de dropdown e outras coleções de template devem ser constantes ou campos estáveis, nunca getters que criam objetos a cada ciclo.

## AngularDart: lifecycle, zona e OnPush

### Lifecycle correto no ngdart 8

A ordem documentada no pacote é:

1. `ngAfterChanges`
2. `ngOnInit`
3. `ngDoCheck`
4. `ngAfterContentInit`
5. `ngAfterContentChecked`
6. `ngAfterViewInit`
7. `ngAfterViewChecked`
8. `ngOnDestroy`

No ngdart 8, use `AfterChanges`, não `OnChanges`.

```dart
class MeuComponente implements AfterChanges, OnDestroy {
  @Input()
  Processo processo = Processo.invalido();

  String? _lastKey;

  @override
  void ngAfterChanges() {
    final key = '${processo.codProcesso}/${processo.anoExercicio}';
    if (key == _lastKey || processo.codProcesso <= 0) return;
    _lastKey = key;
    _recarregar();
  }

  @override
  void ngOnDestroy() {}
}
```

Não existe `AfterViewChange`. Os hooks corretos de view são `AfterViewInit` e `AfterViewChecked`.

### `AfterChanges` é para reagir a `@Input`

Use `ngAfterChanges()` quando o componente depende de `@Input()` e precisa recarregar estado ao receber novo processo, filtro, id ou seleção.

### Cuidado com `DoCheck`

`DoCheck` roda em toda checagem e substitui o detector padrão para inputs mutáveis. A própria documentação avisa:

- não dispare evento assíncrono em `ngDoCheck`;
- não implemente `DoCheck` junto com `AfterChanges`, porque `ngAfterChanges()` não será chamado.

No SALI, use `DoCheck` só para diretivas muito específicas e com justificativa clara. Para componentes de tela, prefira inputs imutáveis, campos cacheados e `AfterChanges`.

### `ViewChild` e `ViewChildren`

`ViewChild` e `ViewChildren` são preenchidos antes de `ngAfterViewInit()` e podem ser atualizados antes de `ngAfterViewChecked()`.

Não use `@ViewChild` diretamente em binding de template do pai, porque a criação do filho pode mudar o valor no mesmo ciclo.

Evite:

```dart
@ViewChild('timeline')
ProcessoTimelineTabComponent? timeline;

bool get canPrint => timeline?.canPrintSelectedAnexo == true;
```

```html
<processo-header [canPrint]="canPrint"></processo-header>
```

Prefira:

- o componente filho emitir estado por `@Output`;
- ou o pai atualizar campos estáveis nos handlers que selecionam item;
- ou o filho receber toda a responsabilidade da ação.

Para ser notificado quando uma query muda, prefira setter:

```dart
@ViewChildren('item')
set itemElements(List<html.Element> value) {
  _itemElements = value;
}
```

### Atualizações depois da renderização

Quando for necessário executar algo depois de uma alteração observada pelo Angular, prefira `NgZone.runAfterChangesObserved()` em vez de `Timer.run`, `Future` ou `scheduleMicrotask`.

```dart
class MeuComponente {
  final NgZone _zone;

  MeuComponente(this._zone);

  void selecionar() {
    selecionado = true;
    _zone.runAfterChangesObserved(() {
      _scrollParaSelecionado();
    });
  }
}
```

Use `Timer(Duration.zero, ...)` apenas quando já for padrão local ou quando não houver `NgZone` disponível. Cancele timers no `ngOnDestroy()`.

### Callbacks nativos do browser e redraw

Eventos declarados no template AngularDart passam pelo ciclo do framework, mas callbacks nativos criados diretamente via APIs do browser não entram automaticamente na zona do Angular. Isso inclui `IntersectionObserver`, `MutationObserver`, `ResizeObserver`, listeners adicionados manualmente em `dart:html` e callbacks de bibliotecas JavaScript.

Quando um callback nativo altera estado usado no template, execute a mutação dentro de `NgZone.run(...)` e marque a view para verificação ao concluir cargas assíncronas:

```dart
class MeuComponente implements AfterViewInit, OnDestroy {
  final NgZone _ngZone;
  final ChangeDetectorRef _changeDetectorRef;
  html.IntersectionObserver? _observer;

  MeuComponente(this._ngZone, this._changeDetectorRef);

  @override
  void ngAfterViewInit() {
    _observer = html.IntersectionObserver((entries, observer) {
      if (entries.any((entry) => entry.isIntersecting)) {
        _ngZone.run(() {
          carregarDadosLazy();
        });
      }
    });
  }

  Future<void> carregarDadosLazy() async {
    try {
      itens = await service.carregar();
    } finally {
      _changeDetectorRef.markForCheck();
    }
  }

  @override
  void ngOnDestroy() {
    _observer?.disconnect();
  }
}
```

Não tente corrigir esse tipo de falha com clique artificial, `overflow-x: hidden`, `Timer.run` aleatório ou redraw indireto. O sintoma típico é: a requisição XHR termina e os dados aparecem no estado/log, mas a tela só atualiza depois de um clique, tecla ou outro evento Angular.

Para mudanças assim, adicione teste de UI que reproduza o evento real sem clique manual. Em testes Puppeteer contra `webdev`, espere a aplicação renderizar a tela de login ou outro marcador real antes de autenticar; a porta HTTP pode responder enquanto o bundle ainda está compilando.

### `OnPush` com cuidado

`ChangeDetectionStrategy.onPush` só verifica o componente quando:

- um `@Input()` muda de identidade;
- um `@Output()` ou evento de template roda no componente ou descendente;
- `ChangeDetectorRef.markForCheck()` é chamado no componente ou descendente.

Use `OnPush` apenas quando:

- inputs são tratados como imutáveis;
- listas são substituídas por nova instância quando mudam;
- callbacks assíncronos chamam `markForCheck()` quando necessário;
- não há filho `checkAlways` dependente de update implícito sob um pai `onPush`.

Não aplique `OnPush` em telas grandes sem antes extrair componentes menores e stores explícitas.

- Cancele `Timer`, `StreamSubscription`, debounce e observers no `ngOnDestroy()`; não mantenha subscriptions anônimas.

### Inputs, outputs e formulários

#### Outputs

Para `@Output`, use `StreamController.broadcast()` quando o evento pode ter múltiplos ouvintes ou seguir padrão dos componentes do projeto.

Sempre feche no `ngOnDestroy()`:

```dart
final _abrirCtrl = StreamController<TramiteProcesso>.broadcast();

@Output()
Stream<TramiteProcesso> get abrir => _abrirCtrl.stream;

@override
void ngOnDestroy() {
  _abrirCtrl.close();
}
```

#### Formulários

- Importe e declare `formDirectives` quando o template usar `ngModel`, `ngControl`, `ngForm` ou `ngSubmit`.
- Use `[(ngModel)]` para formularios simples quando o projeto ja usa esse padrao.
- Para submit, prefira `<form (ngSubmit)="onSubmit()" #formRef="ngForm">` e botao `type="submit"`.
- Desabilite confirmacao/submissao com estado de formulario (`formRef.form.valid`, campos obrigatorios, flags de loading), nao com validacao duplicada apenas no clique.
- Mostre erro de validacao com base em estado do controle (`valid`, `pristine`, `dirty`, `touched`) e em campos booleanos estaveis do componente.
- O frontend pode guiar o usuario, mas a regra de negocio obrigatoria deve ser revalidada no backend.

### Rotas e query params transitórios

em páginas AngularDart que implementam `CanReuse`, implemente também `OnInit`; use `ngOnInit()` para inicialização própria do componente. Não confunda isso com fluxo de rota: se a carga inicial depende de `RouterState`, query params ou parâmetros de URL, trate em `onActivate()`, porque `ngOnInit()` não recebe `current.queryParameters`.

- `ngOnInit()` pertence ao ciclo de vida do componente AngularDart. `onActivate(RouterState? previous, RouterState current)` pertence ao ciclo de vida do `ngrouter` e é o lugar correto para ler `current.queryParameters`.
- Quando uma tela recebe um query param transitório de outra tela, por exemplo o card da Home navegando para `despachar-processo?a=59&somenteRascunhos=true`, aplique o filtro em `onActivate()`, remova o parâmetro do mapa local e só então atribua `currentQueryParameters`.
- Para `somenteRascunhos=true`, o comportamento esperado é: ativar `filtros.somenteRascunhos`, remover `somenteRascunhos` de `currentQueryParameters`, zerar `filtros.offset`, chamar `loadProcessos()` e agendar a limpeza visual da URL.
- Não remova o query param da barra imediatamente dentro de `onActivate()` assumindo que o `ngrouter` já terminou a navegação. O `ngrouter` ainda pode estar atualizando a URL nesse momento. Use `Timer.run(() { _removeQueryParameterFromBrowserUrl('somenteRascunhos'); })`.
- A limpeza da barra deve ser feita com `html.window.history.replaceState(...)`, preservando os demais query params e evitando nova navegação.
- Não condicione `loadProcessos()` a `previous == null` quando a tela precisa refletir query params de ativação e retorno de navegação; nesse padrão, `onActivate()` deve carregar após aplicar os filtros da rota.

Padrão esperado:

```dart
@override
void onActivate(RouterState? previous, RouterState current) {
  final queryParameters = Map<String, String>.from(current.queryParameters);

  if (queryParameters.containsKey('somenteRascunhos')) {
    final value = (queryParameters['somenteRascunhos'] ?? '').toLowerCase();
    filtros.somenteRascunhos = value == 'true' ? true : null;
    queryParameters.remove('somenteRascunhos');

    Timer.run(() {
      _removeQueryParameterFromBrowserUrl('somenteRascunhos');
    });
  }

  currentQueryParameters = queryParameters;
  filtros.offset = 0;
  loadProcessos();
  _agendarAssinaturaDireta();
}

void _removeQueryParameterFromBrowserUrl(String key) {
  final uri = Uri.parse(html.window.location.href);
  final nextParams = Map<String, String>.from(uri.queryParameters)
    ..remove(key);

  final nextUri = uri.replace(
    query: nextParams.isEmpty ? '' : Uri(queryParameters: nextParams).query,
  );

  html.window.history.replaceState(
    null,
    html.document.title,
    nextUri.toString(),
  );
}
```

## AngularDart: assincronismo e loading

- `SimpleLoading` (`frontend/lib/src/shared/components/loading/loading.dart`) é criado **por operação de carga**, no mesmo escopo do par `show`/`hide`: `final loading = SimpleLoading();` dentro do método, `show()` antes do `await`, `hide()` no `finally`. **Nunca** como campo de classe ("instância de tela") — esse é o uso errado.
- Motivo: `show()` troca `_root` por uma div nova e `hide()` remove só o `_root` **atual**. Dois `show()` na mesma instância abandonam a div anterior no DOM — `z-index: 500000`, cobrindo a tela toda — e ela fica lá para sempre engolindo todo clique: a tela parece viva e não responde a nada.
- **Não** conserte isso chamando `hide()` no início do `show()`. Torna o `show()` idempotente, mas mascara o mau uso em vez de deixá-lo aparecer; a correção é o escopo da instância.
- Contraste: `TargetAlert` (`frontend/lib/src/shared/components/target_alert/target_alert.dart`) **foi** projetado para viver como estado da tela e ser reusado entre cargas; o `SimpleLoading` não. O contrato está escrito no dartdoc do próprio `TargetAlert`.
- Exceção conhecida: `frontend/lib/src/shared/components/datatable/datatable_component.dart` mantém um campo porque expõe `showLoading()`/`hideLoading()` como API pública para as páginas que embutem o datatable. Fora esse caso, campo do tipo `SimpleLoading` é bug.

- Evite respostas antigas sobrescrevendo estado novo. Em buscas/filtros com risco de retorno fora de ordem, use um contador de requisição e descarte resultados obsoletos:

```dart
int _requestSeq = 0;

Future<void> loadItens({bool forceReload = false}) async {
  final requestId = ++_requestSeq;
  final data = await service.all(filtros);
  if (requestId != _requestSeq) return;
  dataFrame = data;
}
```

## AngularDart: buscas, datatables e coleções

### Buscas remotas e filtros seletivos

Em telas com paginação remota, lazy loading, timeline, árvore, datatable ou processo com muitos itens, a busca deve ser seletiva e previsível.

Evite expor **Todos os campos** quando o backend não tiver índice full-text específico para isso. Esse tipo de busca normalmente vira uma combinação de múltiplos `OR`, concatenações, `ILIKE`, `unaccent` e casts, reduzindo a seletividade e dificultando uso eficiente de índices.

Prefira sempre:

- um campo de busca explícito por vez;
- opções de campo compatíveis com índices ou colunas bem delimitadas;
- busca por ID usando igualdade, não `LIKE`;
- texto livre disparado por botão de lupa ou Enter;
- `limit` máximo no backend;
- `offset`/cursor controlado pelo componente;
- filtro de período aplicado no servidor;

Exemplo de contrato preferido:

```dart
final filtros = SaliFilters(
  limit: 400,
  offset: 0,
  campoBuscaArvoreProcesso: 'setor',
);

void onCampoBuscaChange(String? value) {
  filtros
    ..campoBuscaArvoreProcesso = value ?? 'setor'
    ..offset = 0;
}

void buscar() {
  filtros
    ..searchString = textoBusca.trim().isEmpty ? null : textoBusca.trim()
    ..offset = 0;
  loadItens(forceReload: true);
}
```

Quando uma opção geral for realmente necessária, ela deve ser outro produto técnico: índice de busca textual, tabela materializada, trigram ou serviço de busca. Não implemente busca geral operacional apenas concatenando vários campos em cada consulta de tela.

### Listas e DataFrame

Para listagens grandes, não mantenha listas paralelas duplicando `DataFrame.items` se não houver transformação real. Use diretamente o `DataFrame<T>` quando a tela é uma listagem comum.

Quando houver transformação de domínio para view model, faça a conversão uma vez por resposta e armazene em campo estável:

```dart
DataFrame<ArvoreProcessoItem> dataFrame = DataFrame.newClear();
List<TramiteProcesso> tramites = const [];

Future<void> load() async {
  dataFrame = await service.getArvoreProcesso(...);
  tramites = dataFrame.items.map(mapper.toTramite).toList();
}
```

Evite no template:

```html
<li *ngFor="let item of dataFrame.items.where(filtro).toList()">
</li>
```

Prepare antes:

```dart
List<TramiteProcesso> itensVisiveis = const [];

void rebuildItensVisiveis() {
  itensVisiveis = tramites.where((item) => item.isVisible).toList();
}
```

Em datatables remotas no SALI:

- mantenha `SaliFilters` como estado direto do componente;
- deixe o evento `(dataRequest)` chamar o método de carga;
- atribua a resposta diretamente ao `DataFrame<T>`;
- não clone filtros sem necessidade;
- não exporte/ordene/filtre localmente uma lista gigante se a tabela é remota.

### Dropdowns

Opções de dropdown devem ser constantes ou campos estáveis. Não crie opções com getter que monta lista nova a cada ciclo.

Prefira:

```dart
static const List<li.LiDropdownMenuOption> campoOptions =
    <li.LiDropdownMenuOption>[
  li.LiDropdownMenuOption(value: 'setor', label: 'Setor'),
  li.LiDropdownMenuOption(value: 'id_despacho', label: 'ID do despacho'),
];
```

Se o componente de UI exige `String`, não faça binding de `String?` sem valor padrão:

```dart
String get campoBuscaValue => filtros.campoBuscaArvoreProcesso ?? 'setor';
```

Ao abrir ou fechar dropdowns, modais e offcanvas, cuidado com eventos síncronos do componente filho. Se o mesmo handler muda estado renderizado no template, agende a abertura/fechamento ou mova a regra para o componente dono do overlay.

## AngularDart: overlays, CSS e layout

- Para overlays, use somente os componentes nativos do `limitless_ui`: `li-modal`, `li-offcanvas`, `li-popover`, `li.SweetAlertPopover`, `li.SweetAlert` e `LiSimpleDialogComponent`.
- Não use os componentes customizados `SimpleDialogComponent.showAlert(...)` nem `SweetAlertSimpleToast` dentro ou por cima de `li-modal`; eles ficam atrás do modal.
- Use `li-popover` para contexto curto; `LiSimpleDialogComponent.showPrompt` para prompt simples; `li-modal` para formulários e fluxos com vários campos; e `SweetAlert` para alertas, confirmações e toasts.
- Popovers devem ser curtos. Sanitize ou escape dados do usuário antes de interpolar HTML; conteúdo jurídico longo, histórico ou revisão pertence a modal, drawer ou aba.
- Feche o modal atual antes de abrir outro modal/overlay ou navegar para outra tela.

- **Gotcha de li-modal e OnPush**: `LiModalComponent` faz `document.body?.append(rootElement)` no `ngOnInit()`, desconectando o modal da árvore de change detection original. Não use `[contentTemplate]` para projetar conteúdo `OnPush` que sofre atualizações assíncronas enquanto o modal está aberto, pois o `markForCheck()` do pai não alcançará a view embutida (causando loaders infinitos). Use `<ng-content>` projetando o conteúdo diretamente dentro de `<li-modal>`. Para conteúdo compartilhado entre modal mobile e inline desktop, use instâncias separadas com `*ngIf`.

### Colapso e foco

- A diretiva `liCollapse` anima a altura do próprio elemento que recebe `[liCollapse]`. Se esse elemento tiver `padding`, a animação pode parecer fechar em múltiplos passos: primeiro encolhe o conteúdo, depois ainda sobra o padding até chegar em `height: 0`.
- Para evitar esse efeito, deixe o elemento com `[liCollapse]` sem padding e mova o espaçamento para um wrapper interno:

```html
<div [liCollapse]="item.colapsado" class="collapse-body">
  <div class="collapse-body-inner">
    ...
  </div>
</div>
```

```scss
.collapse-body {
  padding: 0;
}

.collapse-body-inner {
  padding: 0.45rem 0.5rem 0.55rem;
}
```

- Esse padrão foi aplicado na árvore de processo: `.arvore-sector-body` ficou como elemento animado sem padding, e `.arvore-sector-body-inner` passou a carregar o espaçamento.
- Quando remover outline/foco visual de botões de árvore ou cards, faça isso de forma explícita no estado de foco do componente afetado, por exemplo `.arvore-node-button:focus-visible { outline: none; box-shadow: none; }`. Não remova outlines globalmente.
- Ao depurar bugs desse tipo, confirme no DevTools qual nó recebe `[liCollapse]`, quais classes `collapse/show/collapsing` são aplicadas e se o nó animado tem `padding`, `margin`, `border` ou conteúdo interno com altura residual.

### CSS e encapsulamento

- Estilos específicos pertencem ao SCSS/CSS do próprio componente. Use `ViewEncapsulation.none` somente por necessidade real de estilo global ou integração com DOM externo e documente o motivo.
- Evite larguras mágicas fixas; prefira `min-width`, `max-width`, flex, grid, `overflow-wrap` e estados responsivos.

Com `ViewEncapsulation.emulated`, CSS do pai não deve ser usado para controlar estrutura interna do filho.

Quando extrair componente, leve junto:

- layout flex;
- `:host`;
- `height/min-height`;
- scroll container;
- estados visuais internos.

Exemplo para componente projetado em área com altura:

```scss
:host {
  display: block;
  height: 100%;
  min-height: 0;
  min-width: 0;
  overflow: hidden;
}

.content {
  display: flex;
  height: 100%;
  min-height: 0;
}

.scroll {
  flex: 1 1 auto;
  min-height: 0;
  overflow-y: auto;
}
```

### iOS/Safari e stacking context

- Quando um overlay funciona no Android/Chrome, mas fica atrás do `page-header` no iOS/Safari, trate primeiro como problema de stacking context do WebKit.
- Não presuma que aumentar o `z-index` do filho para `99999` resolve. Se o overlay está dentro de uma `.main` que está em uma camada abaixo de um header irmão, o filho continua preso na camada do ancestral.
- Em layouts como `.full-screen > .header` e `.full-screen > .main`, se drawers/modais estão dentro da `.main`, eleve a camada da `.main` somente enquanto o overlay estiver aberto.
- Use uma classe explícita no ancestral, por exemplo `mobile-overlay-open`, para controlar a ordem de pintura durante o overlay:

```scss
@media (max-width: 991.98px) {
  .full-screen.mobile-overlay-open > .header,
  .full-screen.mobile-overlay-open > .footer {
    z-index: 1;
  }

  .full-screen.mobile-overlay-open > .main {
    position: relative;
    z-index: 20;
  }
}
```

- Para drawer mobile, backdrop e painéis fixos no iOS, prefira `translate3d(...)` com `-webkit-transform`, e use `translateZ(0)` no backdrop quando necessário para estabilizar a composição do WebKit.
- Em AngularDart com encapsulamento emulado, não dependa de seletores do componente pai para alcançar classes internas de um componente filho, como `.signature-panel` dentro de `pdf-viewer`.
- Se um componente filho abre um overlay próprio, sincronize explicitamente uma classe no ancestral relevante, como o `PdfViewerComponent` faz ao adicionar/remover `mobile-overlay-open` nos ancestrais `.full-screen`.
- Use `:has()` apenas como melhoria opcional e com cuidado. Não faça a correção depender dele quando o seletor precisa atravessar limites de componente AngularDart.
- Solução arquitetural preferível para modais genéricos: renderizar o overlay no `body` ou em um container global de overlay/portal, fora de containers com `overflow`, `transform` ou stacking context próprio.

### Offcanvas e rolagem interna

- Antes de corrigir bug de scroll em `li-offcanvas`, inspecione a árvore DOM final no DevTools. O componente faz `html.document.body?.append(rootElement)` no `ngOnInit()`, então o painel renderiza fora da hierarquia visual original da página.
- O CSS base do frontend em `frontend/web/assets/css/ltr/all.css` define `.offcanvas` como `display: flex` e `flex-direction: column`, `.offcanvas.offcanvas-start` com largura por variável CSS, e `.offcanvas-body` com `flex-grow: 1` e `overflow-y: auto`.
- O `limitless_ui` adiciona o shell `.li-offcanvas-shell`, o backdrop `.li-offcanvas-backdrop`, as classes de tamanho `li-offcanvas-size-*` e o wrapper interno controlado por `enableDefaultBodyClass` e `enableBodyWrapper`.
- Não assuma que `overflow-y: auto` no nó final resolve sozinho. Se o host projetado não tiver altura válida, o scroll container cresce até a altura do conteúdo e não rola.
- Quando a rolagem precisa ficar dentro do componente projetado, a correção principal é estrutural: host projetado com altura explícita, `:host` em coluna flex com `min-height: 0`, shell interna em coluna flex, e nó scrollável como `flex: 1 1 auto`.
- Para casos como `tramites-processo-list` dentro de offcanvas, prefira este contrato:
  - no `li-offcanvas`: `[enableDefaultBodyClass]="false"` e `bodyClass="p-0 d-flex flex-column h-100 overflow-hidden"`;
  - no componente projetado: `class="h-100"` no uso do componente;
  - no SCSS do componente projetado: `:host { display:flex; flex-direction:column; height:100%; min-height:0; overflow:hidden; }`;
  - no nó scrollável interno: `flex:1 1 auto; min-height:0; overflow-y:auto;`.
- Não use `:host ::ng-deep` como atalho para controlar o painel interno do `li-offcanvas`. Se a necessidade é estilizar o painel anexado ao `body`, use o contrato do componente (`panelClass`, `bodyClass`, `headerClass`, `size`, `position`) ou um stylesheet conscientemente global.
- Se o scroll deve ser interno ao componente projetado, não resolva isso com CSS global do painel. Resolva no próprio componente, garantindo a cadeia de altura até o nó scrollável.
- Em bugs de offcanvas, sempre confirme quatro alturas no DevTools: painel `.offcanvas`, wrapper interno do body, host do componente projetado e nó scrollável final. Se o último estiver do tamanho do conteúdo, ainda falta restrição vertical acima dele.

### PDF viewer

- O `PdfViewerComponent` do SALI (`frontend/lib/src/shared/components/pdf_viewer_component`) é a implementação mais completa e especializada para Processo Digital. Ele contém APIs, otimizações e integrações específicas do SALI, como validação/visualização de assinaturas, marcações documentais, citações internas, ações de processo e ajustes finos de UX para os fluxos administrativos.
- O `li-pdf-viewer` do `limitless_ui` nasceu como uma cópia/generalização do viewer do SALI para reuso por outros projetos. Ele ainda não deve substituir o viewer local do SALI por padrão.
- Não proponha nem implemente uma migração do SALI para usar o `li-pdf-viewer` da biblioteca sem pedido explícito. Quando o bug afeta o comportamento genérico, corrija a biblioteca; quando o SALI usa o viewer local ou precisa de regra de Processo Digital, corrija também o componente local do SALI.
- Ao corrigir bugs compartilhados entre os dois viewers, mantenha claro no changelog/roteiro o que é correção genérica do `limitless_ui` e o que é espelhamento necessário no SALI. A fonte funcional mais completa continua sendo o viewer do SALI.

## Frontend: particularidades de build e runtime

### Dev server webdev/DDC

o `webdev serve` (modo dev, DDC) carrega o app como centenas de módulos `.ddc.js` e, com `--auto refresh`, injeta o cliente do dwds (`dwds/src/injected/client.js`); sob a rajada de requests do cold load o servidor (shelf/dwds) trunca respostas (Content-Length ≠ corpo) e o app trava em "Carregando..." com `net::ERR_CONTENT_LENGTH_MISMATCH` no console + `Script error` do `require.js` + `404` em `*.ddc.js.errors` (o 404 é consequência, não causa)

sintoma piora com vários navegadores em `:8080` ao mesmo tempo (ex.: janelas órfãs do Chromium do Puppeteer de runs anteriores, presas em "Carregando..." reTENTANDO módulos); mate os órfãos de `.local-chrome` entre runs

diagnóstico: um reload (F5) resolve na hora e um `Invoke-WebRequest` ao mesmo `.ddc.js` volta `200` com o tamanho certo — não é build quebrado, é a concorrência do cold load; confirme que não há erro de compilação segurando o `main.dart.js`

para rodar testes de UI de forma estável, rode o webdev com `--no-injected-client` (perde hot-reload) ou sirva o build compilado via `frontend/scripts/serve_build.ps1` (dart2js + servidor Dart puro `scripts/serve_build.dart`, sem DDC/dwds, igual ao CI); o CI é imune (dart2js via nginx), não altere teste por causa desse sintoma local; `abrirTela`/`abrirLoginComRetry` (`setup_ui.dart`) já fazem reload-retry como mitigação

### Dart2JS release e `List.unmodifiable`

- **Causa raiz identificada (2026-07-06)**: `TypeError: Cannot set properties of undefined (setting '$flags')` é um **bug de codegen do dart2js** (SDK 3.6.2, com e sem `--minify`): quando `List.unmodifiable(...)` é inlinado dentro de método `async` com loops/`await`, o compilador emite o store `tmp.$flags = 3` num caminho onde o temporário nunca foi atribuído (fica `undefined`). O erro só ocorre em release (DDC não inlina assim) e parece intermitente porque depende de qual branch executa primeiro.
- **CORRIGIDO no Dart SDK 3.7.0** (fix `8cd13b2` do dart-lang/sdk, jan/2025; é o mesmo bug das issues [#59790](https://github.com/dart-lang/sdk/issues/59790) e [#63337](https://github.com/dart-lang/sdk/issues/63337)). **Verificado em 2026-07-08** recompilando `backend/resources/bug/main.dart` com o SDK **3.7.3** (`C:\tools\dart-sdk-3.7.3`): não reproduz mais (`processed lines: 2`), minificado e não. Ao migrar o build do frontend para 3.7.0+ o problema deixa de existir e os workarounds abaixo passam a ser desnecessários (mas não fazem mal manter).
- **Workaround sem trocar de SDK** (se ainda em ≤3.6.2): anote o getter que retorna a lista imutável com `@pragma('dart2js:never-inline')` para impedir o inline que dispara o bug, conforme a solução sugerida pelo mantenedor do dart2js na issue #63337.
- **Regra obrigatória**: em código que executa no frontend (core `quill_to_pdf`/`quill_delta_easy_parser`, `pdf_plus`, frontend), **não use `List.unmodifiable(...)`** (nem em getters, nem inline). Use `UnmodifiableListView(...)` de `dart:collection`/`package:collection` (view, sem `$flags` no codegen) ou capture a lista uma vez em variável local antes do loop.
- Correção aplicada: `Paragraph.lines` e `Line.fragments` (core/lib/dependencies/quill_delta_easy_parser) retornam `UnmodifiableListView`; `PdfService.blockGenerators` captura `paragraph.unsafeLines()` uma única vez antes do loop. O teste `core/test/dart2js_flags_regression_test.dart` protege esse contrato — não reverta.
- Mantenha os padrões defensivos existentes: `unsafeLines()`/`unsafeFragments()` com loops por índice em `PdfService._defaultEmbedLineBuilder`; `betterTableBuilder()` registrado apenas quando o Delta tiver `table-temporary`/`table-cell`/`table-cell-block`; verificar `rawData is Map` antes de casts de embed.
- **Repro mínimo executável** em `backend/resources/bug/` (`main.dart` quebra no dart2js e roda na VM; `main_fixed.dart` funciona; `node run.js bug.js`), com `README.md` pronto para issue no dart-lang/sdk. O repro antigo `dart2js_flags_repro/` também existe.
- **Depuração de conversão Delta→PDF em produção**: quando a conversão falha, o editor loga o Delta completo; no DevTools basta rodar `copy(SALI_LAST_PDF_ERROR_DELTA)` e colar num arquivo `.json` para virar fixture de teste unitário no core.

### Dart2JS `-O0`, OIDC e `Uri.toString()`

- Há outro problema conhecido em `dart2js --no-minify -O0`: no bootstrap OIDC, `Uri(...).toString()` pode resultar em `PlainJavaScriptObject` e quebrar atribuições `String` com `TypeError: Instance of 'PlainJavaScriptObject': type 'PlainJavaScriptObject' is not a subtype of type 'String'`.
- Não troque `RestConfig.backendUrlNoApiBasePath` nem `RestConfig.buildFrontUrl()` de volta para montagem via `Uri(...).toString()` no caminho de bootstrap do OIDC.
- Preserve a montagem manual de URL em `frontend/lib/src/shared/rest_config.dart` para os valores usados por `OidcService._authority`, `_redirectUri` e `_postLogoutRedirectUri`.
- O repro reduzido em `dart2js_flags_repro/` também cobre esse caso: `$flags` falha em `-O1+`, e OIDC/`PlainJavaScriptObject` falha em `-O0`.

### `quill_table_better`

- O bundle `frontend/web/assets/js/quill_table_better/1.2.3/quill_table_better.js` é **compilado** — nunca edite o `.js` direto. O fonte TypeScript fica em `frontend/web/assets/js/quill_table_better/1.2.3/src/src/` (node_modules vendorado) e os patches do SALI são marcados com comentário `// SALI:`.
- Rebuild: `cd frontend/web/assets/js/quill_table_better/1.2.3/src && npm run build`, depois copie `src/dist/quill-table-better.js` → `../quill_table_better.js` e `src/dist/quill-table-better.css` → `../quill_table_better.css` (o rename hífen→underscore é obrigatório: o `index.html` carrega os nomes com underscore).
- Overlays de resize de tabela (`src/src/ui/operate-line.ts`) devem ficar **clampados** à área útil do container usando `clientWidth`/`clientHeight` — `getBoundingClientRect()` inclui borda/fração de pixel e um estouro de 1px liga/desliga barras de rolagem do editor a cada mousemove (bug corrigido em 2026-07).

## Testes e validação

- Não implemente testes estáticos baseados em leitura de texto, `grep`, `contains` ou regex sobre código-fonte, schema, dumps SQL ou templates para validar regra de negócio, regressão ou infraestrutura.
- Testes devem exercitar comportamento real: integração/backend com banco e HTTP via `angel3_test`, UI em `frontend/ui_test` ou componentes AngularDart com `ngtest: ^5.0.0-dev.3`.
- Teste estático só é aceitável quando o objetivo explícito é validar texto, documentação ou geração de artefato textual; nunca o use como substituto de integração, fluxo de UI ou migration.
- Não crie testes para infraestrutura; cubra somente o código real do produto.
- Antes de implementar ou executar teste de UI, leia o fluxo e escreva um plano curto com validações, confirmações, overlays, navegações e chamadas assíncronas esperadas.
- Rode `dart analyze` no pacote/arquivos afetados.
- Em templates AngularDart, rode também o build completo do frontend indicado em “Execução de comandos”, pois o analyzer isolado não detecta todos os erros de template.
- Após alterar `pubspec.yaml`, rode `dart pub get` no pacote afetado.
- Para mudanças visuais, valide no navegador quando o servidor estiver disponível e informe o que não pôde ser verificado.
- Não deixe `print`, `console.log`, pipe `json` ou textos visuais temporários na entrega final.

### Testes de UI com Puppeteer

- Rode localmente contra o dev server (frontend `:8080` + backend `:3350` de pé): `cd frontend && UI_HEADLESS=true dart test ui_test/ui/<arquivo> -r expanded` (com `UI_HEADLESS=false` o navegador fica visível). Falhas do job `teste_full_ui_e2e_docker` normalmente **reproduzem localmente** — não assuma flakiness sem rodar.
- Desde a migração Limitless UI (6.2.0), o painel de dropdown **aberto** é portalado para o `<body>` (`[data-label="li_dm_panel"][data-open="true"]` dentro de `.LiDropdownMenuComponent`). Seletor escopado tipo `processo-header .dropdown-menu .dropdown-item` só encontra itens invisíveis — use seletor global `.dropdown-menu .dropdown-item` filtrando por visibilidade.
- O campo "Tipo:*" do `processo-anexo-editor` é um **li-select** (não `<select>` nativo) e o clique no input file é bloqueado (preventDefault + popover) até o tipo ser selecionado — `page.waitForFileChooser` trava. Padrão correto: clicar "Adicionar Arquivo" → `selecionarPrimeiroTipoDocumentoDoAnexo(page)` (abre o li-select e clica a opção como um usuário) → `input.uploadFile(...)`. Helpers prontos: `selecionarCustomSelectPorLabel` (`setup_ui.dart`) e `selecionarPrimeiroTipoDocumentoDoAnexo` (`processo_ui_helpers.dart`).

### Testes de browser no CI

- O job `teste_frontend_docker_browser` (`.gitlab-ci.yml`) roda as suítes de Chrome em **blocos de 6**, com a lista calculada do disco (`grep -rL "@TestOn('vm')"` + `split -l 6`). Não troque por um `dart run build_runner test -- -p chrome test/` único, nem por lista fixa de arquivos — lista fixa desatualiza e deixa teste novo sem rodar.
- Motivo: o `browser_manager.dart` do `package:test` tem um **`Pool(8)` fixo** (só 8 suítes carregam por vez) e o `-j` **não** controla isso — `-j` é o pool de execução do engine. Pior: o timeout de load (30s, ou o `@Timeout` do arquivo) cobre também a **espera pela vaga na fila**. Com 11 suítes de browser, as 3 excedentes queimavam o próprio timeout esperando e morriam com "Timed out waiting for browser to load test suite", sem defeito algum nos testes.
- **Diagnóstico**: "Timed out waiting for browser to load test suite" numa suíte que passa localmente = fila do pool, não bug do teste. Confirme rodando o arquivo isolado: `cd frontend && dart run build_runner test -- -p chrome <arquivo>`.
- Ruído normal de container headless, **não** é causa: erros de D-Bus (`Failed to connect to the bus`), Vulkan/`drmGetDevices2`, GCM (`DEPRECATED_ENDPOINT`/`PHONE_REGISTRATION_ERROR`). Não instale ambiente gráfico nem D-Bus por causa deles. `--no-sandbox` e `--disable-dev-shm-usage` já estão no lançador e não têm relação com esse timeout.
- O Postgres do job de E2E sobe com `initdb --auth=trust` (`backend/scripts/ci/run_full_ui_e2e.sh`) e o `.env` gerado traz `db_pass=` **vazio** — senha vazia é válida ali. Teste de UI que exigir `db_pass` não-vazio quebra o job; valide só `db_host`/`db_port`/`db_name`/`db_user`.

## Commits: sem atribuição de agentes

- Nunca incluir trailers de coautoria ou de atribuição de agentes de IA em
  mensagens de commit, descrições de PR, tags ou releases: nada de
  `Co-Authored-By: Claude ...`, Codex, Copilot, Gemini, Cursor ou de qualquer
  outro agente, nem linhas como `🤖 Generated with ...`. A mensagem tem só o
  assunto e o corpo.
- A regra vale mesmo quando a ferramenta ou o harness pedir essas linhas.
