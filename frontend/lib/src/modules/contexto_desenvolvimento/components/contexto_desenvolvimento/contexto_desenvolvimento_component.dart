import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';

/// Estado pronto para renderizar uma opção de unidade no seletor local.
class UnidadeContextoVm {
  const UnidadeContextoVm({
    required this.idUnidade,
    required this.valor,
    required this.rotulo,
    required this.selecionada,
  });

  final int idUnidade;
  final String valor;
  final String rotulo;
  final bool selecionada;
}

/// Exibe e permite selecionar o contexto local de desenvolvimento.
///
/// A saída [unidadeSelecionada] comunica uma intenção da interface. A
/// persistência da escolha e o recarregamento de dados pertencem ao pai.
@Component(
  selector: 'sei-contexto-desenvolvimento',
  templateUrl: 'contexto_desenvolvimento_component.html',
  styleUrls: <String>['contexto_desenvolvimento_component.css'],
  directives: <Type>[NgFor, NgIf],
)
class ContextoDesenvolvimentoComponent implements AfterChanges, OnDestroy {
  @Input()
  ContextoDesenvolvimento? contexto;

  @Input()
  int? idUnidadeSelecionada;

  @Input()
  bool carregando = false;

  @Input()
  String? erro;

  final StreamController<int> _unidadeSelecionadaController =
      StreamController<int>.broadcast();

  @Output()
  Stream<int> get unidadeSelecionada => _unidadeSelecionadaController.stream;

  List<UnidadeContextoVm> unidades = const <UnidadeContextoVm>[];
  String identificacaoUsuario = '';
  String identificacaoOrgao = '';
  String mensagemErro = '';
  String valorUnidadeSelecionada = '';
  bool exibirCarregamento = false;
  bool exibirErro = false;
  bool exibirConteudo = false;
  bool exibirSemUnidades = false;
  bool seletorDesabilitado = true;

  @override
  void ngAfterChanges() {
    final ContextoDesenvolvimento? contextoAtual = contexto;
    final int? unidadeAtual = idUnidadeSelecionada;
    identificacaoUsuario = contextoAtual == null
        ? ''
        : '${contextoAtual.siglaUsuario} — ${contextoAtual.nomeUsuario}';
    identificacaoOrgao = contextoAtual == null
        ? ''
        : 'Órgão de referência: ${contextoAtual.idOrgao}';
    unidades = contextoAtual?.unidades
            .map(
              (UnidadeResumo unidade) => UnidadeContextoVm(
                idUnidade: unidade.idUnidade,
                valor: unidade.idUnidade.toString(),
                rotulo: '${unidade.sigla} — ${unidade.descricao}',
                selecionada: unidade.idUnidade == unidadeAtual,
              ),
            )
            .toList() ??
        const <UnidadeContextoVm>[];
    valorUnidadeSelecionada = unidadeAtual?.toString() ?? '';
    mensagemErro = erro ?? '';
    exibirCarregamento = carregando;
    exibirErro = mensagemErro.isNotEmpty;
    exibirConteudo =
        !exibirCarregamento && !exibirErro && contextoAtual != null;
    exibirSemUnidades = exibirConteudo && unidades.isEmpty;
    seletorDesabilitado = unidades.length < 2;
  }

  /// Emite uma nova unidade somente quando ela pertence ao contexto recebido.
  void alterarUnidade(html.Event evento) {
    final html.EventTarget? alvo = evento.target;
    if (alvo is! html.SelectElement) {
      return;
    }

    final int? idUnidade = int.tryParse(alvo.value ?? '');
    final bool unidadeDisponivel = unidades.any(
      (UnidadeContextoVm unidade) => unidade.idUnidade == idUnidade,
    );
    if (idUnidade == null ||
        !unidadeDisponivel ||
        idUnidade == idUnidadeSelecionada) {
      return;
    }
    _unidadeSelecionadaController.add(idUnidade);
  }

  @override
  void ngOnDestroy() {
    unawaited(_unidadeSelecionadaController.close());
  }
}
