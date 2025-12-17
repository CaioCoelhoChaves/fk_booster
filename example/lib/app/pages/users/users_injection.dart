import 'package:example/app/pages/users/users_view_model.dart';
import 'package:fk_booster/fk_booster.dart';

class UsersInjection extends DependencyInjection {
  UsersInjection() : super('users');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    i.registerLazySingleton(UsersViewModel.new);
  }
}
