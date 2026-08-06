import 'package:angel3_framework/angel3_framework.dart';
import 'package:sei_backend/src/shared/models/resposta_erro_api.dart';
import 'package:sei_core/sei_core.dart';

/// Padroniza erros JSON das rotas públicas da API.
final class RespostaApiHttp {
  const RespostaApiHttp._();

  /// Escreve um erro previsível sem expor detalhes internos da infraestrutura.
  static Future<void> responderErro(
    ResponseContext response, {
    required int codigoHttp,
    required String mensagem,
  }) async {
    response.statusCode = codigoHttp;
    await response.json(RespostaErroApi(mensagem).toMap());
  }

  /// Serializa uma coleção de modelos sem repetir conversão em controllers.
  static Future<void> responderLista<T extends BaseModel>(
    ResponseContext response,
    Iterable<T> itens,
  ) async {
    final List<Map<String, dynamic>> resposta = <Map<String, dynamic>>[];
    for (final T item in itens) {
      resposta.add(item.toMap());
    }

    await response.json(resposta);
  }
}
