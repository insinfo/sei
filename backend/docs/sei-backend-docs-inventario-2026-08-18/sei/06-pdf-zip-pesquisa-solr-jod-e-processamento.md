# 06 — PDF, ZIP, pesquisa, Solr, JOD e processamento

## 1. Tela de geração de PDF

A tela analisada oferece:

- Todos os documentos disponíveis;
- Todos exceto selecionados;
- Apenas selecionados;
- botão **Gerar**.

![Gerar Arquivo PDF do Processo](assets/03-gerar-pdf-processo.png)

## 2. A geração é imediata ou agendada?

### Comportamento documentado

O fluxo oficial é:

```text
abrir processo
→ clicar em Gerar PDF
→ selecionar documentos
→ clicar em Gerar
→ navegador baixa o PDF
```

O manual não descreve criação de job, fila, tela de progresso assíncrono ou notificação posterior.

### Conclusão técnica

> **No comportamento padrão analisado, a geração é imediata/síncrona no ciclo da requisição web.**

Essa conclusão é uma inferência técnica apoiada por dois elementos oficiais:

1. o manual diz que o arquivo é baixado automaticamente logo após **Gerar**;
2. a configuração de referência do `sei-docker` classifica **Geração de PDF** como operação de Limite Nível 2 do processo PHP, com tempo e memória próprios, e não como agendamento.

Na configuração pública de desenvolvimento analisada, o Nível 2 está definido com valores de referência de 600 segundos e 2.048 MB. Esses valores não devem ser tratados como padrão obrigatório de produção; são parâmetros do ambiente de referência.

### Consequências

Durante uma exportação grande, o servidor pode consumir:

- um worker PHP/Apache;
- CPU para renderização e junção;
- memória proporcional aos documentos e páginas;
- leitura intensa do repositório de arquivos;
- espaço temporário;
- chamadas ao conversor JOD, quando aplicável.

O usuário fica dependente da conclusão da requisição e dos limites de timeout, memória, proxy e navegador.

### Exceções

Um órgão pode customizar o SEI ou instalar módulo que implemente fila. A conclusão acima se refere ao fluxo nativo/documentado e à configuração pública analisada.

## 3. O que entra no PDF

O usuário escolhe os documentos. O manual informa que não são convertidos:

- formatos de imagem;
- som;
- arquivos compactados;
- documentos cancelados;
- minutas de documentos de outras unidades.

Também é necessário permitir pop-ups/downloads do endereço do SEI.

### Implicação

“Todos os documentos disponíveis” não significa literalmente todos os itens da árvore. Significa todos os documentos que:

- o usuário pode acessar;
- estão em situação convertível;
- possuem formato suportado;
- não são excluídos pelas regras acima.

## 4. PDF versus ZIP

| Aspecto | PDF | ZIP |
|---|---|---|
| Objetivo | Representação consolidada e paginada. | Pacote de arquivos em formatos originais. |
| Formatos | Apenas documentos convertíveis. | Pode preservar maior variedade de arquivos. |
| Uso | Leitura, impressão, remessa e consulta. | Backup operacional/download de anexos. |
| Custo | Conversão e junção podem ser pesadas. | Principalmente leitura, cópia e compactação. |
| Fidelidade | Pode haver diferenças de conversão. | Mantém arquivo original. |

## 5. JODConverter

O **SEI-JOD** é um serviço HTTP que usa Java + JODConverter + LibreOffice para transformar documentos de escritório em PDF.

```text
SEI → HTTP → JODConverter → LibreOffice headless → PDF
```

Na imagem pública `jod4.4.8` do projeto `sei-docker` existem:

- Alpine Linux;
- OpenJDK 17;
- JODConverter 4.4.8;
- LibreOffice;
- fontes Noto, DejaVu, CJK, Font Awesome e outras;
- dois processos internos do LibreOffice;
- API na porta 8080;
- limite de upload de referência de 1.024 MB;
- heap Java máximo configurado em 2 GB.

### Vantagens

- isola conversão pesada do processo PHP;
- permite compartilhar conversor entre várias instâncias;
- dispensa Microsoft Office no servidor;
- pode ser escalado horizontalmente.

### Limitações

- conversão depende dos filtros do LibreOffice;
- fontes ausentes alteram paginação/layout;
- macros, OLE, vínculos externos e documentos protegidos podem falhar;
- dois workers atendem apenas duas conversões simultâneas, salvo mudança de configuração;
- serviço deve ficar em rede privada, pois recebe documentos potencialmente sigilosos.

