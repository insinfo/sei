import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Exibe o conteúdo de um documento específico do processo, interno (corpo
/// HTML) ou externo (ponteiro do anexo, sem o byte do arquivo).
///
/// Diferente das demais seções da tela do processo, este componente não
/// resume o processo inteiro: ele mostra o conteúdo de **um** documento
/// selecionado, por isso depende de dois `@Input()` — [idProcesso] e
/// [idDocumento] — em vez de só o primeiro.
///
/// **Segurança contra XSS.** O corpo do documento interno é HTML produzido
/// pelo editor do SEI e é exibido com `[innerHtml]`, que no NgDart passa
/// pelo `DomSanitizationService` padrão antes de entrar no DOM — a
/// sanitização automática do framework não é contornada em nenhum ponto
/// (`bypassSecurityTrustHtml` e equivalentes não são usados aqui).
@Component(
  selector: 'sei-processo-documento-conteudo',
  templateUrl: 'processo_documento_conteudo_component.html',
  styleUrls: <String>['processo_documento_conteudo_component.css'],
  directives: <Type>[NgIf],
)
class ProcessoDocumentoConteudoComponent implements AfterChanges, OnDestroy {
  ProcessoDocumentoConteudoComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  @Input()
  String idDocumento = '';

  ProcessoDocumentoConteudo? documento;
  String mensagemErro = '';
  bool carregando = false;
  bool carregado = false;

  /// Se o documento carregado é interno (corpo HTML potencialmente presente).
  bool documentoInterno = false;

  /// Se o documento carregado é externo (só o ponteiro do anexo).
  bool documentoExterno = false;

  /// Se há corpo HTML não vazio para exibir.
  bool possuiConteudoHtml = false;

  /// Corpo HTML do documento interno, pronto para `[innerHtml]`.
  ///
  /// Mantido como `String` (nunca `String?`) para o binding — a ausência de
  /// corpo é sinalizada por [possuiConteudoHtml], não por um valor nulo aqui.
  String conteudoHtmlExibicao = '';

  /// Tamanho do anexo já formatado em unidade legível (B/KB/MB/GB).
  String anexoTamanhoFormatado = '—';

  int _versaoConsulta = 0;
  String _ultimaChaveConsulta = '';

  @override
  void ngAfterChanges() {
    if (idProcesso.isEmpty || idDocumento.isEmpty) {
      _limparEstado();
      return;
    }
    final String chave = '$idProcesso/$idDocumento';
    if (chave == _ultimaChaveConsulta) {
      return;
    }
    _ultimaChaveConsulta = chave;
    _limparEstado();
    unawaited(_carregar());
  }

  Future<void> _carregar() async {
    final String idProcessoConsulta = idProcesso;
    final String idDocumentoConsulta = idDocumento;
    final int versaoConsulta = ++_versaoConsulta;
    carregando = true;
    mensagemErro = '';
    try {
      final ProcessoDocumentoConteudo resultado =
          await _service.obterConteudoDocumento(
        idProcessoConsulta,
        idDocumentoConsulta,
      );
      if (!_consultaAtual(
        versaoConsulta,
        idProcessoConsulta,
        idDocumentoConsulta,
      )) {
        return;
      }
      _aplicarResultado(resultado);
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(
        versaoConsulta,
        idProcessoConsulta,
        idDocumentoConsulta,
      )) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(
        versaoConsulta,
        idProcessoConsulta,
        idDocumentoConsulta,
      )) {
        mensagemErro = 'Não foi possível carregar o conteúdo do documento.';
      }
    } finally {
      if (_consultaAtual(
        versaoConsulta,
        idProcessoConsulta,
        idDocumentoConsulta,
      )) {
        carregando = false;
      }
    }
  }

  void _aplicarResultado(ProcessoDocumentoConteudo resultado) {
    documento = resultado;
    documentoInterno = resultado.estado == EstadoDocumento.interno;
    documentoExterno = resultado.estado == EstadoDocumento.externo;
    final String? corpo = resultado.conteudoHtml;
    conteudoHtmlExibicao = corpo ?? '';
    possuiConteudoHtml = corpo != null && corpo.trim().isNotEmpty;
    anexoTamanhoFormatado = _formatarTamanho(resultado.anexoTamanho);
  }

  void _limparEstado() {
    documento = null;
    carregado = false;
    mensagemErro = '';
    documentoInterno = false;
    documentoExterno = false;
    possuiConteudoHtml = false;
    conteudoHtmlExibicao = '';
    anexoTamanhoFormatado = '—';
  }

  bool _consultaAtual(
    int versaoConsulta,
    String idProcessoConsulta,
    String idDocumentoConsulta,
  ) {
    return versaoConsulta == _versaoConsulta &&
        idProcessoConsulta == idProcesso &&
        idDocumentoConsulta == idDocumento;
  }

  /// Formata um tamanho em bytes na maior unidade legível (B, KB, MB ou GB).
  ///
  /// Fica local a este componente por ser, até agora, o único lugar do
  /// módulo que precisa dessa conversão — não há motivo para promovê-la a
  /// utilitário compartilhado ainda.
  String _formatarTamanho(int? bytes) {
    if (bytes == null) {
      return '—';
    }
    const List<String> unidades = <String>['B', 'KB', 'MB', 'GB'];
    double valor = bytes.toDouble();
    int indice = 0;
    while (valor >= 1024 && indice < unidades.length - 1) {
      valor /= 1024;
      indice++;
    }
    final int casasDecimais = indice == 0 ? 0 : 1;
    return '${valor.toStringAsFixed(casasDecimais)} ${unidades[indice]}';
  }

  @override
  void ngOnDestroy() {}
}
