import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:sei_backend/src/shared/services/servico_conexao.dart';

/// Registra uma conexão no escopo de uma requisição antes do controlador.
///
/// A instância é encerrada quando a requisição termina se o serviço não usa
/// pool. Os repositórios a recebem pela fábrica registrada no DI do Angel.
class MiddlewareConexaoBanco {
  MiddlewareConexaoBanco(this._servicoConexao);

  final ServicoConexao _servicoConexao;

  Future<bool> executar(
    RequestContext request,
    ResponseContext response,
  ) async {
    final container = request.container;
    if (container == null) {
      throw StateError('O contêiner da requisição não está disponível.');
    }

    final connection = await _servicoConexao.conectar();
    try {
      container.registerSingleton<Connection>(connection);
    } catch (_) {
      if (!_servicoConexao.usaPool) {
        await connection.disconnect();
      }
      rethrow;
    }

    if (!_servicoConexao.usaPool) {
      request.shutdownHooks.add(connection.disconnect);
    }
    return true;
  }
}

/// Identifica o middleware que abre conexão com a Base de Referência SEI.
class MiddlewareConexaoSei extends MiddlewareConexaoBanco {
  MiddlewareConexaoSei(ServicoConexao servicoConexao) : super(servicoConexao);
}

/// Identifica o middleware que abre conexão com a Base de Referência SIP.
class MiddlewareConexaoSip extends MiddlewareConexaoBanco {
  MiddlewareConexaoSip(ServicoConexao servicoConexao) : super(servicoConexao);
}
