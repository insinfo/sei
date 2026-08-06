import 'package:collection/collection.dart';
import 'package:essential_core/essential_core.dart';

/// Contrato comum dos modelos e DTOs compartilhados pelo SEI em Dart.
///
/// Todo modelo expõe mapas distintos para transporte, inserção e atualização.
/// DTOs de consulta herdam os dois últimos métodos com erro explícito, pois
/// não representam uma linha gravável. Uma entidade persistível deve
/// sobrescrevê-los e remover chaves geradas pelo banco quando necessário.
abstract class BaseModel extends SerializeBase {
  static const DeepCollectionEquality _igualdadeProfunda =
      DeepCollectionEquality();

  /// Retorna os campos permitidos em uma inserção.
  ///
  /// Projeções, envelopes, filtros e páginas não possuem semântica de escrita.
  /// Nesses casos, o erro evita que uma resposta de leitura seja usada como SQL
  /// de inserção por acidente.
  Map<String, dynamic> toInsertMap() {
    throw UnsupportedError(
      'O modelo $runtimeType não representa uma entidade persistível.',
    );
  }

  /// Retorna os campos permitidos em uma atualização.
  ///
  /// A chave de identidade deve ser usada no filtro da query, nunca no mapa de
  /// atualização. Entidades persistíveis sobrescrevem este método.
  Map<String, dynamic> toUpdateMap() {
    throw UnsupportedError(
      'O modelo $runtimeType não representa uma entidade persistível.',
    );
  }

  /// Compara DTOs imutáveis pelo conteúdo serializado.
  ///
  /// Entidades futuras com identidade de domínio e estado mutável devem
  /// sobrescrever igualdade e `hashCode` usando sua chave de negócio.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is BaseModel &&
            _igualdadeProfunda.equals(toMap(), other.toMap());
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        _igualdadeProfunda.hash(toMap()),
      );
}
