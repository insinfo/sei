import 'dart:async' show StreamController, unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Exibe a árvore documental do processo, carregada sob demanda.
///
/// Intencionalmente não carrega ao receber o processo: a árvore pode ser
/// grande, e transferi-la de imediato oneraria a abertura da tela para
/// processos com muitos documentos.
@Component(
  selector: 'sei-processo-documentos',
  templateUrl: 'processo_documentos_component.html',
  styleUrls: <String>['processo_documentos_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoDocumentosComponent implements AfterChanges, OnDestroy {
  ProcessoDocumentosComponent(this._service);

  final ProcessoDetalheService _service;
  final StreamController<String> _documentoSelecionadoController =
      StreamController<String>.broadcast();

  @Input()
  String idProcesso = '';

  /// Notifica a página quando o usuário escolhe um documento da árvore para
  /// ver o conteúdo, para que ela alimente
  /// `sei-processo-documento-conteudo` sem esta seção conhecer o consumidor.
  @Output()
  Stream<String> get documentoSelecionado =>
      _documentoSelecionadoController.stream;

  List<ProcessoArvoreDocumentoItem> documentos =
      const <ProcessoArvoreDocumentoItem>[];
  String? proximoCursor;
  String mensagemErro = '';
  bool carregando = false;
  bool carregado = false;
  bool podeCarregarMais = false;

  /// Documento em destaque na árvore, só para realce visual da linha.
  String idDocumentoSelecionado = '';

  String _ultimoIdProcesso = '';

  @override
  void ngAfterChanges() {
    if (idProcesso == _ultimoIdProcesso) {
      return;
    }
    _ultimoIdProcesso = idProcesso;
    idDocumentoSelecionado = '';
    _limparEstado();
  }

  /// Marca o documento como selecionado e avisa quem estiver ouvindo.
  void selecionarDocumento(ProcessoArvoreDocumentoItem item) {
    idDocumentoSelecionado = item.idDocumento;
    _documentoSelecionadoController.add(item.idDocumento);
  }

  /// Carrega a primeira página da árvore documental quando o usuário pedir.
  void solicitarDocumentos() {
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
      final PaginaProcessoArvoreDocumentos pagina =
          await _service.listarDocumentos(idConsulta, cursor: cursor);
      if (idConsulta != idProcesso) {
        return;
      }
      documentos = cursor == null
          ? pagina.itens
          : <ProcessoArvoreDocumentoItem>[...documentos, ...pagina.itens];
      proximoCursor = pagina.proximoCursor;
      podeCarregarMais = pagina.temProximaPagina;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (idConsulta == idProcesso) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (idConsulta == idProcesso) {
        mensagemErro = 'Não foi possível carregar os documentos do processo.';
      }
    } finally {
      if (idConsulta == idProcesso) {
        carregando = false;
      }
    }
  }

  void _limparEstado() {
    documentos = const <ProcessoArvoreDocumentoItem>[];
    proximoCursor = null;
    mensagemErro = '';
    carregando = false;
    carregado = false;
    podeCarregarMais = false;
  }

  @override
  void ngOnDestroy() {
    unawaited(_documentoSelecionadoController.close());
  }
}
