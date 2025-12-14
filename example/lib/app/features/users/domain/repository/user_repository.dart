import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:fk_booster/domain/domain.dart';

abstract class UserRepository extends Repository<UserEntity>
    with
        GetAll<UserEntity>,
        Create<UserEntity, String>,
        GetById<UserEntity, String>,
        Delete<UserEntity, String> {}
