import 'package:example/features/_screens/register/register_screen.dart';
import 'package:example/features/_screens/register/register_screen_injection.dart';
import 'package:example/features/_screens/register/register_view_model.dart';
import 'package:example/router/routes.dart';
import 'package:fk_booster/fk_booster.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.register,
  routes: [
    FkRoute<RegisterViewModel, RegisterScreen, FkEmpty>(
      injection: const RegisterScreenInjection(),
      path: Routes.register,
      pageBuilder: (context, routeState, viewModel) {
        return RegisterScreen(viewModel: viewModel);
      },
    ),
  ],
);
