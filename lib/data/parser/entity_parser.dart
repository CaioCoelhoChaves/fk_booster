import 'package:fk_booster/data/typedefs.dart';

abstract class EntityParser<Entity> {
  const EntityParser();
}

mixin FromMap<Entity> on EntityParser<Entity> {
  Entity fromMap(JsonMap map);
}

mixin ToMap<Entity> on EntityParser<Entity> {
  JsonMap toMap(Entity entity);
}

mixin GetId<Entity, ID> on EntityParser<Entity> {
  ID getId(Entity entity);
}
