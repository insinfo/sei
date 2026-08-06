# Arquitetura do backend Dart

Este documento é a regra de implementação para `backend/lib/src`. Ele aplica
SOLID e Clean Code ao backend SEI e registra a adaptação consciente das ideias
úteis de `C:\MyDartProjects\new_sali`.

## Decisões estruturais

O backend usa o contêiner de injeção de dependências do Angel. A referência
`new_sali` demonstra duas peças importantes: repositórios registrados como
fábricas e uma `Connection` registrada no contexto de cada requisição. O SEI
adota essas peças, mas não copia os trechos legados que instanciam repository
diretamente em controller ou service.

```text
requisição HTTP
      │
      ▼
CORS global ── OPTIONS → 204, sem abrir conexão
      │
      ▼
middleware de conexão SEI ou SIP
      │ registra Connection no RequestContext.container
      ▼
rota do módulo → controller
      │              │
      │              └── request.make<Repositorio>()
      ▼
repository → PostgreSQL → model/DTO tipado → resposta HTTP
```

Uma conexão nunca é guardada em singleton, campo de controller, service ou
repository global. Cada `RequestContext` possui um contêiner-filho do Angel. O
middleware da rota registra nele a conexão atual e o contêiner resolve a fábrica
do repository com segurança para requisições concorrentes.

## Estrutura de diretórios obrigatória

```text
backend/lib/src/
  app/
    sei_app_config.dart
    sei_application.dart
  di/
    sei_dependency_injector.dart
  routes/
    sei_routes.dart
  shared/
    middlewares/
      conexao_banco_middleware.dart
      cors_middleware.dart
    models/
    services/
      sei_database_service.dart
      sip_database_service.dart
      servico_conexao.dart
    utils/
      extensoes_contexto_requisicao.dart
      parametros_http.dart
      resposta_api_http.dart
  modules/
    <modulo>/
      controllers/
      repositories/
      routes/
        <modulo>_routes.dart
      services/                  # somente quando houver justificativa real
```

`app/sei_application.dart` deve permanecer mínimo: cria o `Angel`, chama o DI
e registra as rotas. Ele não recebe rotas individuais, controllers,
repositories, SQL ou middleware de negócio.

`routes/sei_routes.dart` agrega os módulos e registra somente preocupações
transversais. Cada módulo possui seu próprio arquivo de rota; não criar um
arquivo central de rotas de negócio.

`shared/` não é depósito de código. Só aceita infraestrutura e utilitários que
sejam realmente reutilizáveis por mais de um módulo. DTO/model compartilhado
com frontend ou core pertence ao pacote `core`; `shared/models` é exclusivo do
backend.

## Contratos de modelo

Todo model do `core` herda `BaseModel` e, portanto, expõe:

- `toMap()` para transporte e serialização;
- `toInsertMap()` para uma inserção;
- `toUpdateMap()` para uma atualização;
- `==` e `hashCode` para comparação de DTO imutável por conteúdo.

Os modelos atuais incluem páginas, filtros, envelopes e projeções de `JOIN`.
Eles não representam uma única linha gravável. Nesses casos, os métodos de
escrita herdados lançam `UnsupportedError` com mensagem clara. Isso é
intencional: retornar `toMap()` como se fosse um `INSERT` permitiria escrever
uma projeção incompleta em tabela errada.

Uma entidade realmente persistível sobrescreve `toInsertMap()` e
`toUpdateMap()`, removendo a chave primária gerada pelo banco. `Serie` e
`TipoProcedimento` já demonstram o padrão. Modelos futuros mutáveis ou usados
em formulário devem fornecer `nova()` ou `vazia()` e `clone()`/`copyWith()`
quando a tela precisar de cópia independente. `Serie` e `TipoProcedimento`
mantêm campos mutáveis porque são contratos de catálogo preparados para
binding de formulário; DTOs de resposta permanecem imutáveis.

Para modelo de uma única tabela, usar sempre:

