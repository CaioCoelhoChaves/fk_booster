import 'package:example/features/user/domain/user.dart';
import 'package:fk_booster/fk_booster.dart';

class UserParser extends FkEntityParser<User> with FromMap {
  @override
  User fromMap(FkJsonMap map) {
    final data = map['data'] as Map<String, dynamic>;
    return User(
      id: data['id'] as int?,
      username: data['username'] as String?,
      email: data['email'] as String?,
      cellphone: data['cellphone'] as String?,
    );
  }
}
