import 'package:example/features/user_registration/domain/user_registration.dart';
import 'package:fk_booster/core/ui/fk_view_state.dart';

class RegisterState extends FkViewState {
  const RegisterState({
    this.registration = const UserRegistration(),
  });

  final UserRegistration registration;

  RegisterState copyWith({
    UserRegistration? registration,
  }) {
    return RegisterState(
      registration: registration ?? this.registration,
    );
  }
}
