import 'package:fk_booster/core/data/entity_parser/fk_entity_parser.dart';
import 'package:fk_booster/core/data/typedefs.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';
import 'package:flutter/foundation.dart';

abstract mixin class FkGetAll<Entity extends FkEntity,
    EntityParser extends FkEntityParser<Entity>> {
  @protected
  List<Entity> getAllFromMap(
    FkListMap list,
    FkEntityListParser<Entity> fromMap,
  );

  Future<List<Entity>> getAll();
}
