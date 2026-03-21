import 'package:example/l10n/l10n_extension.dart';
import 'package:example/routing/router.dart';
import 'package:example/theme/theme.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _registerGlobalDependencies();
  runApp(const ExampleApp());
}

/// Registers application-wide singletons like [Dio].
void _registerGlobalDependencies() {
  GetIt.instance.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    ),
  );
}

/// Root widget of the example application.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'fk_booster Example',
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
