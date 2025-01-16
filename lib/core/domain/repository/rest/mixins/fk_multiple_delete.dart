import 'package:fk_booster/fk_booster.dart';

abstract mixin class FkMultipleDelete<Entity extends FkEntity, ReturnType> {
  Future<ReturnType> multipleDelete(List<Entity> entities);
}
