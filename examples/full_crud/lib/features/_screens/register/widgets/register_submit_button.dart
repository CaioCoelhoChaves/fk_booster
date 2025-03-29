part of '../register_screen.dart';

class _SubmitButton extends StatelessWidget {
  const _SubmitButton(this.viewModel);
  final RegisterViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final isRegisterLoading = viewModel.register.running.watch(context);
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 15),
        onPressed: isRegisterLoading ? null : viewModel.register.execute,
        color: Colors.blue,
        disabledColor: Colors.grey,
        child: Visibility(
          visible: isRegisterLoading,
          replacement: const Text(
            'Create Account',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          child: const Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
