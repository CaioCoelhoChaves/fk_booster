import 'package:fk_booster/core/domain/entity/fk_entity.dart';

abstract mixin class FkUpdate<Entity extends FkEntity, ReturnType> {
  Future<ReturnType> update(Entity entity);
}
