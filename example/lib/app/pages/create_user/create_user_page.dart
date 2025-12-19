import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/pages/create_user/create_user_injection.dart';
import 'package:example/app/pages/create_user/create_user_view_model.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState
    extends ViewState<CreateUserPage, CreateUserViewModel> {
  UserEntity get form => viewModel.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: .start,
            spacing: 15,
            children: [
              TextFormField(
                decoration: const InputDecoration(label: Text('Name')),
                onChanged: (value) => viewModel.value = form.copyWith(
                  name: value,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(label: Text('Email')),
                onChanged: (value) => viewModel.value = form.copyWith(
                  email: value,
                ),
              ),
              InputDatePickerFormField(
                fieldLabelText: 'Birthday',
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                onDateSubmitted: (value) => viewModel.value = form.copyWith(
                  birthday: Date.fromDateTime(value),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(label: Text('Description')),
                onChanged: (value) => viewModel.value = form.copyWith(
                  description: value,
                ),
              ),
              ElevatedButton(
                onPressed: viewModel.onSavePressed,
                child: const Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  DependencyInjection? get injection => CreateUserInjection();
}
