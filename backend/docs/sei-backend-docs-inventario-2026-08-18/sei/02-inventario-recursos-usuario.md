# 02 — Inventário de recursos do usuário

Este inventário cobre os recursos documentados no Manual do Usuário SEI 4.0+, incluindo funções incorporadas nas versões 4.1 e 5.0. A presença em tela depende de versão, perfil, unidade e módulos.

## 1. Acesso, navegação e organização da tela

| Recurso | Para que serve | Vantagens | Limitações e comportamento |
|---|---|---|---|
| Login | Autenticar o usuário e carregar seus perfis e unidades. | Centraliza identidade e auditoria. | O que o usuário enxerga depende das permissões do SIP. |
| Autenticação em dois fatores | Adicionar código temporário ao login. | Reduz risco de comprometimento por senha. | Depende de ativação e dispositivo/aplicativo autenticador. |
| Troca de unidade | Alternar o contexto organizacional do usuário. | Um usuário pode trabalhar em mais de uma unidade sem outra conta. | Todas as ações são registradas na unidade selecionada; trocar de unidade não transfere processo. |
| Menu principal | Acessar recursos do perfil e da unidade. | Entrada central para operações. | O menu é dinâmico e não representa todos os recursos existentes na instalação. |
| Controle de Processos | Exibir processos abertos recebidos e gerados na unidade. | Visão operacional e ações em lote. | Não mostra automaticamente processos concluídos, arquivados ou apenas acompanhados. |
| Painel de Controle | Resumir processos abertos, prazos, retornos, blocos, tipos, marcadores, atribuições e acompanhamentos. | Visão gerencial configurável. | É um painel da unidade; não substitui relatórios ou gestão de workflow. |
| Painel em Números | Exibir indicadores compactos, a partir do SEI 4.1. | Leitura rápida. | Detalhamento depende da configuração da unidade. |
| Atalhos de acessibilidade | Navegar entre tela, menu, árvore, pesquisa e editor pelo teclado. | Melhora acessibilidade e produtividade. | Alguns atalhos dependem do foco da tela/navegador. |
| Favoritos de processo | Criar atalho de acesso rápido ao processo. | Facilita localizar processos recorrentes. | Não duplica nem transforma o processo em modelo. |

## 2. Ciclo básico do processo

| Recurso | Para que serve | Vantagens | Limitações e comportamento |
|---|---|---|---|
| Iniciar Processo | Criar um novo processo e gerar NUP. | Padroniza tipo, assuntos, acesso e metadados. | Depende dos tipos de processo habilitados para órgão/unidade. |
| Receber Processo | Confirmar que usuário da unidade acessou o processo recebido. | Registra data, hora, unidade e usuário. | Processo aparece em vermelho até o recebimento. |
| Consultar/Alterar Processo | Consultar ou modificar descrição, interessados, destinatário, nível de acesso e observações. | Mantém metadados atualizados e pesquisáveis. | NUP e data de autuação não são livremente alteráveis; observações de outra unidade não podem ser editadas. |
| Atribuir Processo | Associar processo a usuário da unidade. | Distribui responsabilidade interna. | Não impede outros usuários da mesma unidade de atuar; não é visível a outras unidades. |
| Enviar Processo | Tramitar para uma ou várias unidades. | Permite fluxo sequencial ou paralelo. | Conclui a origem automaticamente, salvo “Manter aberto”; múltiplos destinos devem ter tarefas independentes. |
| Manter processo aberto na unidade atual | Preservar contexto ativo na origem durante o envio. | Permite trabalho paralelo legítimo. | Inflaciona tempo estatístico e aumenta risco de atuação duplicada se usado sem governança. |
| Atualizar Andamento | Registrar informação no histórico sem criar documento formal. | Registro rápido de evento operacional. | Não deve substituir despacho/decisão quando a informação precisar integrar formalmente os autos. |
| Ciência | Registrar que uma unidade tomou ciência. | Evita criar documento apenas para declarar ciência. | É um registro de ciência, não aprovação nem manifestação de mérito. |
| Concluir Processo | Encerrar o trabalho na unidade atual. | Retira da fila ativa e encerra tempo aberto naquela unidade. | Não conclui outras unidades; não arquiva; pode ser reaberto. |
| Reabrir Processo | Reativar processo anteriormente concluído na unidade. | Dispensa novo envio para unidade pela qual já tramitou. | Deve ser usado apenas para nova providência; atribui automaticamente ao usuário que reabriu. |
| Reabertura Programada | Programar reabertura na origem após envio, quando disponível. | Automatiza retorno do processo à fila da unidade em data/prazo. | Não aparece quando a origem foi mantida aberta; não equivale a Retorno Programado. |

