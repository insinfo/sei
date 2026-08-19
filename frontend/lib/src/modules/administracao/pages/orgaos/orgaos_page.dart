import 'dart:async' show unawaited;
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:sei_frontend/src/modules/administracao/models/orgao_detalhe.dart';
import 'package:sei_frontend/src/modules/administracao/models/orgao_list_item.dart';
import 'package:sei_frontend/src/modules/administracao/services/orgaos_service.dart';

/// Administração de órgãos: listagem paginada com filtro por sigla/
/// situação e detalhe somente leitura do item selecionado.
///
/// Segue o mesmo padrão de `UsuariosPage`/`UnidadesPage`/
/// `AtividadesEmAbertoComponent`. Criar/editar órgão fica fora desta
/// rodada por decisão explícita do escopo: só lista e detalhe somente
/// leitura.
@Component(
  selector: 'sei-orgaos-page',
  templateUrl: 'orgaos_page.html',
  styleUrls: <String>['orgaos_page.css'],
  directives: <Type>[NgFor, NgIf],
)
class OrgaosPage implements OnInit {
  OrgaosPage(this._service);

  final OrgaosService _service;

  String filtroSigla = '';
  String filtroAtivo = '';

  List<OrgaoListItem> itens = const <OrgaoListItem>[];
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

  OrgaoListItem? itemSelecionado;
  OrgaoDetalhe? detalhe;
  bool carregandoDetalhe = false;
  String? erroDetalhe;

  @override
  void ngOnInit() {
    unawaited(carregar());
  }

  /// Carrega a página de órgãos com os filtros atuais.
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
    } on OrgaosApiException catch (excecao) {
      if (versaoConsulta != _versaoConsulta) {
        return;
      }
      erro = excecao.mensagem;
      itens = const <OrgaoListItem>[];
    } catch (_) {
      if (versaoConsulta != _versaoConsulta) {
        return;
      }
      erro = 'Não foi possível carregar os órgãos.';
      itens = const <OrgaoListItem>[];
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

  /// Abre o painel de detalhe do órgão selecionado na tabela.
  Future<void> selecionarItem(OrgaoListItem item) async {
    itemSelecionado = item;
    detalhe = null;
    erroDetalhe = null;
    carregandoDetalhe = true;
    try {
      detalhe = await _service.buscar(item.idOrgao);
    } on OrgaosApiException catch (excecao) {
      erroDetalhe = excecao.mensagem;
    } catch (_) {
      erroDetalhe = 'Não foi possível carregar o detalhe do órgão.';
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
          'Exibindo itens $primeiroItem a $ultimoItem de $total órgãos.';
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
