import 'package:fk_booster/core/domain/entity/fk_entity.dart';

class UserRegistration extends FkEntity {
  const UserRegistration({
    this.username,
    this.fullName,
    this.email,
    this.cellphone,
    this.password,
    this.repeatPassword,
  });

  final String? username;
  final String? fullName;
  final String? email;
  final String? cellphone;
  final String? password;
  final String? repeatPassword;

  UserRegistration copyWith({
    String? username,
    String? fullName,
    String? email,
    String? cellphone,
    String? password,
    String? repeatPassword,
  }) {
    return UserRegistration(
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      cellphone: cellphone ?? this.cellphone,
      password: password ?? this.password,
      repeatPassword: repeatPassword ?? this.repeatPassword,
    );
  }
}