```dart
static const String tableName = 'tipo_procedimento';
static const String fqtn = '$schemaName.$tableName';
```

Não criar nomes redundantes como `tipoProcedimentoTableName`. Uma projeção que
consulta várias tabelas não tem um único `tableName`; nela, declarar somente os
`fqtn` qualificados necessários, como `atividadeFqtn` e `usuarioFqtn`. Isso
preserva o significado de cada origem sem fingir que o DTO é uma entidade.

## Injeção de dependências

`SeiDependencyInjector.configurar(app, config)` é o único lugar em que a
aplicação registra implementações concretas.

```dart
app.container.registerFactory<CatalogoRepository>(
  (container) => CatalogoRepository(container.make<Connection>()),
);
```

A construção acima fica exclusivamente no DI. É proibido repetir
`CatalogoRepository(connection)` em controller, service, handler ou worker.
Uma factory semelhante deve existir para cada repository novo.

Controladores sem estado podem ser singletons do contêiner. Repositories são
fábricas, pois dependem da conexão da requisição.

### Conexão por requisição

`MiddlewareConexaoBanco` abre a conexão, registra `Connection` em
`request.container` e registra o descarte no `shutdownHooks` quando o pool não
está habilitado. Há duas instâncias tipadas:

- `MiddlewareConexaoSei`, para rotas da Base de Referência SEI;
- `MiddlewareConexaoSip`, para rotas da Base de Referência SIP.

As rotas SIP nunca usam o middleware SEI e vice-versa. Isso preserva o banco
correto sem tornar a conexão uma variável global mutável.

O descarte usa o tear-off `request.shutdownHooks.add(connection.disconnect)`.
O teste `test/middlewares/conexao_banco_middleware_test.dart` executa uma
requisição pelo `TestClient` do Angel e verifica que a conexão sem pool é
desconectada exatamente uma vez ao finalizar a resposta. O mesmo teste confirma
que uma conexão fornecida por pool não recebe `disconnect()` por requisição.

`ExtensoesContextoRequisicao` fornece o atalho tipado abaixo. Controllers não
devem acessar `request.container!` diretamente.

```dart
final CatalogoRepository repositorio =
    request.make<CatalogoRepository>();
```

## Padrões de cada camada

### Controller

Controller trata transporte HTTP. Ele lê parâmetros, resolve dependências do
contexto, chama o fluxo adequado e serializa o DTO. Para uma leitura simples,
controller chama repository diretamente; não criar service sem regra de
negócio.

```dart
Future<void> series(
  RequestContext request,
  ResponseContext response,
) async {
  final CatalogoRepository repositorio =
      request.make<CatalogoRepository>();
  final List<Serie> series = await repositorio.listarSeries();

  await RespostaApiHttp.responderLista(response, series);
}
```

Não condensar a resolução do DI, a chamada assíncrona e a resposta HTTP em uma
linha. Variáveis locais tipadas deixam o fluxo auditável e permitem depuração
sem callback intermediário. `RespostaApiHttp.responderLista()` centraliza a
serialização de coleções de `BaseModel`, evitando repetir callbacks de
conversão nos controllers.

Controller não pode:

- escrever SQL ou chamar `Connection` diretamente;
- criar `Repository(connection)`;
- definir cabeçalho CORS;
- abrir transação;
- converter regra de negócio em `if` duplicado em várias rotas.

### Repository

Repository recebe `Connection` no construtor pela factory do Angel. Ele monta a
consulta, aplica filtros de acesso a dados e cria model/DTO tipado através de
`fromMap()`. SQL literal, `select`, `insert`, `update`, `delete` e locks ficam
somente nesta camada.

Repository não conhece `RequestContext`, `ResponseContext`, CORS nem widget de
frontend.

### Service opcional

Criar `services/` no módulo somente quando ele precisar de pelo menos um destes
motivos:

