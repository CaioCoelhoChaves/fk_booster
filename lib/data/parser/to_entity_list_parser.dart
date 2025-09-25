import 'package:fk_booster/data/typedefs.dart';

List<Entity> toEntityListParser<Entity>(
  JsonList items,
  Entity Function(JsonMap map) fromMap,
) {
  return items.map((e) => fromMap(e)).toList();
}
