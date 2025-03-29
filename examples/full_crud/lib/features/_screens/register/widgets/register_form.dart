part of '../register_screen.dart';

class _RegisterForm extends StatelessWidget {
  const _RegisterForm(this.viewModel);
  final RegisterViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextInput(
          required: true,
          label: 'Username',
          onChanged: (text) {
            viewModel.registration = viewModel.registration.copyWith(
              username: text,
            );
          },
        ),
        const Gap.y(10),
        TextInput(
          required: true,
          label: 'Full Name',
          onChanged: (text) {
            viewModel.registration = viewModel.registration.copyWith(
              fullName: text,
            );
          },
        ),
        const Gap.y(10),
        TextInput(
          required: true,
          label: 'Email',
          onChanged: (text) {
            viewModel.registration = viewModel.registration.copyWith(
              email: text,
            );
          },
        ),
        const Gap.y(10),
        TextInput(
          required: true,
          label: 'Cellphone',
          onChanged: (text) {
            viewModel.registration = viewModel.registration.copyWith(
              email: text,
            );
          },
        ),
        const Gap.y(10),
        PasswordInput(
          label: 'Password',
          onChanged: (text) {
            viewModel.registration = viewModel.registration.copyWith(
              password: text,
            );
          },
        ),
        const Gap.y(10),
        PasswordInput(
          label: 'Repeat Password',
          onChanged: (text) {
            viewModel.registration = viewModel.registration.copyWith(
              repeatPassword: text,
            );
          },
        ),
      ],
    );
  }
}
