import 'dart:async' show unawaited;
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:sei_frontend/src/modules/administracao/models/unidade_detalhe.dart';
import 'package:sei_frontend/src/modules/administracao/models/unidade_list_item.dart';
import 'package:sei_frontend/src/modules/administracao/services/unidades_service.dart';

/// Administração de unidades: listagem paginada com filtro por sigla/
/// situação e detalhe somente leitura do item selecionado.
///
/// Segue o mesmo padrão de `UsuariosPage`/`AtividadesEmAbertoComponent`.
/// Criar/editar unidade fica fora desta rodada por decisão explícita do
/// escopo: só lista e detalhe somente leitura.
@Component(
  selector: 'sei-unidades-page',
  templateUrl: 'unidades_page.html',
  styleUrls: <String>['unidades_page.css'],
  directives: <Type>[NgFor, NgIf],
)
class UnidadesPage implements OnInit {
  UnidadesPage(this._service);

  final UnidadesService _service;

  String filtroSigla = '';
  String filtroAtivo = '';

  List<UnidadeListItem> itens = const <UnidadeListItem>[];
  int total = 0;
  final int limite = 50;
  int deslocamento = 0;

  bool carregando = false;
  String? erro;
  bool exibirCarregando = false;
  bool exibirErro = false;
  bool exibirTabela = false;
  bool exibirVazio = false;
  bool exibirPaginacao = false;
  bool podeVoltarPagina = false;
  bool podeAvancarPagina = false;
  String rotuloPaginacao = '';
  int _deslocamentoPaginaAnterior = 0;
  int _deslocamentoProximaPagina = 0;
  int _versaoConsulta = 0;

  UnidadeListItem? itemSelecionado;
  UnidadeDetalhe? detalhe;
  bool carregandoDetalhe = false;
  String? erroDetalhe;

  @override
  void ngOnInit() {
    unawaited(carregar());
  }

  /// Carrega a página de unidades com os filtros atuais.
  Future<void> carregar({int? deslocamento}) async {
    final int deslocamentoConsulta = deslocamento ?? this.deslocamento;
    final int versaoConsulta = ++_versaoConsulta;
    this.deslocamento = deslocamentoConsulta;
    carregando = true;
    erro = null;
    _atualizarFlags();
    try {
      final resultado = await _service.listar(
        sigla: filtroSigla.trim().isEmpty ? null : filtroSigla.trim(),
        ativo: _filtroAtivoComoBool(),
        limite: limite,
        deslocamento: deslocamentoConsulta,
      );
      if (versaoConsulta != _versaoConsulta) {
        return;
      }
      itens = resultado.itens;
      total = resultado.total;
      this.deslocamento = resultado.deslocamento;
    } on UnidadesApiException catch (excecao) {
      if (versaoConsulta != _versaoConsulta) {
        return;
      }
      erro = excecao.mensagem;
      itens = const <UnidadeListItem>[];
    } catch (_) {
      if (versaoConsulta != _versaoConsulta) {
        return;
      }
      erro = 'Não foi possível carregar as unidades.';
      itens = const <UnidadeListItem>[];
    } finally {
      if (versaoConsulta == _versaoConsulta) {
        carregando = false;
        _atualizarFlags();
      }
    }
  }

  /// Aplica os filtros digitados, reiniciando a paginação.
  void buscar() {
    unawaited(carregar(deslocamento: 0));
  }

  /// Handler do submit do formulário de filtros: evita o postback padrão do
  /// navegador e delega para [buscar].
  void onBuscarSubmit(html.Event evento) {
    evento.preventDefault();
    buscar();
  }

  /// Limpa os filtros e recarrega a primeira página.
  void limparFiltros() {
    filtroSigla = '';
    filtroAtivo = '';
    unawaited(carregar(deslocamento: 0));
  }

  void onFiltroSiglaChange(html.Event evento) {
    filtroSigla = _lerValorDoCampo(evento);
  }

  void onFiltroAtivoChange(html.Event evento) {
    final html.EventTarget? alvo = evento.target;
    if (alvo is html.SelectElement) {
      filtroAtivo = alvo.value ?? '';
    }
  }

  void solicitarPaginaAnterior() {
    if (!podeVoltarPagina) {
      return;
    }
    unawaited(carregar(deslocamento: _deslocamentoPaginaAnterior));
  }

  void solicitarProximaPagina() {
    if (!podeAvancarPagina) {
      return;
    }
    unawaited(carregar(deslocamento: _deslocamentoProximaPagina));
  }

  /// Abre o painel de detalhe da unidade selecionada na tabela.
  Future<void> selecionarItem(UnidadeListItem item) async {
    itemSelecionado = item;
    detalhe = null;
    erroDetalhe = null;
    carregandoDetalhe = true;
    try {
      detalhe = await _service.buscar(item.idUnidade);
    } on UnidadesApiException catch (excecao) {
      erroDetalhe = excecao.mensagem;
    } catch (_) {
      erroDetalhe = 'Não foi possível carregar o detalhe da unidade.';
    } finally {
      carregandoDetalhe = false;
    }
  }

  /// Fecha o painel de detalhe.
  void fecharDetalhe() {
    itemSelecionado = null;
    detalhe = null;
    erroDetalhe = null;
  }

  bool? _filtroAtivoComoBool() {
    if (filtroAtivo == 'true') {
      return true;
    }
    if (filtroAtivo == 'false') {
      return false;
    }
    return null;
  }

  void _atualizarFlags() {
    exibirCarregando = carregando;
    exibirErro = !carregando && erro != null;
    exibirTabela = !carregando && erro == null && itens.isNotEmpty;
    exibirVazio = !carregando && erro == null && itens.isEmpty;

    _deslocamentoPaginaAnterior = deslocamento - limite;
    if (_deslocamentoPaginaAnterior < 0) {
      _deslocamentoPaginaAnterior = 0;
    }
    _deslocamentoProximaPagina = deslocamento + limite;
    podeVoltarPagina = deslocamento > 0;
    podeAvancarPagina = _deslocamentoProximaPagina < total;
    exibirPaginacao = !carregando && erro == null && total > 0;

    if (itens.isNotEmpty) {
      final int primeiroItem = deslocamento + 1;
      final int ultimoCalculado = deslocamento + itens.length;
      final int ultimoItem = ultimoCalculado > total ? total : ultimoCalculado;
      rotuloPaginacao =
          'Exibindo itens $primeiroItem a $ultimoItem de $total unidades.';
    } else {
      rotuloPaginacao = '';
    }
  }

  String _lerValorDoCampo(html.Event evento) {
    final html.EventTarget? alvo = evento.target;
    if (alvo is html.InputElement) {
      return alvo.value ?? '';
    }
    return '';
  }
}
