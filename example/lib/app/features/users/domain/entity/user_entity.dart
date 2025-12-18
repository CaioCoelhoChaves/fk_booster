import 'package:fk_booster/domain/domain.dart';

class UserEntity extends Entity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.birthday,
    required this.description,
    required this.createdAt,
  });

  const UserEntity.empty()
    : id = null,
      name = null,
      email = null,
      birthday = null,
      description = null,
      createdAt = null;

  final String? id;
  final String? name;
  final String? email;
  final Date? birthday;
  final String? description;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    birthday,
    description,
    createdAt,
  ];

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    Date? birthday,
    String? description,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
