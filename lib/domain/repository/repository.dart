import 'package:fk_booster/data/data.dart';

abstract class Repository<Entity> {
  const Repository();

  Future<TResponse> rawCreate<TResponse>({
    required Entity entity,
    required ToMap<Entity> entityParser,
    required FromMap<TResponse> responseParser,
  });
}
