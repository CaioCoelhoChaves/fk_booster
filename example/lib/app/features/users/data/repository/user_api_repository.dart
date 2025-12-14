import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:fk_booster/data/data.dart';

class UserApiRepository extends DioRepository<UserEntity>
    implements UserRepository {
  const UserApiRepository({required this.parser, required super.dio});
  final UserEntityParser parser;

  @override
  Future<String> create(UserEntity entity) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<List<UserEntity>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<String> delete(UserEntity entity) {
    // TODO: implement delete
    throw UnimplementedError();
  }
}
