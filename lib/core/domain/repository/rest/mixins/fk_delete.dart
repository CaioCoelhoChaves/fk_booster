import 'package:fk_booster/fk_booster.dart';

abstract mixin class FkDelete<Entity extends FkEntity> {
  Future<void> delete(Entity entity);
}
