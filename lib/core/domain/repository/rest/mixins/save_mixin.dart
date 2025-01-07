import 'package:fk_booster/core/data/entity_parser/fk_entity_parser.dart';
import 'package:fk_booster/core/data/typedefs.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';
import 'package:flutter/foundation.dart';

abstract mixin class Save<Entity extends FkEntity,
    EntityParser extends FkEntityParser<Entity>, ReturnType extends Object> {
  @protected
  FkJsonMap Function(Entity) saveToMap();

  @protected
  ReturnType Function(FkJsonMap) saveFromMap();
  Future<ReturnType> save(Entity entity);
}
