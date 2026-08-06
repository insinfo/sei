import 'dart:async' show unawaited;
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/catalogos/components/catalogo_resumo_component.dart';
import 'package:sei_frontend/src/modules/catalogos/components/lista_series_component.dart';
import 'package:sei_frontend/src/modules/catalogos/components/lista_tipos_procedimento_component.dart';
import 'package:sei_frontend/src/modules/catalogos/services/catalogos_service.dart';
import 'package:sei_frontend/src/modules/controle_processos/components/atividades_em_aberto_component.dart';
import 'package:sei_frontend/src/modules/controle_processos/services/controle_processos_service.dart';
import 'package:sei_frontend/src/modules/contexto_desenvolvimento/components/contexto_desenvolvimento_component.dart';
import 'package:sei_frontend/src/modules/contexto_desenvolvimento/services/contexto_desenvolvimento_service.dart';

@Component(
  selector: 'sei-app',
  templateUrl: 'app_component.html',
  styleUrls: <String>['app_component.css'],
  directives: <Type>[
    NgIf,
    CatalogoResumoComponent,
    ListaTiposProcedimentoComponent,
    ListaSeriesComponent,
    AtividadesEmAbertoComponent,
    ContextoDesenvolvimentoComponent,
  ],
  providers: <Provider>[
    ClassProvider(CatalogosService),
    ClassProvider(ControleProcessosService),
    ClassProvider(ContextoDesenvolvimentoService),
  ],
)
class AppComponent implements OnInit {
  AppComponent(
    this._catalogosService,
    this._controleProcessosService,
    this._contextoDesenvolvimentoService,
  );

  final CatalogosService _catalogosService;
  final ControleProcessosService _controleProcessosService;
  final ContextoDesenvolvimentoService _contextoDesenvolvimentoService;

  final String tituloAtividades = 'Processos recebidos';
  final String descricaoAtividades = 'Processos recebidos';
  final String tituloAtividadesVazio = 'Nenhuma atividade em aberto';
  final String descricaoAtividadesVazia = 'processos recebidos pendentes';
  final String rotuloDataAtividades = 'Recebido em';
  final String tituloProcessosGerados = 'Processos gerados';
  final String descricaoProcessosGerados = 'Processos gerados';
  final String tituloProcessosGeradosVazio = 'Nenhum processo gerado';
  final String descricaoProcessosGeradosVazia = 'processos gerados pendentes';
  final String rotuloDataProcessosGerados = 'Gerado em';

  CatalogoResumo? resumo;
  StatusAmbiente? status;
  ContextoDesenvolvimento? contextoDesenvolvimento;
  List<TipoProcedimento> tiposProcedimento = const <TipoProcedimento>[];
  List<TipoProcedimento> tiposProcedimentoVisiveis = const <TipoProcedimento>[];
  List<Serie> series = const <Serie>[];
  List<Serie> seriesVisiveis = const <Serie>[];

  bool carregando = false;
  bool carregandoAtividades = false;
  bool carregandoProcessosGerados = false;
  bool carregandoContexto = false;
  bool abaTiposSelecionada = true;
  bool abaSeriesSelecionada = false;
  bool abaAtividadesSelecionada = false;
  bool abaProcessosGeradosSelecionada = false;
  String? erro;
  String? erroAtividades;
  String? erroProcessosGerados;
  String? erroContexto;
  String filtroTipos = '';
  String filtroSeries = '';
  int? idUnidadeSelecionada;
  String unidadeSelecionadaRotulo = '';
  PaginaProcessosRecebidos? paginaProcessosRecebidos;
  PaginaProcessosRecebidos? paginaProcessosGerados;
  int deslocamentoAtividades = 0;
  int deslocamentoProcessosGerados = 0;
  int _versaoConsultaAtividades = 0;
  int _versaoConsultaProcessosGerados = 0;

  @override
  void ngOnInit() {
    unawaited(recarregar());
    unawaited(carregarContextoDesenvolvimento());
  }

  /// Atualiza todos os dados de referência exibidos no painel.
  Future<void> recarregar() async {
    if (carregando) {
      return;
    }

    carregando = true;
    erro = null;
    try {
      final PainelCatalogos painel = await _catalogosService.carregarPainel();
      status = painel.status;
      resumo = painel.resumo;
      tiposProcedimento = painel.tiposProcedimento;
      series = painel.series;
      _reconstruirTiposVisiveis();
      _reconstruirSeriesVisiveis();
    } on CatalogosApiException catch (excecao) {
      erro = excecao.mensagem;
    } catch (_) {
      erro = 'Não foi possível carregar os catálogos de referência.';
    } finally {
      carregando = false;
    }
  }

  void selecionarTipos() {
    abaTiposSelecionada = true;
    abaSeriesSelecionada = false;
    abaAtividadesSelecionada = false;
    abaProcessosGeradosSelecionada = false;
  }

  void selecionarSeries() {
    abaTiposSelecionada = false;
    abaSeriesSelecionada = true;
    abaAtividadesSelecionada = false;
    abaProcessosGeradosSelecionada = false;
  }

