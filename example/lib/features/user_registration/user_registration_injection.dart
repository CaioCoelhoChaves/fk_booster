import 'package:example/features/user/data/user_parser.dart';
import 'package:example/features/user_registration/data/user_registration_parser.dart';
import 'package:example/features/user_registration/data/use_registration_rest_repository.dart';
import 'package:fk_booster/fk_booster.dart';

class UserRegistrationInjection extends FkInjection<FkEmpty> {
  const UserRegistrationInjection() : super('user_registration');
  @override
  void call(GetIt i) {
    i
      ..registerSingleton(UserRegistrationParser())
      ..registerSingleton(UserParser())
      ..registerSingleton(
        UserRegistrationRestRepository(
          httpClient: i.get(),
          parser: i.get(),
          userParser: i.get(),
        ),
      );
  }
}
