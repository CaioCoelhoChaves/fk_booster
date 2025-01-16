import 'package:fk_booster/fk_booster.dart';

abstract mixin class FkMultipleDelete<Entity extends FkEntity> {
  Future<void> multipleDelete(List<Entity> entities);
}
