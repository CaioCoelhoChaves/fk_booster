import 'package:fk_booster/core/data/entity_parser/fk_entity_parser.dart';
import 'package:fk_booster/core/data/typedefs.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';
import 'package:fk_booster/core/domain/repository/fk_repository.dart';
import 'package:flutter/foundation.dart';

mixin Save<Entity extends FkEntity, EntityParser extends FkEntityParser<Entity>,
    ReturnType extends Object> on FkRepository<Entity, EntityParser> {
  @protected
  String saveEndpoint() => endpoint();

  @protected
  FkJsonMap Function(Entity) saveToMap();

  @protected
  ReturnType Function(FkJsonMap) saveFromMap();

  Future<ReturnType> save(Entity entity) async {
    final response = await httpClient.post(
      saveEndpoint(),
      data: saveToMap()(entity),
    );
    return saveFromMap()(response.data as Map<String, dynamic>);
  }
}
