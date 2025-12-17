import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

class CreateUserViewModel extends StatefulViewModel<UserEntity> {
  CreateUserViewModel() : super(const UserEntity.empty());

  final formKey = GlobalKey<FormState>();
}
