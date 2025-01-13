import 'package:fk_booster/core/data/entity_parser/fk_entity_parser.dart';
import 'package:fk_booster/core/data/typedefs.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';
import 'package:flutter/foundation.dart';

abstract mixin class FkGetAll<Entity extends FkEntity,
    EntityParser extends FkEntityParser<Entity>> {
  @protected
  FkJsonMap Function(Entity) getAllToMap();

  @protected
  List<Entity> Function(FkJsonMap) getAllFromMap();

  Future<List<Entity>> save(Entity entity);
}
