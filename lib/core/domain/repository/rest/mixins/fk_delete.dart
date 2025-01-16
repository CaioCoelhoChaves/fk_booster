import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/foundation.dart';

abstract mixin class FkDelete<Entity extends FkEntity> {
  @protected
  FkJsonMap saveToMap(Entity entity);

  Future<void> delete(Entity entity);
}
