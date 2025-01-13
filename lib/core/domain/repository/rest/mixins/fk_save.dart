import 'package:fk_booster/core/data/entity_parser/fk_entity_parser.dart';
import 'package:fk_booster/core/data/typedefs.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';
import 'package:flutter/foundation.dart';

abstract mixin class FkSave<Entity extends FkEntity,
    EntityParser extends FkEntityParser<Entity>, ReturnType extends Object> {
  @protected
  FkJsonMap saveToMap(Entity entity);

  @protected
  ReturnType saveFromMap(FkJsonMap map);
  Future<ReturnType> save(Entity entity);
}
