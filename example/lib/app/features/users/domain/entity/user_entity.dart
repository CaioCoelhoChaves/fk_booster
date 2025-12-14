import 'package:fk_booster/data/data.dart';
import 'package:fk_booster/domain/domain.dart';

class UserEntity extends Entity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.birthday,
    required this.createdAt,
  });

  final String? id;
  final String? name;
  final String? email;
  final Date? birthday;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    birthday,
    createdAt,
  ];
}

abstract class UserEntityParser extends EntityParser<UserEntity>
    with ToMap, FromMap {}
