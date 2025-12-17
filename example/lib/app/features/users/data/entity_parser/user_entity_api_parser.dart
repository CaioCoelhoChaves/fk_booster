import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:fk_booster/fk_booster.dart';

class UserEntityApiParser extends UserEntityParser {
  @override
  UserEntity fromMap(JsonMap map) {
    return UserEntity(
      id: map.getString('id'),
      name: map.getString('name'),
      email: map.getString('email'),
      birthday: map.getDate('birthday'),
      description: map.getString('description'),
      createdAt: map.getDateTime('created_at'),
    );
  }

  @override
  JsonMap toMap(UserEntity e) => JsonMap()
    ..add('id', e.id)
    ..add('name', e.name)
    ..add('email', e.email)
    ..add('description', e.description)
    ..add('birthday', e.birthday.toApi());
}
