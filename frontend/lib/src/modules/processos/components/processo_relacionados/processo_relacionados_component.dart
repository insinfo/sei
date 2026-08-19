import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Lista os processos relacionados ao processo consultado.
///
/// Processos relacionados não tramitam juntos e não têm hierarquia entre si;
/// o vínculo é só de afinidade temática e aparece nos dois sentidos.
@Component(
  selector: 'sei-processo-relacionados',
  templateUrl: 'processo_relacionados_component.html',
  styleUrls: <String>['processo_relacionados_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoRelacionadosComponent implements AfterChanges, OnDestroy {
  ProcessoRelacionadosComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  List<ProcessoRelacionado> relacionados = const <ProcessoRelacionado>[];
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
    relacionados = const <ProcessoRelacionado>[];
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
      final List<ProcessoRelacionado> resultado =
          await _service.listarRelacionados(idConsulta);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      relacionados = resultado;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = 'Não foi possível carregar os processos relacionados.';
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