  void selecionarAtividades() {
    abaTiposSelecionada = false;
    abaSeriesSelecionada = false;
    abaAtividadesSelecionada = true;
    abaProcessosGeradosSelecionada = false;
    if (idUnidadeSelecionada == null) {
      if (contextoDesenvolvimento == null && !carregandoContexto) {
        unawaited(carregarContextoDesenvolvimento());
      }
      return;
    }
    if (paginaProcessosRecebidos == null && !carregandoAtividades) {
      unawaited(carregarAtividades());
    }
  }

  void selecionarProcessosGerados() {
    abaTiposSelecionada = false;
    abaSeriesSelecionada = false;
    abaAtividadesSelecionada = false;
    abaProcessosGeradosSelecionada = true;
    if (idUnidadeSelecionada == null) {
      if (contextoDesenvolvimento == null && !carregandoContexto) {
        unawaited(carregarContextoDesenvolvimento());
      }
      return;
    }
    if (paginaProcessosGerados == null && !carregandoProcessosGerados) {
      unawaited(carregarProcessosGerados());
    }
  }

  /// Atualiza o conteúdo da aba aberta sem disparar uma operação de escrita.
  Future<void> atualizarAbaAtual() async {
    if (abaAtividadesSelecionada) {
      if (idUnidadeSelecionada == null) {
        await carregarContextoDesenvolvimento();
        return;
      }
      await carregarAtividades();
      return;
    }
    if (abaProcessosGeradosSelecionada) {
      if (idUnidadeSelecionada == null) {
        await carregarContextoDesenvolvimento();
        return;
      }
      await carregarProcessosGerados();
      return;
    }
    await recarregar();
  }

  /// Carrega uma página de atividades recebidas da unidade selecionada.
  Future<void> carregarAtividades({int? deslocamento}) async {
    final int? idUnidade = idUnidadeSelecionada;
    if (idUnidade == null) {
      paginaProcessosRecebidos = null;
      erroAtividades =
          'Selecione uma unidade de desenvolvimento para consultar atividades.';
      return;
    }

    final int deslocamentoConsulta = deslocamento ?? deslocamentoAtividades;
    final int versaoConsulta = ++_versaoConsultaAtividades;
    deslocamentoAtividades = deslocamentoConsulta;
    carregandoAtividades = true;
    erroAtividades = null;
    try {
      final PaginaProcessosRecebidos pagina =
          await _controleProcessosService.listarRecebidos(
        idUnidade: idUnidade,
        limite: 50,
        deslocamento: deslocamentoConsulta,
      );
      if (versaoConsulta != _versaoConsultaAtividades) {
        return;
      }
      paginaProcessosRecebidos = pagina;
      deslocamentoAtividades = pagina.deslocamento;
    } on ControleProcessosApiException catch (excecao) {
      if (versaoConsulta != _versaoConsultaAtividades) {
        return;
      }
      erroAtividades = excecao.mensagem;
    } catch (_) {
      if (versaoConsulta != _versaoConsultaAtividades) {
        return;
      }
      erroAtividades = 'Não foi possível carregar as atividades em aberto.';
    } finally {
      if (versaoConsulta == _versaoConsultaAtividades) {
        carregandoAtividades = false;
      }
    }
  }

  /// Carrega uma página de processos gerados pela unidade selecionada.
  Future<void> carregarProcessosGerados({int? deslocamento}) async {
    final int? idUnidade = idUnidadeSelecionada;
    if (idUnidade == null) {
      paginaProcessosGerados = null;
      erroProcessosGerados =
          'Selecione uma unidade de desenvolvimento para consultar processos gerados.';
      return;
    }

    final int deslocamentoConsulta =
        deslocamento ?? deslocamentoProcessosGerados;
    final int versaoConsulta = ++_versaoConsultaProcessosGerados;
    deslocamentoProcessosGerados = deslocamentoConsulta;
    carregandoProcessosGerados = true;
    erroProcessosGerados = null;
    try {
      final PaginaProcessosRecebidos pagina =
          await _controleProcessosService.listarGerados(
        idUnidade: idUnidade,
        limite: 50,
        deslocamento: deslocamentoConsulta,
      );
      if (versaoConsulta != _versaoConsultaProcessosGerados) {
        return;
      }
      paginaProcessosGerados = pagina;
      deslocamentoProcessosGerados = pagina.deslocamento;
    } on ControleProcessosApiException catch (excecao) {
      if (versaoConsulta != _versaoConsultaProcessosGerados) {
        return;
      }
      erroProcessosGerados = excecao.mensagem;
    } catch (_) {
      if (versaoConsulta != _versaoConsultaProcessosGerados) {
        return;
      }
      erroProcessosGerados = 'Não foi possível carregar os processos gerados.';
    } finally {
      if (versaoConsulta == _versaoConsultaProcessosGerados) {
        carregandoProcessosGerados = false;
      }
    }
  }