## 3. Prazo, acompanhamento e organização interna

| Recurso | Para que serve | Vantagens | Limitações e comportamento |
|---|---|---|---|
| Controle de Prazos | Definir data ou prazo em dias para controle interno. | Agenda interna com indicação de prazo restante/vencido. | Só a unidade vê; concluir o controle não conclui o processo. |
| Retorno Programado | Definir prazo para outra unidade devolver o processo. | Cria controle bilateral de “aguardando retorno” e “para devolver”. | Não devolve automaticamente nem remove acesso no vencimento. |
| Acompanhamento Especial | Acompanhar atualizações mesmo sem manter o processo aberto. | Evita filas e estatísticas infladas; aceita grupos e observações. | É ferramenta de acompanhamento da unidade, não ato processual. |
| Marcadores | Etiquetar processos por cor, nome e texto. | Organização visual flexível. | Interno à unidade; não é transmitido no envio. |
| Anotações | Registrar orientação interna que não deve constar dos autos. | Comunicação rápida dentro da equipe. | Outra unidade não vê; não deve conter decisão formal. |
| Comentários | Registrar comentário em processo ou documento. | Comunicação contextual visível às unidades autorizadas. | Não integra a instrução processual; comentário em documento não assinado fica local até assinatura. |
| Bloco Interno | Agrupar processos semelhantes dentro da unidade. | Organização persistente e acompanhamento posterior. | Visível apenas à unidade; inclusão exige processo aberto na unidade. |
| Ponto de Controle | Atribuir fase/categoria de acompanhamento definida pela administração. | Permite indicadores e gráficos por etapa. | Não é motor de workflow obrigatório; depende de configuração por tipo de processo. |
| Plano de Trabalho | Sequenciar atividades previstas dentro do processo, disponível a partir da versão 4.1. | Organiza etapas, situações e documentos esperados. | Depende de planos administrativamente configurados; não substitui regras jurídicas do processo. |
| Estatísticas da Unidade | Medir quantidade e tempo de processos. | Apoia gestão de desempenho. | Permanência aberta sem atividade é contabilizada; qualidade depende do uso correto de concluir. |
| Desempenho de Processos | Comparar quantidade e tempo médio por tipo. | Visão por tipologia. | Indicador pode ser distorcido por processos mantidos abertos sem necessidade. |
| Relatório de Atividades | Consultar atividades de usuário/unidade, a partir do SEI 4.1. | Auditoria operacional e gestão. | Não substitui log técnico nem auditoria completa. |

## 4. Relações e situações especiais do processo

| Recurso | Para que serve | Vantagens | Limitações e comportamento |
|---|---|---|---|
| Relacionar Processos | Criar vínculo virtual entre processos. | Mantém NUPs, árvores e andamentos independentes. | Relação não funde documentos nem torna um processo subordinado ao outro. |
| Anexar Processo | Incorporar permanentemente um processo a outro. | Consolida processos cuja continuidade deve ocorrer no principal. | Ação normalmente irreversível pelo usuário; exige processo aberto apenas na unidade e impede novas alterações no anexado. |
| Duplicar Processo | Criar novo processo a partir de documentos de outro. | Reutiliza estrutura e conteúdo. | Gera outro NUP; não mantém identidade nem sincronização com o original. |
| Sobrestar Processo | Suspender temporariamente o trâmite para aguardar providência. | Retira da fila comum e registra motivo/vínculo. | Não é conclusão nem arquivo; deve haver fundamento e posterior remoção do sobrestamento. |
| Processos Sobrestados | Listar e administrar processos suspensos na unidade. | Centraliza acompanhamento da suspensão. | Só representa sobrestamentos da unidade/contexto aplicável. |
| Excluir Processo | Excluir processo gerado indevidamente, dentro das regras do sistema. | Corrige autuação indevida. | Fortemente limitado; processos com tramitação/documentos/atos geralmente não podem ser simplesmente eliminados. |
| Filtro Linha Direta | Mostrar apenas documentos de unidades com comunicação direta com a unidade atual. | Reduz ruído em processos muito distribuídos. | Oculta parte da árvore sem excluir; pode gerar interpretação errada se o usuário esquecer que o filtro está ativo. |

## 5. Documentos

