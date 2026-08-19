import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Lista os acompanhamentos especiais registrados para o processo.
///
/// Diferente do Bloco Interno, o Acompanhamento Especial não exige que o
/// processo esteja aberto na unidade que acompanha.
@Component(
  selector: 'sei-processo-acompanhamentos',
  templateUrl: 'processo_acompanhamentos_component.html',
  styleUrls: <String>['processo_acompanhamentos_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoAcompanhamentosComponent implements AfterChanges, OnDestroy {
  ProcessoAcompanhamentosComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  List<ProcessoAcompanhamento> acompanhamentos =
      const <ProcessoAcompanhamento>[];
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
    acompanhamentos = const <ProcessoAcompanhamento>[];
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
      final List<ProcessoAcompanhamento> resultado =
          await _service.listarAcompanhamentos(idConsulta);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      acompanhamentos = resultado;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro =
            'Não foi possível carregar os acompanhamentos especiais do processo.';
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
