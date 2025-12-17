import 'package:example/app/pages/create_user/create_user_view_model.dart';
import 'package:fk_booster/fk_booster.dart';

class CreateUserInjection extends DependencyInjection {
  CreateUserInjection() : super('create-user');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    i.registerLazySingleton(CreateUserViewModel.new);
  }
}
