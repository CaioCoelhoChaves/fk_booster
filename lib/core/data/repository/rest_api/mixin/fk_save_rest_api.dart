import 'package:fk_booster/core/data/entity_parser/fk_entity_parser.dart';
import 'package:fk_booster/core/data/repository/rest_api/fk_rest_api_repository.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';
import 'package:fk_booster/core/domain/repository/rest/mixins/fk_save.dart';
import 'package:flutter/foundation.dart';

mixin FkSaveRestApi<
        Entity extends FkEntity,
        EntityParser extends FkEntityParser<Entity>,
        ReturnType extends Object> on FkRestApiRepository<Entity, EntityParser>
    implements FkSave<Entity, EntityParser, ReturnType> {
  @protected
  String saveEndpoint() => endpoint();

  @override
  Future<ReturnType> save(Entity entity) async {
    final response = await httpClient.post(
      saveEndpoint(),
      data: saveToMap(entity),
    );
    return saveFromMap(response.data as Map<String, dynamic>);
  }
}