## 6. Solr

O **SEI-Solr** é o serviço de indexação e pesquisa. Ele não gera PDF.

Principais cores do SEI:

- `sei-protocolos`;
- `sei-bases-conhecimento`;
- `sei-publicacoes`.

O Solr guarda uma representação pesquisável, não a fonte oficial dos processos. Banco e repositório de arquivos continuam sendo os dados primários.

### Conteúdo pesquisável

- metadados de processo/documento;
- conteúdo do editor HTML;
- documentos externos em texto;
- documentos digitalizados que receberam OCR;
- campos de assunto, unidade, interessado, assinatura e acesso.

### Comportamento

- indexação pode levar alguns minutos;
- documentos não assinados são localizados apenas no âmbito da unidade produtora;
- processos sigilosos não aparecem na pesquisa comum;
- filtros de acesso precisam ser aplicados.

## 7. Infraestrutura observada nos testes do PEN

O `docker-compose` fornecido cria:

- duas instâncias HTTP do SEI, `org1-http` e `org2-http`;
- bancos e Memcached separados por órgão;
- um único Solr compartilhado;
- Selenium, proxy e MailCatcher;
- não declara serviço JOD nesse ambiente funcional do PEN.

Ambos os contêineres HTTP possuem link para o mesmo host `solr`, demonstrando compartilhamento do servidor de pesquisa no ambiente de teste. Para produção, instalações independentes devem usar índices/cores logicamente isolados para evitar colisões e mistura de dados.

## 8. Solr e JOD dependem um do outro?

Não.

```text
Solr = indexação e pesquisa
JOD  = conversão de arquivos Office
```

Um documento pode ser convertido pelo JOD e depois indexado pelo Solr, mas isso é coordenação do SEI; os serviços não formam uma dependência direta obrigatória entre si.

## 9. Recomendações para uma nova implementação

> Recomendações, não comportamento nativo do SEI.

Para processos volumosos, é preferível implementar exportação consolidada assíncrona:

```text
POST /processos/{id}/exportacoes
  → cria job
  → retorna 202 + id

worker
  → gera documentos convertidos
  → junta PDF
  → grava checksum e arquivo

GET /exportacoes/{id}
  → PENDENTE | PROCESSANDO | CONCLUIDA | FALHOU
```

Recursos recomendados:

- fila persistente;
- progresso por documento;
- cancelamento;
- idempotência;
- timeout por componente;
- cache por versão do processo;
- hash dos documentos;
- expiração do arquivo gerado;
- limite de páginas/tamanho;
- isolamento de JOD;
- logs e métricas;
- download com autorização revalidada;
- preservação da ordem selecionada;
- relatório de itens omitidos.

### Estratégia híbrida

- PDF pequeno: geração síncrona.
- PDF grande ou com conversões: job assíncrono.
- Limite decidido por número de documentos, bytes e estimativa de páginas.

## 10. Testes essenciais

- geração com todos os documentos convertíveis;
- seleção parcial;
- exclusão de cancelados;
- exclusão de minuta de outra unidade;
- documento sem permissão;
- PDF externo corrompido;
- DOCX com fonte ausente;
- timeout do JOD;
- arquivo com 1.000+ páginas;
- duas gerações idênticas concorrentes;
- processo alterado durante a exportação;
- download após mudança de nível de acesso.

## Fontes principais

- [Gerar PDF ou ZIP][U3]
- [Pesquisa e Base de Conhecimento][U8]
- [Configuração SEI do sei-docker][D1]
- [Dockerfile JODConverter][D2]
- [Dockerfile Solr][D3]
- [`docker-compose` dos testes PEN](referencias/docker-compose-testes-pen.yml)

[U3]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_de_manutencao_e_acompanhamento_de_processos.html
[U8]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Acompanhando_e_recuperando_informacoes_de_processos.html
[D1]: https://github.com/pengovbr/sei-docker/blob/main/containers/app-php8/app-dev-php8/assets/scripts-e-automatizadores/ConfiguracaoSEI.php
[D2]: https://github.com/pengovbr/sei-docker/blob/main/containers/jod4.4.8/Dockerfile
[D3]: https://github.com/pengovbr/sei-docker/blob/main/containers/solr-9.6.1/Dockerfile
