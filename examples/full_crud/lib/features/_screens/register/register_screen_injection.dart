import 'package:example/features/_screens/register/register_view_model.dart';
import 'package:example/features/user_registration/user_registration_injection.dart';
import 'package:fk_booster/fk_booster.dart';

class RegisterScreenInjection extends FkInjection<FkEmpty> {
  const RegisterScreenInjection() : super('register_screen');
  @override
  void call(GetIt i) {
    const UserRegistrationInjection()(i);
    i.registerSingleton(RegisterViewModel(i.get()));
  }
}
