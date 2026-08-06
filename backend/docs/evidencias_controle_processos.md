# Evidências — Controle de Processos

## Classificação de Recebidos e Gerados

| Regra implementada | Evidência local | Decisão |
| --- | --- | --- |
| Recebidos | `backend/referencias/mod-sei-pen/src/rn/ReceberProcedimentoRN.php`, linhas 1367–1382, cria a atividade recebida com `sin_inicial = 'N'`. | Filtrar `atividade.sin_inicial = 'N'`. |
| Gerados | Manual `backend/referencias/manuais_sei_publicos/html/SEI/Operacoes_basicas_com_processos.html`, linhas 450–461, separa os processos abertos entre Recebidos e Gerados. | Filtrar `atividade.sin_inicial = 'S'`. |
| Processo, não documento | Dump canônico `sei_5_0_0_BD_Ref_Exec.sql`, linhas 70634–70638, vincula `procedimento.id_procedimento` a `protocolo.id_protocolo`. | Manter o `JOIN` com `procedimento`. |
| Retorno à unidade de origem | Dump histórico `backup_sei_bd/sei.sql`, sequência do processo 46, mostra atividade posterior com `sin_inicial = 'N'` na unidade originalmente geradora. | Não classificar pela unidade geradora do protocolo. |
| Desempenho | Dump canônico, linhas 68721–68724, possui `i03_atividade(dth_conclusao, id_unidade, sin_inicial)`. | Não criar índice adicional nesta fatia. |
| PEN bloqueado | `backend/referencias/mod-sei-pen/docs/USAGE.md`, linhas 75–81, mantém o processo no Controle de Processos. | Não excluir `sta_estado = '4'`. |

## Contrato atual

As duas rotas de leitura usam os mesmos filtros de unidade e atividade aberta:

```text
GET /api/v1/controle-processos/recebidos?id_unidade=<unidade>
  atividade.id_unidade = <unidade>
  atividade.dth_conclusao IS NULL
  atividade.sin_inicial = 'N'

GET /api/v1/controle-processos/gerados?id_unidade=<unidade>
  atividade.id_unidade = <unidade>
  atividade.dth_conclusao IS NULL
  atividade.sin_inicial = 'S'
```

As rotas não alteram a Base de Referência. A base oficial restaurada não possui
atividades operacionais, portanto ambas retornam página vazia até que uma
fixture anonimizada e isolada ou um ambiente autorizado com dados reais esteja
disponível.

## Limite conhecido

O manual informa que processos sobrestados não aparecem na tela, mas a condição
canônica de banco para identificá-los ainda não foi comprovada nas fontes
locais. Esse filtro não foi inferido nem implementado nesta etapa.
