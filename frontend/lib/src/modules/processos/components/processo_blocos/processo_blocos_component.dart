import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Rótulo em português para exibição de [TipoBloco] na tela.
extension TipoBlocoRotulo on TipoBloco {
  String get rotulo {
    switch (this) {
      case TipoBloco.assinatura:
        return 'Assinatura';
      case TipoBloco.reuniao:
        return 'Reunião';
      case TipoBloco.interno:
        return 'Interno';
    }
  }
}

/// Rótulo em português para exibição de [EstadoBloco] na tela.
extension EstadoBlocoRotulo on EstadoBloco {
  String get rotulo {
    switch (this) {
      case EstadoBloco.gerado:
        return 'Gerado';
      case EstadoBloco.disponibilizado:
        return 'Disponibilizado';
      case EstadoBloco.concluido:
        return 'Concluído';
    }
  }
}

/// Lista os blocos (Assinatura, Reunião ou Interno) que contêm o processo.
@Component(
  selector: 'sei-processo-blocos',
  templateUrl: 'processo_blocos_component.html',
  styleUrls: <String>['processo_blocos_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoBlocosComponent implements AfterChanges, OnDestroy {
  ProcessoBlocosComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  List<ProcessoBloco> blocos = const <ProcessoBloco>[];
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
    blocos = const <ProcessoBloco>[];
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
      final List<ProcessoBloco> resultado =
          await _service.listarBlocos(idConsulta);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      blocos = resultado;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = 'Não foi possível carregar os blocos do processo.';
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
