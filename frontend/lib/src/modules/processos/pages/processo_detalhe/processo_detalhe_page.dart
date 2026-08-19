import 'dart:async' show StreamController, unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_acompanhamentos/processo_acompanhamentos_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_andamentos/processo_andamentos_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_anotacoes/processo_anotacoes_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_cabecalho/processo_cabecalho_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_controles_prazo/processo_controles_prazo_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_documentos/processo_documentos_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_marcadores/processo_marcadores_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_participantes/processo_participantes_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_relacionados/processo_relacionados_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_retornos_programados/processo_retornos_programados_component.dart';
import 'package:sei_frontend/src/modules/processos/components/processo_unidades_abertas/processo_unidades_abertas_component.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Página que exibe o detalhe somente leitura de um processo selecionado nas
/// filas do SEI.
///
/// É o container da tela: carrega o processo base (cabeçalho) para confirmar
/// que ele existe e conecta a navegação de retorno. Cada seção — documentos,
/// andamentos, unidades abertas, relacionados, participantes, marcadores,
/// acompanhamentos, controles de prazo, anotações e retornos programados — é
/// um componente próprio que carrega seus próprios dados, reduzindo o
/// acoplamento com esta página.
@Component(
  selector: 'sei-processo-detalhe-page',
  templateUrl: 'processo_detalhe_page.html',
  styleUrls: <String>['processo_detalhe_page.css'],
  directives: <Type>[
    NgIf,
    ProcessoCabecalhoComponent,
    ProcessoDocumentosComponent,
    ProcessoAndamentosComponent,
    ProcessoUnidadesAbertasComponent,
    ProcessoRelacionadosComponent,
    ProcessoParticipantesComponent,
    ProcessoMarcadoresComponent,
    ProcessoAcompanhamentosComponent,
    ProcessoControlesPrazoComponent,
    ProcessoAnotacoesComponent,
    ProcessoRetornosProgramadosComponent,
  ],
  providers: <Provider>[ClassProvider(ProcessoDetalheService)],
)
class ProcessoDetalhePage implements AfterChanges, OnDestroy {
  ProcessoDetalhePage(this._service);

  final ProcessoDetalheService _service;
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
    unawaited(_carregarCabecalho(idProcesso));
  }

  /// Retorna à lista sem iniciar uma alteração no processo selecionado.
  void solicitarRetorno() {
    _retornoSolicitadoController.add(null);
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
