import 'package:fk_booster/core/domain/entity/fk_entity.dart';

abstract mixin class FkGetAll<Entity extends FkEntity> {
  Future<List<Entity>> getAll();
}
