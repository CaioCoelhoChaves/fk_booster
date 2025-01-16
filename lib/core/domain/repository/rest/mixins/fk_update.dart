import 'package:fk_booster/core/data/entity_parser/fk_entity_parser.dart';
import 'package:fk_booster/core/data/typedefs.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';
import 'package:flutter/foundation.dart';

abstract mixin class FkUpdate<Entity extends FkEntity,
    EntityParser extends FkEntityParser<Entity>, ReturnType> {
  @protected
  FkJsonMap updateToMap(Entity entity);

  @protected
  ReturnType updateFromMap(FkJsonMap map);
  Future<ReturnType> update(Entity entity);
}
