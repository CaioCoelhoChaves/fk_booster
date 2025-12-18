import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/features/users/domain/entity/user_entity_parser.dart';
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

  @override
  Future<UserEntity> delete(UserEntity entity) => rawDelete(
    entity: entity,
    idParser: parser,
    responseParser: parser,
  );

  @override
  Future<List<UserEntity>> getAll() => rawGetAll(entityParser: parser);

  @override
  Future<UserEntity> getById(String id) => rawGetById(
    id: id,
    idParser: parser,
    entityParser: parser,
  );
}
