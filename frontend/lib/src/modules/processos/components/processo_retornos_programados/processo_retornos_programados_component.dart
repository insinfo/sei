import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Lista os retornos programados (prazos de devolução) do processo.
///
/// O manual do SEI é explícito: este recurso só determina prazos, não
/// retira o acesso da unidade demandada nem devolve o processo
/// automaticamente ao vencer.
@Component(
  selector: 'sei-processo-retornos-programados',
  templateUrl: 'processo_retornos_programados_component.html',
  styleUrls: <String>['processo_retornos_programados_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoRetornosProgramadosComponent implements AfterChanges, OnDestroy {
  ProcessoRetornosProgramadosComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  List<ProcessoRetornoProgramado> retornos =
      const <ProcessoRetornoProgramado>[];
  String mensagemErro = '';
  bool carregando = false;
  bool carregado = false;

  int _versaoConsulta = 0;
  String _ultimoIdProcesso = '';

  @override
  void ngAfterChanges() {
    if (idProcesso.isEmpty || idProcesso == _ultimoIdProcesso) {
      return;
    }
    _ultimoIdProcesso = idProcesso;
    retornos = const <ProcessoRetornoProgramado>[];
    carregado = false;
    mensagemErro = '';
    unawaited(_carregar());
  }

  Future<void> _carregar() async {
    final String idConsulta = idProcesso;
    final int versaoConsulta = ++_versaoConsulta;
    carregando = true;
    mensagemErro = '';
    try {
      final List<ProcessoRetornoProgramado> resultado =
          await _service.listarRetornosProgramados(idConsulta);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      retornos = resultado;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro =
            'Não foi possível carregar os retornos programados do processo.';
      }
    } finally {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        carregando = false;
      }
    }
  }

  bool _consultaAtual(int versaoConsulta, String idConsulta) {
    return versaoConsulta == _versaoConsulta && idConsulta == idProcesso;
  }

  @override
  void ngOnDestroy() {}
}
