import 'package:fk_booster/core/data/entity_parser/fk_entity_parser.dart';
import 'package:fk_booster/core/data/repository/rest_api/fk_rest_api_repository.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';
import 'package:fk_booster/core/domain/repository/rest/mixins/fk_create.dart';
import 'package:flutter/foundation.dart';

mixin FkRestCreate<
        Entity extends FkEntity,
        EntityParser extends FkEntityParser<Entity>,
        ReturnType extends Object> on FkRestApiRepository<Entity, EntityParser>
    implements FkCreate<Entity, EntityParser, ReturnType> {
  @protected
  String createEndpoint() => endpoint();

  @override
  Future<ReturnType> create(Entity entity) async {
    final response = await httpClient.post(
      createEndpoint(),
      data: createToMap(entity),
    );
    return createFromMap(response.data as Map<String, dynamic>);
  }
}
