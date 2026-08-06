import 'package:sei_backend/src/db/sip_database_service.dart';
import 'package:sei_backend/src/modules/sip/sip_referencia_repository.dart';
import 'package:sei_core/sei_core.dart';

/// Orquestra leituras explicitamente não autenticadas da referência SIP.
class SipReferenciaService {
  SipReferenciaService(this._databaseService);

  final SipDatabaseService _databaseService;

  Future<List<SistemaSipResumo>> listarSistemasAtivos() {
    return _databaseService.executar(
      (connection) =>
          SipReferenciaRepository(connection).listarSistemasAtivos(),
    );
  }
}
