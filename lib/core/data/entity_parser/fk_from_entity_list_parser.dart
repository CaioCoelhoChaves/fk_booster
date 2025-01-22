import 'package:fk_booster/core/data/typedefs.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';

FkJsonList fkFromEntityListParser<Entity extends FkEntity>(
  List<Entity> items,
  FkJsonMap Function(Entity entity) fromEntity,
) {
  return items.map((e) => fromEntity(e)).toList();
}
