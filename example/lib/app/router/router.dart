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
        path: RoutePaths.users,
        name: RouteNames.users,
        builder: (_, _) => const UsersPage(),
      ),
    ],
  );
}
