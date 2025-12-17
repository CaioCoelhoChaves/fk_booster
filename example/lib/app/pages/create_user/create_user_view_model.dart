import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

class CreateUserViewModel extends StatefulViewModel<UserEntity> {
  CreateUserViewModel(this._userRepository) : super(const UserEntity.empty());
  final UserRepository _userRepository;

  final formKey = GlobalKey<FormState>();

  Future<void> onSavePressed() async {
    if (formKey.currentState!.validate()) await _createUser();
  }

  Future<void> _createUser() async {
    final userCreated = await _userRepository.create(value);
    print(userCreated);
  }
}
