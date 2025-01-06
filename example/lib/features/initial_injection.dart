import 'package:fk_booster/fk_booster.dart';

class InitialInjection extends FkInjection {
  @override
  void call(GetIt i) {
    i.registerSingleton<FkHttpClient>(
      FkDioHttpClient(baseUrl: 'http://localhost:8080/api'),
    );
  }
}
