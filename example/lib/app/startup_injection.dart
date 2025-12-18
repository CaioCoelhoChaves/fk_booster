import 'package:example/app/router/router.dart';
import 'package:fk_booster/fk_booster.dart';

class StartupInjection extends DependencyInjection {
  const StartupInjection() : super('Startup');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    i
      ..registerLazySingleton(
        () => Dio()
          ..options = BaseOptions(
            baseUrl: 'http://localhost:8000',
          ),
      )
      ..registerLazySingleton(AppRouter.new);
  }
}
