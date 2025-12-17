import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:fk_booster/domain/domain.dart';

abstract class UserRepository extends Repository<UserEntity>
    with Create<UserEntity, UserEntity> {}

// GetAll<UserEntity>,
// GetById<UserEntity, String>,
// Delete<UserEntity, String> {}
