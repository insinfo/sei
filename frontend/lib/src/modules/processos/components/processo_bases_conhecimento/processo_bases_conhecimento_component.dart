import 'dart:async' show unawaited;

import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';
import 'package:sei_frontend/src/modules/processos/services/processo_detalhe_service.dart';

/// Lista as bases de conhecimento associadas ao **tipo** do processo.
///
/// O corpo (`conteudo`) da base de conhecimento **não** faz parte desta
/// projeção — `ProcessoBaseConhecimento` a mantém fora de propósito, no
/// mesmo padrão do conteúdo de documento, por ser potencialmente grande e
/// por não haver ainda uma rota de leitura sob demanda equivalente a
/// `GET .../documentos/:idDocumento/conteudo`. Por isso este componente
/// exibe só os metadados retornados pela API (descrição, unidade, usuário
/// gerador e datas) e deixa claro que o corpo não está disponível aqui —
/// sem simular link, endpoint ou conteúdo que o backend ainda não expõe.
@Component(
  selector: 'sei-processo-bases-conhecimento',
  templateUrl: 'processo_bases_conhecimento_component.html',
  styleUrls: <String>['processo_bases_conhecimento_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ProcessoBasesConhecimentoComponent implements AfterChanges, OnDestroy {
  ProcessoBasesConhecimentoComponent(this._service);

  final ProcessoDetalheService _service;

  @Input()
  String idProcesso = '';

  List<ProcessoBaseConhecimento> bases = const <ProcessoBaseConhecimento>[];
  String mensagemErro = '';
  bool carregando = false;
  bool carregado = false;

  int _versaoConsulta = 0;
  String _ultimoIdProcesso = '';

  @override
  void ngAfterChanges() {
    if (idProcesso.isEmpty || idProcesso == _ultimoIdProcesso) {
      return;
    }
    _ultimoIdProcesso = idProcesso;
    bases = const <ProcessoBaseConhecimento>[];
    carregado = false;
    mensagemErro = '';
    unawaited(_carregar());
  }

  Future<void> _carregar() async {
    final String idConsulta = idProcesso;
    final int versaoConsulta = ++_versaoConsulta;
    carregando = true;
    mensagemErro = '';
    try {
      final List<ProcessoBaseConhecimento> resultado =
          await _service.listarBasesConhecimento(idConsulta);
      if (!_consultaAtual(versaoConsulta, idConsulta)) {
        return;
      }
      bases = resultado;
      carregado = true;
    } on ProcessoDetalheApiException catch (excecao) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro = excecao.mensagem;
      }
    } catch (_) {
      if (_consultaAtual(versaoConsulta, idConsulta)) {
        mensagemErro =
            'Não foi possível carregar as bases de conhecimento do tipo deste processo.';
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
