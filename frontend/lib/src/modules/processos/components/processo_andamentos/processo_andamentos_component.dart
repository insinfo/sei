import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Exibe o histórico cronológico de andamentos do processo, carregado sob
/// demanda.
@Component(
  selector: 'sei-processo-andamentos',
  templateUrl: 'processo_andamentos_component.html',
  styleUrls: <String>['processo_andamentos_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoAndamentosComponent implements AfterChanges, OnDestroy {
  ProcessoAndamentosComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  List<ProcessoAndamentoItem> andamentos = const <ProcessoAndamentoItem>[];
  String? proximoCursor;
  String mensagemErro = '';
  bool carregando = false;
  bool carregado = false;
  bool podeCarregarMais = false;

  String _ultimoIdProcesso = '';

  @override
  void ngAfterChanges() {
    if (idProcesso == _ultimoIdProcesso) {
      return;
    }
    _ultimoIdProcesso = idProcesso;
    _limparEstado();
  }

  /// Carrega a primeira página do histórico quando o usuário pedir.
  void solicitarAndamentos() {
    if (carregando) {
      return;
    }
    unawaited(_carregar());
  }

  /// Carrega a próxima página quando o cursor estiver disponível.
  void solicitarMais() {
    if (carregando || !podeCarregarMais) {
      return;
    }
    unawaited(_carregar(cursor: proximoCursor));
  }

  Future<void> _carregar({String? cursor}) async {
    final String idConsulta = idProcesso;
    carregando = true;
    mensagemErro = '';
    try {
      final PaginaProcessoAndamentos pagina =
          await _service.listarAndamentos(idConsulta, cursor: cursor);
      if (idConsulta != idProcesso) {
        return;
      }
      andamentos = cursor == null
          ? pagina.itens
          : <ProcessoAndamentoItem>[...andamentos, ...pagina.itens];
      proximoCursor = pagina.proximoCursor;
      podeCarregarMais = pagina.temProximaPagina;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (idConsulta == idProcesso) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (idConsulta == idProcesso) {
        mensagemErro = 'Não foi possível carregar o histórico do processo.';
      }
    } finally {
      if (idConsulta == idProcesso) {
        carregando = false;
      }
    }
  }

  void _limparEstado() {
    andamentos = const <ProcessoAndamentoItem>[];
    proximoCursor = null;
    mensagemErro = '';
    carregando = false;
    carregado = false;
    podeCarregarMais = false;
  }

  @override
  void ngOnDestroy() {}
}