  /// Carrega o deslocamento solicitado na aba de processos recebidos.
  void solicitarPaginaAtividades(int deslocamento) {
    if (carregandoAtividades || deslocamento == deslocamentoAtividades) {
      return;
    }
    unawaited(carregarAtividades(deslocamento: deslocamento));
  }

  /// Carrega o deslocamento solicitado na aba de processos gerados.
  void solicitarPaginaProcessosGerados(int deslocamento) {
    if (carregandoProcessosGerados ||
        deslocamento == deslocamentoProcessosGerados) {
      return;
    }
    unawaited(carregarProcessosGerados(deslocamento: deslocamento));
  }

  /// Carrega a referência de usuário e unidades sem iniciar autenticação SIP.
  Future<void> carregarContextoDesenvolvimento() async {
    if (carregandoContexto) {
      return;
    }

    carregandoContexto = true;
    erroContexto = null;
    try {
      final ContextoDesenvolvimento contexto =
          await _contextoDesenvolvimentoService.buscar();
      contextoDesenvolvimento = contexto;
      final int? selecaoAnterior = idUnidadeSelecionada;
      final bool manterSelecao = contexto.unidades.any(
        (UnidadeResumo unidade) => unidade.idUnidade == selecaoAnterior,
      );
      idUnidadeSelecionada =
          manterSelecao ? selecaoAnterior : contexto.idUnidadeInicial;
      _atualizarUnidadeSelecionadaRotulo();
      _invalidarConsultasControleProcessos();
      if (abaAtividadesSelecionada && idUnidadeSelecionada != null) {
        unawaited(carregarAtividades());
      }
      if (abaProcessosGeradosSelecionada && idUnidadeSelecionada != null) {
        unawaited(carregarProcessosGerados());
      }
    } on ContextoDesenvolvimentoApiException catch (excecao) {
      erroContexto = excecao.mensagem;
    } catch (_) {
      erroContexto = 'Não foi possível carregar o contexto de desenvolvimento.';
    } finally {
      carregandoContexto = false;
    }
  }

  /// Atualiza a unidade local e busca novamente a fila quando ela está aberta.
  void selecionarUnidade(int idUnidade) {
    final ContextoDesenvolvimento? contexto = contextoDesenvolvimento;
    final bool unidadeDisponivel = contexto?.unidades.any(
          (UnidadeResumo unidade) => unidade.idUnidade == idUnidade,
        ) ??
        false;
    if (!unidadeDisponivel || idUnidade == idUnidadeSelecionada) {
      return;
    }

    idUnidadeSelecionada = idUnidade;
    _atualizarUnidadeSelecionadaRotulo();
    _invalidarConsultasControleProcessos();
    if (abaAtividadesSelecionada) {
      unawaited(carregarAtividades());
    }
    if (abaProcessosGeradosSelecionada) {
      unawaited(carregarProcessosGerados());
    }
  }

  void _atualizarUnidadeSelecionadaRotulo() {
    final int? idUnidade = idUnidadeSelecionada;
    UnidadeResumo? unidadeSelecionada;
    for (final UnidadeResumo unidade
        in contextoDesenvolvimento?.unidades ?? const <UnidadeResumo>[]) {
      if (unidade.idUnidade == idUnidade) {
        unidadeSelecionada = unidade;
        break;
      }
    }
    unidadeSelecionadaRotulo = unidadeSelecionada == null
        ? ''
        : '${unidadeSelecionada.sigla} — ${unidadeSelecionada.descricao}';
  }

  void _invalidarConsultasControleProcessos() {
    _versaoConsultaAtividades++;
    carregandoAtividades = false;
    erroAtividades = null;
    paginaProcessosRecebidos = null;
    deslocamentoAtividades = 0;
    _versaoConsultaProcessosGerados++;
    carregandoProcessosGerados = false;
    erroProcessosGerados = null;
    paginaProcessosGerados = null;
    deslocamentoProcessosGerados = 0;
  }

  void filtrarTipos(html.Event evento) {
    filtroTipos = _lerValorDoCampo(evento);
    _reconstruirTiposVisiveis();
  }

  void filtrarSeries(html.Event evento) {
    filtroSeries = _lerValorDoCampo(evento);
    _reconstruirSeriesVisiveis();
  }

  String _lerValorDoCampo(html.Event evento) {
    final html.EventTarget? alvo = evento.target;
    if (alvo is html.InputElement) {
      return alvo.value?.trim() ?? '';
    }
    return '';
  }

  void _reconstruirTiposVisiveis() {
    final String termo = filtroTipos.toLowerCase();
    tiposProcedimentoVisiveis = tiposProcedimento
        .where(
          (TipoProcedimento item) =>
              item.nome.toLowerCase().contains(termo) ||
              item.idTipoProcedimento.toString().contains(termo),
        )
        .toList();
  }

  void _reconstruirSeriesVisiveis() {
    final String termo = filtroSeries.toLowerCase();
    seriesVisiveis = series
        .where(
          (Serie item) =>
              item.nome.toLowerCase().contains(termo) ||
              item.idSerie.toString().contains(termo),
        )
        .toList();
  }
}
