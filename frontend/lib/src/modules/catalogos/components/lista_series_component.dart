import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';

@Component(
  selector: 'sei-lista-series',
  templateUrl: 'lista_series_component.html',
  styleUrls: <String>['lista_catalogo_component.css'],
  directives: <Type>[NgIf, NgFor],
)
class ListaSeriesComponent {
  @Input()
  List<Serie> itens = const <Serie>[];
}
