import 'package:example/features/initial_injection.dart';
import 'package:example/router/app_router.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

void main() {
  const InitialInjection()(GetIt.I);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
