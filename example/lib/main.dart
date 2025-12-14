import 'package:example/app/app.dart';
import 'package:example/app/startup_injection.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await const StartupInjection().registerDependencies(GetIt.I);
  runApp(const App());
}
