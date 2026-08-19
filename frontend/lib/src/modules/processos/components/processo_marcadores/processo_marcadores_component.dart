import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Lista os marcadores vigentes atribuídos ao processo.
@Component(
  selector: 'sei-processo-marcadores',
  templateUrl: 'processo_marcadores_component.html',
  styleUrls: <String>['processo_marcadores_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoMarcadoresComponent implements AfterChanges, OnDestroy {
  ProcessoMarcadoresComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  List<ProcessoMarcador> marcadores = const <ProcessoMarcador>[];
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
    marcadores = const <ProcessoMarcador>[];
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
      final List<ProcessoMarcador> resultado =
          await _service.listarMarcadores(idConsulta);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      marcadores = resultado;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = 'Não foi possível carregar os marcadores do processo.';
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
