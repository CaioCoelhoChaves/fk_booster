import 'package:example/app/router/router.dart';
import 'package:fk_booster/fk_booster.dart';

class StartupInjection extends DependencyInjection {
  const StartupInjection() : super('Startup');

  @override
  Future<void> registerDependencies(GetIt i) async {
    await super.registerDependencies(i);
    i.registerLazySingleton(AppRouter.new);
  }
}