| Recurso | Para que serve | Vantagens | Limitações e comportamento |
|---|---|---|---|
| Incluir Documento Interno | Criar documento HTML no editor do SEI. | Modelos, variáveis, versões e assinatura integradas. | Não é DOCX; fidelidade e recursos de layout são menores que editores de escritório completos. |
| Incluir Documento Externo | Inserir arquivo produzido fora do sistema. | Preserva documento recebido/produzido em outra ferramenta. | Extensão e tamanho dependem da configuração; conteúdo pode não ser pesquisável sem texto/OCR. |
| Formulário do Sistema | Criar documento estruturado por campos. | Validação, máscaras, listas e obrigatoriedade. | Layout visual é limitado; não serve bem para documentos de aparência complexa. |
| Editar Conteúdo | Produzir ou alterar minuta no editor. | Controle de versão e estilos institucionais. | Documento assinado e já conhecido por outra unidade deixa de ser editável. |
| Versões do Documento | Registrar e comparar alterações. | Rastreabilidade da minuta. | Não substitui versionamento de arquivos externos nem controle de mudança de um editor colaborativo em tempo real. |
| Assinar Documento | Aplicar assinatura por senha ou certificado digital. | Autenticidade, autoria e integridade. | Cargo/função e permissão precisam estar configurados; assinatura não corrige conteúdo inadequado. |
| Consultar Assinaturas | Ver assinantes e dados de autenticação. | Verificação rápida. | Validade jurídica depende do tipo de assinatura e da cadeia de validação aplicável. |
| Excluir Documento | Retirar documento incluído indevidamente quando as regras permitem. | Corrige erro antes de consolidação/tramitação. | Pode ser bloqueado após assinatura, acesso externo, tramitação ou outras dependências. |
| Cancelar Documento | Tornar documento sem efeito preservando seu registro. | Mantém rastreabilidade. | Documento cancelado não é convertido no PDF do processo; cancelamento não deve apagar a história. |
| Mover Documento Externo | Transferir documento externo para outro processo. | Corrige protocolo em pasta errada. | Documentos internos gerados no SEI não são movidos; podem ser referenciados. |
| Ordenar Árvore | Alterar ordem visual dos documentos. | Melhora compreensão quando cronologia de inclusão ficou inadequada. | Não muda datas nem histórico; uso excessivo pode ocultar a sequência real de produção. |
| Referenciar Processo/Documento | Inserir link interno em outro documento. | Evita duplicação e mantém navegação. | O acesso continua sujeito às permissões do item referenciado. |
| Favorito de Documento | Salvar documento inteiro como modelo de conteúdo. | Reutiliza formato e texto de um documento anterior. | A cópia futura é independente; alterações não voltam ao original. |
| Texto Padrão/AutoTexto | Reutilizar fragmento editável em documentos e e-mails. | Padronização e produtividade. | Não representa documento completo nem regra de negócio; precisa de manutenção textual. |
| Publicar/Agendar Publicação | Preparar publicação em veículo configurado e, quando cabível, agendar data. | Integra produção documental e publicidade oficial. | Depende de veículo, permissões e configuração; agendar não garante publicação externa sem integração adequada. |
| Autenticar Documento Externo | Registrar autenticação de documento digitalizado. | Identifica conferência com original/cópia. | Aplicável a documentos externos digitalizados e dentro das regras da unidade protocolizadora. |
| Circular | Gerar documentos semelhantes para vários destinatários/contatos. | Automatiza comunicação em massa com personalização. | Qualidade depende do cadastro de contatos; pode gerar grande quantidade de documentos. |
| Imprimir Web | Imprimir documento produzido no editor. | Saída rápida. | Disponível para documentos internos do editor, não para qualquer anexo externo. |

## 6. Colaboração e compartilhamento

| Recurso | Para que serve | Vantagens | Limitações e comportamento |
|---|---|---|---|
| Bloco de Assinatura | Disponibilizar minutas para edição/assinatura por outra unidade ou assinatura em lote. | Evita tramitar o processo só para colher assinatura. | Deve ser devolvido/cancelado/concluído corretamente; não transfere responsabilidade formal pelo processo. |
| Bloco de Reunião | Disponibilizar processos e minutas para conhecimento/discussão. | Permite ver documentos não assinados sem atuação formal. | Não autoriza atos de tramitação; é ambiente temporário de consulta. |
| Enviar Correspondência Eletrônica | Enviar e-mail relacionado ao processo, com anexos. | Mantém registro de comunicação no contexto do processo. | Entrega depende do SMTP; e-mail não substitui trâmite ou documento formal quando exigido. |
| Gerenciar Acesso Externo | Liberar consulta a usuário externo por link/autorização. | Compartilha documentos sem criar usuário interno. | Deve limitar prazo e conteúdo; envolve dados pessoais e regras de sigilo. |
| Assinatura Externa | Permitir que usuário externo assine documento. | Formaliza participação de fornecedores, advogados e interessados. | Exige cadastro/liberação e definição precisa do escopo de visualização. |
| Grupos de Contatos | Reunir contatos cadastrados. | Seleção em massa de pessoas/entidades. | Não cria permissões nem unidade de trabalho. |
| Grupos de E-mail | Reunir endereços para mensagens. | Comunicação em massa. | Não é lista de acesso ao processo. |
| Grupos de Envio | Reunir unidades para tramitação. | Agiliza envio a várias unidades. | Deve ser usado apenas quando as tarefas forem adequadamente paralelas. |

