import 'package:example/core/widgets/password_input.dart';
import 'package:example/core/widgets/text_input.dart';
import 'package:example/features/_screens/register/register_view_model.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

part 'widgets/register_submit_button.dart';
part 'widgets/register_form.dart';

class RegisterScreen extends FkView<RegisterViewModel> {
  const RegisterScreen({
    required super.viewModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: viewModel.registerFormKey,
            child: Column(
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Gap.y(15),
                _RegisterForm(viewModel),
                const Gap.y(25),
                _SubmitButton(viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
