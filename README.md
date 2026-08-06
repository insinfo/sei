# SEI em Dart

Esta base inicia a implementação Dart full stack compatível com a estrutura da Base de Referência SEI 5.0.0. O recorte disponível neste momento é deliberadamente somente leitura: ele comprova a conexão real com o PostgreSQL restaurado e expõe os catálogos de tipos de processo e documento para uma interface AngularDart.

## Banco local

Os bancos locais restaurados são `sei_5_0_0` e `sip_5_0_0`, ambos em LATIN1 e compatíveis com as Bases de Referência íntegras. Para recriá-los de forma controlada, consulte [a documentação de restauração](backend/referencias/backup_sei_bd/README_RESTAURACAO_POSTGRESQL.md) e execute o script correspondente.

A cópia UTF-8 corrompida do dump, com caracteres de substituição (`�`), foi preservada somente para análise. A aplicação e os testes usam a cópia íntegra do repositório local `sei-db-ref-executivo`. A Base de Referência não contém processos, documentos ou atividades operacionais; uma carga anonimizada será necessária para demonstrar fluxos completos.

## Executar a API

```powershell
Set-Location C:\MyDartProjects\sei\backend
timeout-cli 240 dart pub get
dart run bin/server.dart
```

A API atende em `http://localhost:3350/api/v1` e disponibiliza:

- `GET /saude`;
- `GET /catalogos/resumo`;
- `GET /catalogos/tipos-procedimento`;
- `GET /catalogos/series`.
- `GET /contexto/desenvolvimento`;
- `GET /controle-processos/recebidos`;
- `GET /controle-processos/gerados`.

Todas as rotas atuais são públicas e somente leitura, próprias para desenvolvimento. O contexto de desenvolvimento é obtido da referência restaurada, mas não constitui autenticação compatível com SIP; login, sessão, autorização por recurso e operações que escrevem no banco ainda não foram implementados.

## Preparar a interface

```powershell
Set-Location C:\MyDartProjects\sei\frontend
timeout-cli 240 dart pub get
timeout-cli 240 dart run build_runner build --delete-conflicting-outputs
```

A interface apresenta o estado da API, os quantitativos restaurados, listas filtráveis de tipos de processo e documento, seleção explícita de unidade de referência e as abas Recebidos e Gerados. A Base de Referência retorna essas últimas vazias por não conter dados operacionais; uma carga anonimizada será necessária para demonstrar linhas reais.
