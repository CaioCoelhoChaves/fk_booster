import 'package:fk_booster/fk_booster.dart';

abstract mixin class FkDelete<Entity extends FkEntity, ReturnType> {
  Future<ReturnType> delete(Entity entity);
}
