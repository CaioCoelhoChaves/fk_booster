import 'package:fk_booster/domain/entity/entity.dart';

typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<Map<String, dynamic>>;
typedef EntityListParser<EntityT extends Entity> = EntityT Function(
    JsonMap map);
