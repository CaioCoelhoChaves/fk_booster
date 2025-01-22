import 'package:fk_booster/fk_booster.dart';

abstract mixin class FkMultipleUpdate<Entity extends FkEntity, ReturnType> {
  Future<ReturnType> multipleUpdate(List<Entity> entities);
}
