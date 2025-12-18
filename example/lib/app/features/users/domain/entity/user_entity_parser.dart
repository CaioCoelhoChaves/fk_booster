import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:fk_booster/data/parser/entity_parser.dart';

abstract class UserEntityParser extends EntityParser<UserEntity>
    with ToMap, FromMap, GetId<UserEntity, String> {}
