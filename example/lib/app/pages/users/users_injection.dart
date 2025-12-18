import 'package:example/app/features/users/data/entity_parser/user_entity_api_parser.dart';
import 'package:example/app/features/users/data/repository/user_api_repository.dart';
import 'package:example/app/features/users/domain/entity/user_entity_parser.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:example/app/pages/users/users_view_model.dart';
import 'package:fk_booster/fk_booster.dart';

class UsersInjection extends DependencyInjection {
  UsersInjection() : super('users');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    i
      ..registerLazySingleton<UserEntityParser>(UserEntityApiParser.new)
      ..registerLazySingleton<UserRepository>(
        () => UserApiRepository(
          parser: i.get<UserEntityParser>(),
          dio: i.get<Dio>(),
        ),
      )
      ..registerLazySingleton<UsersViewModel>(
        () => UsersViewModel(userRepository: i.get<UserRepository>()),
      );
  }
}
