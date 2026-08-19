import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Lista os interessados, remetentes e destinatários vinculados ao processo.
@Component(
  selector: 'sei-processo-participantes',
  templateUrl: 'processo_participantes_component.html',
  styleUrls: <String>['processo_participantes_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoParticipantesComponent implements AfterChanges, OnDestroy {
  ProcessoParticipantesComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  List<ProcessoParticipante> participantes = const <ProcessoParticipante>[];
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
    participantes = const <ProcessoParticipante>[];
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
      final List<ProcessoParticipante> resultado =
          await _service.listarParticipantes(idConsulta);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      participantes = resultado;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro =
            'Não foi possível carregar os participantes do processo.';
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
