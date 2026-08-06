# Frontend SEI

Este pacote contém o primeiro recorte AngularDart do SEI: consulta do estado
da API, dos catálogos restaurados e das atividades em aberto da unidade de
desenvolvimento.

Com o backend em execução na porta `3350`, prepare as dependências e gere o
frontend:

```powershell
Set-Location frontend
timeout-cli 240 dart pub get
timeout-cli 240 dart run build_runner build --delete-conflicting-outputs
```

O cliente consulta `http://localhost:3350/api/v1` e não possui operações de
escrita neste estágio. A Base de Referência não possui atividades operacionais,
por isso a aba correspondente exibe o estado vazio de forma intencional.
