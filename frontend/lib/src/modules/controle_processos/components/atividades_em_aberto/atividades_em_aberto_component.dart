import 'dart:async' show StreamController, unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';

@Component(
  selector: 'sei-atividades-em-aberto',
  templateUrl: 'atividades_em_aberto_component.html',
  styleUrls: <String>['atividades_em_aberto_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class AtividadesEmAbertoComponent implements AfterChanges, OnDestroy {
  /// Título da consulta que será exibida no cabeçalho da lista.
  @Input()
  String titulo = 'Atividades em aberto';

  /// Descrição dos processos consultados para a unidade selecionada.
  @Input()
  String descricaoConsulta = 'Processos recebidos';

  /// Título usado quando a consulta não retorna processos.
  @Input()
  String tituloVazio = 'Nenhuma atividade em aberto';

  /// Descrição usada quando a consulta não retorna processos.
  @Input()
  String descricaoVazia = 'processos recebidos pendentes';

  /// Rótulo da coluna que informa a abertura da atividade na unidade.
  @Input()
  String rotuloDataAbertura = 'Recebido em';

  @Input()
  PaginaProcessosRecebidos? pagina;

  @Input()
  bool carregando = false;

  @Input()
  String? erro;

  @Input()
  String unidadeSelecionada = '';

  final StreamController<int> _paginaSolicitadaController =
      StreamController<int>.broadcast();
  final StreamController<ProcessoRecebidoItem> _processoSelecionadoController =
      StreamController<ProcessoRecebidoItem>.broadcast();

  /// Emite o deslocamento da página solicitada pelo usuário.
  @Output()
  Stream<int> get paginaSolicitada => _paginaSolicitadaController.stream;

  /// Emite a atividade cujo processo deve ser aberto no contêiner da tela.
  @Output()
  Stream<ProcessoRecebidoItem> get processoSelecionado =>
      _processoSelecionadoController.stream;

  List<ProcessoRecebidoItem> itens = const <ProcessoRecebidoItem>[];
  int total = 0;
  int limite = 50;
  int deslocamento = 0;
  String mensagemErro = '';
  String descricaoUnidade = '';
  String descricaoDataAbertura = 'Recebido em';
  String rotuloPaginacao = '';
  String rotuloAcessivelPaginacao = 'Paginação';
  bool exibirCarregamento = false;
  bool exibirErro = false;
  bool exibirTabela = false;
  bool exibirVazio = false;
  bool exibirAguardandoUnidade = false;
  bool exibirPaginacao = false;
  bool temUnidadeSelecionada = false;
  bool podeVoltarPagina = false;
  bool podeAvancarPagina = false;
  bool botaoAnteriorDesabilitado = true;
  bool botaoProximoDesabilitado = true;
  int deslocamentoPaginaAnterior = 0;
  int deslocamentoProximaPagina = 0;

  @override
  void ngAfterChanges() {
    itens = pagina?.itens ?? const <ProcessoRecebidoItem>[];
    total = pagina?.total ?? 0;
    limite = pagina?.limite ?? 50;
    if (limite <= 0) {
      limite = 50;
    }
    deslocamento = pagina?.deslocamento ?? 0;
    mensagemErro = erro ?? '';
    descricaoUnidade = unidadeSelecionada;
    descricaoDataAbertura = rotuloDataAbertura;
    temUnidadeSelecionada = descricaoUnidade.isNotEmpty;
    exibirCarregamento = carregando;
    exibirErro = mensagemErro.isNotEmpty;
    exibirTabela = !exibirCarregamento && !exibirErro && itens.isNotEmpty;
    exibirVazio =
        !exibirCarregamento && !exibirErro && pagina != null && itens.isEmpty;
    exibirAguardandoUnidade = !exibirCarregamento &&
        !exibirErro &&
        pagina == null &&
        !temUnidadeSelecionada;
    _atualizarPaginacao();
  }

  /// Solicita a página anterior quando existe uma página anterior disponível.
  void solicitarPaginaAnterior() {
    if (!podeVoltarPagina) {
      return;
    }
    _paginaSolicitadaController.add(deslocamentoPaginaAnterior);
  }

  /// Solicita a próxima página quando existe uma página seguinte disponível.
  void solicitarProximaPagina() {
    if (!podeAvancarPagina) {
      return;
    }
    _paginaSolicitadaController.add(deslocamentoProximaPagina);
  }

  /// Solicita a abertura do processo associado à atividade selecionada.
  void selecionarProcesso(ProcessoRecebidoItem item) {
    _processoSelecionadoController.add(item);
  }

  void _atualizarPaginacao() {
    rotuloAcessivelPaginacao = 'Paginação de $titulo';
    deslocamentoPaginaAnterior = deslocamento - limite;
    if (deslocamentoPaginaAnterior < 0) {
      deslocamentoPaginaAnterior = 0;
    }
    deslocamentoProximaPagina = deslocamento + limite;
    podeVoltarPagina = deslocamento > 0;
    podeAvancarPagina = deslocamentoProximaPagina < total;
    botaoAnteriorDesabilitado = !podeVoltarPagina;
    botaoProximoDesabilitado = !podeAvancarPagina;

    final bool possuiPaginaComItens = pagina != null && itens.isNotEmpty;
    if (possuiPaginaComItens) {
      final int primeiroItem = deslocamento + 1;
      final int ultimoCalculado = deslocamento + itens.length;
      final int ultimoItem = ultimoCalculado > total ? total : ultimoCalculado;
      rotuloPaginacao =
          'Exibindo itens $primeiroItem a $ultimoItem de $total processos.';
    } else if (pagina != null && total > 0) {
      rotuloPaginacao =
          'Nenhum processo nesta página. Total de $total processos.';
    } else {
      rotuloPaginacao = '';
    }
    exibirPaginacao =
        pagina != null && total > 0 && !exibirCarregamento && !exibirErro;
  }

  @override
  void ngOnDestroy() {
    unawaited(_paginaSolicitadaController.close());
    unawaited(_processoSelecionadoController.close());
  }
}
