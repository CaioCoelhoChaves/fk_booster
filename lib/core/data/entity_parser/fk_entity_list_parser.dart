import 'package:fk_booster/core/data/typedefs.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';

List<Entity> fkEntityListParser<Entity extends FkEntity>(
  FkListMap items,
  Entity Function(FkJsonMap map) fromMap,
) {
  return items.map((e) => fromMap(e)).toList();
}
