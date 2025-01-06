import 'package:fk_booster/core/domain/entity/fk_entity.dart';

class User extends FkEntity {
  const User({
    this.id,
    this.username,
    this.email,
    this.cellphone,
  });

  final int? id;
  final String? username;
  final String? email;
  final String? cellphone;

  @override
  String toString() {
    return 'UserRegistration{username: $username, email: $email, '
        'cellphone: $cellphone}';
  }
}
