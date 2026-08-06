import 'package:ngdart/angular.dart';
import 'package:sei_core/sei_core.dart';

@Component(
  selector: 'sei-catalogo-resumo',
  templateUrl: 'catalogo_resumo_component.html',
  styleUrls: <String>['catalogo_resumo_component.css'],
  directives: <Type>[NgIf],
)
class CatalogoResumoComponent {
  @Input()
  CatalogoResumo? resumo;

  @Input()
  StatusAmbiente? status;
}
