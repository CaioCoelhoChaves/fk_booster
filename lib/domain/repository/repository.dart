import 'package:fk_booster/data/data.dart';

abstract class Repository<Entity> {
  const Repository();

  Future<TResponse> rawCreate<TResponse>({
    required Entity entity,
    required ToMap<Entity> entityParser,
    required FromMap<TResponse> responseParser,
  });

  Future<Entity> rawGetById<ID>({
    required ID id,
    required GetId<Entity, ID> idParser,
    required FromMap<Entity> entityParser,
  });

  Future<List<Entity>> rawGetAll({
    required FromMap<Entity> entityParser,
  });

  Future<TResponse> rawUpdate<TResponse, ID>({
    required Entity entity,
    required ToMap<Entity> entityParser,
    required GetId<Entity, ID> idParser,
    required FromMap<TResponse> responseParser,
  });

  Future<TResponse> rawDelete<TResponse, ID>({
    required Entity entity,
    required GetId<Entity, ID> idParser,
    required FromMap<TResponse> responseParser,
  });
}
