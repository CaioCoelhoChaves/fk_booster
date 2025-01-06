import 'package:example/features/user_registration/domain/user_registration.dart';
import 'package:fk_booster/fk_booster.dart';

class UserRegistrationParser extends FkEntityParser<UserRegistration>
    with ToMap {
  @override
  Map<String, dynamic> toMap(UserRegistration entity) {
    return {
      'username': entity.username,
      'email': entity.email,
      'cellphone': entity.cellphone,
      'password': entity.password,
    };
  }
}