## 7. Pesquisa, conhecimento e exportação

| Recurso | Para que serve | Vantagens | Limitações e comportamento |
|---|---|---|---|
| Pesquisa Rápida | Localizar NUP, protocolo ou termo simples. | Acesso direto e rápido. | Resultados sujeitos a nível de acesso e tempo de indexação. |
| Pesquisa Estruturada | Combinar filtros de órgão, unidade, assunto, contato, assinatura, datas e texto. | Recuperação precisa. | Qualidade depende de metadados bem preenchidos e índice atualizado. |
| Pesquisar no Processo | Localizar termo dentro de processo volumoso. | Reduz navegação manual. | Minutas de outra unidade e arquivos sem texto/OCR podem não ser localizados. |
| Histórico/Consultar Andamento | Consultar ações, data, unidade e usuário. | Rastreabilidade operacional. | Atualização de andamento textual não equivale a documento formal assinado. |
| Base de Conhecimento | Descrever procedimento associado a tipos de processo, com versões, links e referências. | Preserva conhecimento institucional e orienta execução. | Não executa o fluxo automaticamente; conteúdo desatualizado pode induzir erro. |
| Gerar PDF | Consolidar documentos selecionados em PDF. | Facilita consulta, download e compartilhamento. | Operação imediata pode ser pesada; formatos não convertíveis, cancelados e minutas de outras unidades são excluídos. |
| Gerar ZIP | Baixar documentos selecionados em pacote. | Preserva arquivos originais e diferentes formatos. | Pode gerar arquivo grande; não cria uma representação visual consolidada. |
| Lixeira, desde 5.0 | Disponibilizar temporariamente conteúdo excluído/cancelado ao próprio autor da ação. | Recuperação operacional limitada. | Não é arquivo permanente nem recuperação irrestrita; depende de retenção/limpeza. |

## 8. O que não deve ser confundido

| Não confundir | Diferença |
|---|---|
| Concluir processo × concluir controle de prazo | O primeiro fecha o contexto da unidade; o segundo marca apenas o lembrete como cumprido. |
| Controle de prazo × Retorno Programado | O primeiro é interno; o segundo estabelece prazo de devolução entre unidades. |
| Acompanhamento Especial × manter processo aberto | Acompanhamento observa sem manter contexto ativo; manter aberto continua contando tempo. |
| Comentário × despacho | Comentário não integra a instrução; despacho é documento formal. |
| Relação × anexação | Relação mantém processos independentes; anexação incorpora permanentemente um ao outro. |
| Favorito de processo × favorito de documento | Processo favorito é atalho; documento favorito é modelo de conteúdo. |
| Texto Padrão × modelo do Editor | Texto padrão é fragmento; modelo define estrutura institucional do documento. |
| Conclusão × arquivamento | Conclusão encerra trabalho da unidade; arquivo inicia gestão de guarda e bloqueia novos atos. |

## Fontes principais

- [Iniciando Operações][U1]
- [Operações Básicas com Processos][U2]
- [Operações de Manutenção e Acompanhamento][U3]
- [Outras Operações com Processos][U4]
- [Operações Básicas com Documentos][U5]
- [Outras Operações com Documentos][U6]
- [Blocos][U7]
- [Acompanhando e Recuperando Informações][U8]

[U1]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Iniciando_operacoes.html
[U2]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_basicas_com_processos.html
[U3]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_de_manutencao_e_acompanhamento_de_processos.html
[U4]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Outras_operacoes_com_processos.html
[U5]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Operacoes_basicas_com_documentos.html
[U6]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Outras_operacoes_com_documentos.html
[U7]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Blocos.html
[U8]: https://manuais.processoeletronico.gov.br/pt-br/latest/SEI/Acompanhando_e_recuperando_informacoes_de_processos.html
