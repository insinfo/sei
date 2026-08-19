import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';

@Component(
  selector: 'sei-lista-tipos-procedimento',
  templateUrl: 'lista_tipos_procedimento_component.html',
  directives: <Type>[NgIf, NgFor],
)
class ListaTiposProcedimentoComponent {
  @Input()
  List<TipoProcedimento> itens = const <TipoProcedimento>[];
}
