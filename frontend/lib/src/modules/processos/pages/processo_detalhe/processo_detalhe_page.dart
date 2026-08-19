import 'dart:async' show StreamController, unawaited;

import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_acompanhamentos/processo_acompanhamentos_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_andamentos/processo_andamentos_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_anotacoes/processo_anotacoes_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_bases_conhecimento/processo_bases_conhecimento_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_blocos/processo_blocos_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_cabecalho/processo_cabecalho_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_controles_prazo/processo_controles_prazo_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_documento_conteudo/processo_documento_conteudo_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_documentos/processo_documentos_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_marcadores/processo_marcadores_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_participantes/processo_participantes_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_relacionados/processo_relacionados_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_retornos_programados/processo_retornos_programados_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_unidades_abertas/processo_unidades_abertas_component.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';
import 'package:sei_frontend/src/shared/routes/route_paths.dart';
import 'package:sei_frontend/src/shared/services/sessao_unidade_service.dart';

/// Página que exibe o detalhe somente leitura de um processo selecionado nas
/// filas do SEI.
///
/// É o container da tela: carrega o processo base (cabeçalho) para confirmar
/// que ele existe e conecta a navegação de retorno. Cada seção — documentos,
/// andamentos, unidades abertas, relacionados, participantes, marcadores,
/// acompanhamentos, controles de prazo, anotações, retornos programados,
/// blocos e bases de conhecimento — é um componente próprio que carrega seus
/// próprios dados, reduzindo o acoplamento com esta página.
///
/// Roteada em `RoutePaths.processoDetalhe` (`/processos/:idProcesso`):
/// [idProcesso] continua `@Input()` — útil para uso embutido e para teste —,
/// mas quando o `ngrouter` instancia esta página via rota, [onActivate] lê o
/// parâmetro da URL, que é a fonte de verdade nesse caso. [idUnidade] segue
/// o mesmo caminho: como a rota não tem um pai de template que faça o
/// binding, o valor vem de [SessaoUnidadeService], escrito por quem
/// selecionou a unidade em `CatalogoPage`.
@Component(
  selector: 'sei-processo-detalhe-page',
  templateUrl: 'processo_detalhe_page.html',
  styleUrls: <String>['processo_detalhe_page.css'],
  directives: <Type>[
    NgIf,
    ProcessoCabecalhoComponent,
    ProcessoDocumentosComponent,
    ProcessoDocumentoConteudoComponent,
    ProcessoAndamentosComponent,
    ProcessoUnidadesAbertasComponent,
    ProcessoRelacionadosComponent,
    ProcessoParticipantesComponent,
    ProcessoMarcadoresComponent,
    ProcessoAcompanhamentosComponent,
    ProcessoControlesPrazoComponent,
    ProcessoAnotacoesComponent,
    ProcessoRetornosProgramadosComponent,
    ProcessoBlocosComponent,
    ProcessoBasesConhecimentoComponent,
  ],
  providers: <Provider>[ClassProvider(ProcessoDetalheService)],
)
class ProcessoDetalhePage implements AfterChanges, OnActivate, OnDestroy {
  ProcessoDetalhePage(this._service, this._sessaoUnidade, this._router);

  final ProcessoDetalheService _service;
  final SessaoUnidadeService _sessaoUnidade;
  final Router _router;
  final StreamController<void> _retornoSolicitadoController =
      StreamController<void>.broadcast();

  /// Identificador textual do processo, preservado sem perda de precisão.
  @Input()
  String idProcesso = '';

  /// Unidade selecionada no contexto de desenvolvimento, usada pelas seções
  /// que dependem de unidade (anotações e controles de prazo).
  @Input()
  int? idUnidade;

  /// Solicita que o contêiner retorne à consulta que originou o detalhe.
  @Output()
  Stream<void> get retornoSolicitado => _retornoSolicitadoController.stream;

  ProcessoCabecalho? cabecalho;
  String mensagemErro = '';
  bool carregandoCabecalho = false;

  /// Documento escolhido na árvore de documentos, para exibir o conteúdo
  /// dele em `sei-processo-documento-conteudo` sem acoplar as duas seções
  /// diretamente entre si.
  String idDocumentoSelecionado = '';

  int _versaoConsulta = 0;
  String _ultimoIdProcesso = '';

  @override
  void ngAfterChanges() {
    if (idProcesso.isEmpty || idProcesso == _ultimoIdProcesso) {
      return;
    }
    _ultimoIdProcesso = idProcesso;
    cabecalho = null;
    mensagemErro = '';
    idDocumentoSelecionado = '';
    unawaited(_carregarCabecalho(idProcesso));
  }

  /// Lê `idProcesso` da URL quando esta página é ativada pelo `ngrouter` e
  /// busca a unidade selecionada em [SessaoUnidadeService], já que a rota
  /// não tem um template pai que faça o binding de `@Input()`.
  @override
  void onActivate(RouterState? previous, RouterState current) {
    final String? idDaRota = current.parameters['idProcesso'];
    if (idDaRota != null && idDaRota.isNotEmpty) {
      idProcesso = idDaRota;
    }
    idUnidade = _sessaoUnidade.idUnidadeSelecionada;
    // Força `ngAfterChanges` a recarregar mesmo se `idProcesso` não mudou
    // (por exemplo, ao reabrir o mesmo processo a partir de outra página).
    _ultimoIdProcesso = '';
    ngAfterChanges();
  }

  /// Retorna à lista sem iniciar uma alteração no processo selecionado.
  ///
  /// Emite [retornoSolicitado] para quem estiver ouvindo (uso embutido) e
  /// também navega de volta para [RoutePaths.raiz], que é o caminho real
  /// quando esta página foi aberta pela rota `/processos/:idProcesso`.
  void solicitarRetorno() {
    _retornoSolicitadoController.add(null);
    unawaited(_router.navigate(RoutePaths.raiz.toUrl()));
  }

  /// Guarda o documento escolhido na árvore para carregar o conteúdo dele.
  void selecionarDocumento(String idDocumento) {
    idDocumentoSelecionado = idDocumento;
  }

  Future<void> _carregarCabecalho(String idConsulta) async {
    final int versaoConsulta = ++_versaoConsulta;
    carregandoCabecalho = true;
    mensagemErro = '';
    try {
      final ProcessoCabecalho resultado =
          await _service.obterCabecalho(idConsulta);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      cabecalho = resultado;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = 'Não foi possível carregar o detalhe do processo.';
      }
    } finally {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        carregandoCabecalho = false;
      }
    }
  }

  bool _consultaAtual(int versaoConsulta, String idConsulta) {
    return versaoConsulta == _versaoConsulta && idConsulta == idProcesso;
  }

  @override
  void ngOnDestroy() {
    unawaited(_retornoSolicitadoController.close());
  }
}
