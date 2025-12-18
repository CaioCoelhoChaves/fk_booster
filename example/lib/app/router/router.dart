import 'package:example/app/pages/create_user/create_user_page.dart';
import 'package:example/app/pages/users/users_page.dart';
import 'package:example/app/router/route_names.dart';
import 'package:example/app/router/route_paths.dart';
import 'package:fk_booster/fk_booster.dart';

class AppRouter {
  AppRouter();

  final GoRouter router = GoRouter(
    initialLocation: RoutePaths.users,
    routes: <RouteBase>[
      GoRoute(
        name: RouteNames.users,
        path: RoutePaths.users,
        builder: (_, _) => const UsersPage(),
        routes: [
          GoRoute(
            name: RouteNames.createUser,
            path: RoutePaths.create,
            builder: (_, _) => const CreateUserPage(),
          ),
        ],
      ),
    ],
  );
}
