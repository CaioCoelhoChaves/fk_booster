import 'package:example/app/router/router.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FK Booster Example',
      routerConfig: GetIt.I.get<AppRouter>().router,
    );
  }
}