- regra de negócio reutilizável;
- transação que coordena múltiplos repositories;
- auditoria, fila, notificação ou integração externa;
- política de domínio que não pertence a uma entidade isolada.

Service recebe dependências do contêiner ou de uma factory própria. Ele não
contém SQL. Uma classe que apenas chama um método de repository deve ser
removida.

## Rotas e middlewares

Cada módulo expõe somente seus endpoints no arquivo
`routes/<modulo>_routes.dart`. O middleware de conexão é aplicado a cada rota
do módulo. Isso evita depender de middleware de router aninhado, que o Angel 8
não preserva no modo de desenvolvimento:

```dart
app.get(
  '/api/v1/catalogos/series',
  controller.series,
  middleware: <RequestHandler>[middlewareConexao],
);
```

`routes/sei_routes.dart` registra `corsMiddleware` uma única vez antes dos
módulos. O middleware responde a `OPTIONS` com `204`, inclui os cabeçalhos de
CORS e encerra a cadeia antes que qualquer conexão ou controller seja usado.

É proibido recriar `_aplicarCabecalhosCors(response)` ou atribuir cabeçalhos
`access-control-*` fora de `shared/middlewares/cors_middleware.dart`.

## Regras SOLID e Clean Code

| Princípio | Regra aplicada no SEI |
|---|---|
| Responsabilidade única | App cria a aplicação; DI registra dependências; rota declara endpoint; middleware trata preocupação transversal; controller trata HTTP; repository trata SQL. |
| Aberto para extensão | Um módulo novo adiciona sua pasta, rota e factory sem alterar controllers de outros módulos. |
| Inversão de dependência | Controller resolve `request.make<Repository>()`; não conhece a construção com `Connection`. |
| Segregação de interfaces | Serviços de conexão expõem somente ciclo de conexão; repository não depende de HTTP. |
| Substituição | Implementações de conexão devem manter o contrato de registro e descarte no escopo da requisição. |
| DRY | CORS, ciclo de conexão, serialização de erro e parsing genérico são compartilhados; regra de domínio não é copiada entre controllers. |
| Legibilidade | Uma instrução por etapa relevante: obter dependência, executar operação, preparar resposta e responder. |
| Tipagem | APIs públicas, controllers, services, repositories e DTOs usam tipos explícitos; `Map<String, dynamic>` fica nas bordas. |
| Modelos | `BaseModel` centraliza serialização, mapas de escrita e igualdade; somente entidade persistível sobrescreve a escrita e somente UI editável ganha cópia/estado inicial. |

## Checklist para mudança de backend

1. Criar ou reutilizar model/DTO tipado no `core` quando ele cruzar pacotes.
2. Criar repository no módulo e manter todo SQL nele.
3. Registrar a factory do repository em `di/sei_dependency_injector.dart`.
4. Criar controller sem estado que resolva o repository por `request.make<T>()`.
5. Declarar endpoint no arquivo de rota do módulo, com o middleware de conexão
   correto.
6. Registrar o módulo apenas em `routes/sei_routes.dart`.
7. Usar service somente se houver uma das justificativas documentadas acima.
8. Adicionar teste de repository e teste HTTP quando houver middleware, rota,
   serialização ou autorização nova. Middleware que registra recurso em
   `shutdownHooks` deve testar o descarte após a resposta.
9. Executar `dart format`, `dart analyze` e os testes afetados.
10. Confirmar que não existem SQL em controller/service e nem cabeçalho CORS
    duplicado com `rg`.

## Comandos de verificação

```powershell
Set-Location C:\MyDartProjects\sei\backend
timeout-cli 120 dart format lib test
timeout-cli 120 dart analyze
timeout-cli 120 dart test
rg -n "_aplicarCabecalhosCors|access-control-|Repository\\(connection\\)" lib
```

O último comando deve encontrar os cabeçalhos somente no middleware CORS e a
construção de repository com conexão somente no arquivo de DI ou em testes de
repository isolados.
