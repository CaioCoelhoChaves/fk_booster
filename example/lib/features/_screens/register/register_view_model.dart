import 'package:example/features/_screens/register/register_state.dart';
import 'package:example/features/user_registration/data/use_registration_rest_repository.dart';
import 'package:example/features/user_registration/domain/user_registration.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/cupertino.dart';

class RegisterViewModel extends FkViewModel<RegisterState> {
  RegisterViewModel(this._repository) : super(const RegisterState());

  final UserRegistrationRestRepository _repository;
  final registerFormKey = GlobalKey<FormState>();

  UserRegistration get registration => value.registration;
  set registration(UserRegistration registration) {
    value = value.copyWith(registration: registration);
  }

  late final FkCommand register = FkCommand(() async {
    if (registerFormKey.currentState!.validate()) {
      final user = await _repository.create(value.registration);
      debugPrint(user.toString());
    }
  });
}
