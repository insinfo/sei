import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Lista os prazos internos de controle da unidade sobre o processo.
///
/// É um recurso de organização interna: só mostra os prazos criados pela
/// unidade selecionada no contexto de desenvolvimento, por isso depende de
/// [idUnidade] estar definido.
@Component(
  selector: 'sei-processo-controles-prazo',
  templateUrl: 'processo_controles_prazo_component.html',
  styleUrls: <String>['processo_controles_prazo_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoControlesPrazoComponent implements AfterChanges, OnDestroy {
  ProcessoControlesPrazoComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  @Input()
  int? idUnidade;

  List<ProcessoControlePrazo> controles = const <ProcessoControlePrazo>[];
  String mensagemErro = '';
  bool carregando = false;
  bool carregado = false;
  bool exibirAguardandoUnidade = false;

  int _versaoConsulta = 0;
  String _ultimaChave = '';

  @override
  void ngAfterChanges() {
    final String chave = '$idProcesso/${idUnidade ?? ''}';
    if (idProcesso.isEmpty || chave == _ultimaChave) {
      return;
    }
    _ultimaChave = chave;
    controles = const <ProcessoControlePrazo>[];
    carregado = false;
    mensagemErro = '';
    final int? unidade = idUnidade;
    if (unidade == null) {
      exibirAguardandoUnidade = true;
      return;
    }
    exibirAguardandoUnidade = false;
    unawaited(_carregar(unidade));
  }

  Future<void> _carregar(int unidade) async {
    final String idConsulta = idProcesso;
    final int versaoConsulta = ++_versaoConsulta;
    carregando = true;
    mensagemErro = '';
    try {
      final List<ProcessoControlePrazo> resultado =
          await _service.listarControlesPrazo(idConsulta, unidade);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      controles = resultado;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro =
            'Não foi possível carregar os controles de prazo do processo.';
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
