import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';

/// Exibe os dados resumidos de identificação de um processo.
///
/// Componente puramente apresentacional: recebe o cabeçalho já carregado
/// pela página e não faz chamada HTTP própria.
@Component(
  selector: 'sei-processo-cabecalho',
  templateUrl: 'processo_cabecalho_component.html',
  styleUrls: <String>['processo_cabecalho_component.css'],
  directives: <Type>[NgIf],
)
class ProcessoCabecalhoComponent {
  /// Cabeçalho já resolvido pela página; `null` enquanto carrega.
  @Input()
  ProcessoCabecalho? cabecalho;
}
