import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Lista as unidades em que o processo está aberto no momento.
///
/// No SEI o estado aberto/concluído não pertence ao processo inteiro: ele
/// pertence ao par processo-unidade. Concluir em uma unidade não conclui nas
/// demais, por isso esta seção mostra uma linha por unidade em aberto, com a
/// data de abertura e se o processo foi gerado ali ou apenas recebido.
@Component(
  selector: 'sei-processo-unidades-abertas',
  templateUrl: 'processo_unidades_abertas_component.html',
  styleUrls: <String>['processo_unidades_abertas_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoUnidadesAbertasComponent implements AfterChanges, OnDestroy {
  ProcessoUnidadesAbertasComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  List<ProcessoUnidadeAberta> unidades = const <ProcessoUnidadeAberta>[];
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
    unidades = const <ProcessoUnidadeAberta>[];
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
      final List<ProcessoUnidadeAberta> resultado =
          await _service.listarUnidadesAbertas(idConsulta);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      unidades = resultado;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro =
            'Não foi possível carregar as unidades em que o processo está aberto.';
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
