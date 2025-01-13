import 'package:fk_booster/core/domain/entity/fk_entity.dart';

typedef FkJsonMap = Map<String, dynamic>;
typedef FkListMap = List<Map<String, dynamic>>;
typedef FkEntityListParser<Entity extends FkEntity> = Entity Function(
  FkJsonMap map,
);
