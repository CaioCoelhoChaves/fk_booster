import 'package:fk_booster/core/domain/entity/fk_entity.dart';

abstract mixin class FkCreate<Entity extends FkEntity, ReturnType> {
  Future<ReturnType> create(Entity entity);
}
