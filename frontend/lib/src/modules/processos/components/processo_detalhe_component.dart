import 'dart:async' show StreamController, unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Exibe o detalhe somente leitura de um processo selecionado nas filas SEI.
///
/// O cabeçalho é carregado ao receber um processo novo. Árvore e histórico são
/// intencionalmente carregados sob demanda para não transferir dados
/// documentais desnecessários ao abrir a tela.
@Component(
  selector: 'sei-processo-detalhe',
  templateUrl: 'processo_detalhe_component.html',
  styleUrls: <String>['processo_detalhe_component.css'],
  directives: <Type>[NgIf, NgFor],
  providers: <Provider>[ClassProvider(ProcessoDetalheService)],
)
class ProcessoDetalheComponent implements AfterChanges, OnDestroy {
  ProcessoDetalheComponent(this._service);

  final ProcessoDetalheService _service;
  final StreamController<void> _retornoSolicitadoController =
      StreamController<void>.broadcast();

  /// Identificador textual do processo, preservado sem perda de precisão.
  @Input()
  String idProcesso = '';

  /// Solicita que o contêiner retorne à consulta que originou o detalhe.
  @Output()
  Stream<void> get retornoSolicitado => _retornoSolicitadoController.stream;

  ProcessoCabecalho? cabecalho;
  List<ProcessoArvoreDocumentoItem> documentos =
      const <ProcessoArvoreDocumentoItem>[];
  List<ProcessoAndamentoItem> andamentos = const <ProcessoAndamentoItem>[];
  String? proximoCursorDocumentos;
  String? proximoCursorAndamentos;
  String mensagemErro = '';
  String mensagemErroDocumentos = '';
  String mensagemErroAndamentos = '';
  bool carregandoCabecalho = false;
  bool carregandoDocumentos = false;
  bool carregandoAndamentos = false;
  bool documentosCarregados = false;
  bool andamentosCarregados = false;
  bool podeCarregarMaisDocumentos = false;
  bool podeCarregarMaisAndamentos = false;
  int _versaoConsulta = 0;
  String _ultimoIdProcesso = '';

  @override
  void ngAfterChanges() {
    if (idProcesso.isEmpty || idProcesso == _ultimoIdProcesso) {
      return;
    }
    _ultimoIdProcesso = idProcesso;
    _limparEstado();
    unawaited(_carregarCabecalho(idProcesso));
  }

  /// Retorna à lista sem iniciar uma alteração no processo selecionado.
  void solicitarRetorno() {
    _retornoSolicitadoController.add(null);
  }

  /// Carrega a primeira página da árvore documental quando o usuário pedir.
  void solicitarDocumentos() {
    if (carregandoDocumentos) {
      return;
    }
    unawaited(_carregarDocumentos());
  }

  /// Carrega a próxima página da árvore quando o cursor estiver disponível.
  void solicitarMaisDocumentos() {
    if (carregandoDocumentos || !podeCarregarMaisDocumentos) {
      return;
    }
    unawaited(_carregarDocumentos(cursor: proximoCursorDocumentos));
  }

  /// Carrega a primeira página do histórico quando o usuário pedir.
  void solicitarAndamentos() {
    if (carregandoAndamentos) {
      return;
    }
    unawaited(_carregarAndamentos());
  }

  /// Carrega a próxima página do histórico quando o cursor estiver disponível.
  void solicitarMaisAndamentos() {
    if (carregandoAndamentos || !podeCarregarMaisAndamentos) {
      return;
    }
    unawaited(_carregarAndamentos(cursor: proximoCursorAndamentos));
  }

  Future<void> _carregarCabecalho(String idConsulta) async {
    final int versaoConsulta = ++_versaoConsulta;
    carregandoCabecalho = true;
    mensagemErro = '';
    try {
      final resultado = await _service.obterCabecalho(idConsulta);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      cabecalho = resultado;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = 'Não foi possível carregar o detalhe do processo.';
      }
    } finally {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        carregandoCabecalho = false;
      }
    }
  }

  Future<void> _carregarDocumentos({String? cursor}) async {
    final String idConsulta = idProcesso;
    carregandoDocumentos = true;
    mensagemErroDocumentos = '';
    try {
      final pagina = await _service.listarDocumentos(
        idConsulta,
        cursor: cursor,
      );
      if (idConsulta != idProcesso) {
        return;
      }
      documentos = cursor == null
          ? pagina.itens
          : <ProcessoArvoreDocumentoItem>[...documentos, ...pagina.itens];
      proximoCursorDocumentos = pagina.proximoCursor;
      podeCarregarMaisDocumentos = pagina.temProximaPagina;
      documentosCarregados = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (idConsulta == idProcesso) {
        mensagemErroDocumentos = excecao.mensagem;
      }
    } catch (_) {
      if (idConsulta == idProcesso) {
        mensagemErroDocumentos =
            'Não foi possível carregar os documentos do processo.';
      }
    } finally {
      if (idConsulta == idProcesso) {
        carregandoDocumentos = false;
      }
    }
  }

  Future<void> _carregarAndamentos({String? cursor}) async {
    final String idConsulta = idProcesso;
    carregandoAndamentos = true;
    mensagemErroAndamentos = '';
    try {
      final pagina = await _service.listarAndamentos(
        idConsulta,
        cursor: cursor,
      );
      if (idConsulta != idProcesso) {
        return;
      }
      andamentos = cursor == null
          ? pagina.itens
          : <ProcessoAndamentoItem>[...andamentos, ...pagina.itens];
      proximoCursorAndamentos = pagina.proximoCursor;
      podeCarregarMaisAndamentos = pagina.temProximaPagina;
      andamentosCarregados = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (idConsulta == idProcesso) {
        mensagemErroAndamentos = excecao.mensagem;
      }
    } catch (_) {
      if (idConsulta == idProcesso) {
        mensagemErroAndamentos =
            'Não foi possível carregar o histórico do processo.';
      }
    } finally {
      if (idConsulta == idProcesso) {
        carregandoAndamentos = false;
      }
    }
  }

  bool _consultaAtual(int versaoConsulta, String idConsulta) {
    return versaoConsulta == _versaoConsulta && idConsulta == idProcesso;
  }

  void _limparEstado() {
    cabecalho = null;
    documentos = const <ProcessoArvoreDocumentoItem>[];
    andamentos = const <ProcessoAndamentoItem>[];
    proximoCursorDocumentos = null;
    proximoCursorAndamentos = null;
    mensagemErro = '';
    mensagemErroDocumentos = '';
    mensagemErroAndamentos = '';
    carregandoDocumentos = false;
    carregandoAndamentos = false;
    documentosCarregados = false;
    andamentosCarregados = false;
    podeCarregarMaisDocumentos = false;
    podeCarregarMaisAndamentos = false;
  }

  @override
  void ngOnDestroy() {
    unawaited(_retornoSolicitadoController.close());
  }
}
