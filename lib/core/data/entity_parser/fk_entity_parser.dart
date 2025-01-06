import 'package:fk_booster/core/data/typedefs.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';

class FkEntityParser<Entity extends FkEntity> {
  const FkEntityParser();
}

mixin FromMap<Entity extends FkEntity> on FkEntityParser<Entity> {
  Entity fromMap(FkJsonMap map);
}

mixin ToMap<Entity extends FkEntity> on FkEntityParser<Entity> {
  FkJsonMap toMap(Entity entity);
}
