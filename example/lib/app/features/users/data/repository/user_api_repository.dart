import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:fk_booster/data/data.dart';

class UserApiRepository extends DioRepository<UserEntity>
    implements UserRepository {
  const UserApiRepository({
    required this.parser,
    required super.dio,
  }) : super(baseUrl: '/users');
  final UserEntityParser parser;

  @override
  Future<UserEntity> create(UserEntity entity) => rawCreate(
    entity: entity,
    entityParser: parser,
    responseParser: parser,
  );
}
