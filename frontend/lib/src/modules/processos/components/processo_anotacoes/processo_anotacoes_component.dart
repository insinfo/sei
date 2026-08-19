import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Lista as anotações do processo visíveis para a unidade selecionada.
///
/// A visibilidade da anotação é exclusiva da unidade que a criou, por isso
/// depende de [idUnidade] estar definido.
@Component(
  selector: 'sei-processo-anotacoes',
  templateUrl: 'processo_anotacoes_component.html',
  styleUrls: <String>['processo_anotacoes_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoAnotacoesComponent implements AfterChanges, OnDestroy {
  ProcessoAnotacoesComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  @Input()
  int? idUnidade;

  List<ProcessoAnotacao> anotacoes = const <ProcessoAnotacao>[];
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
    anotacoes = const <ProcessoAnotacao>[];
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
      final List<ProcessoAnotacao> resultado =
          await _service.listarAnotacoes(idConsulta, unidade);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      anotacoes = resultado;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = 'Não foi possível carregar as anotações do processo.';
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
