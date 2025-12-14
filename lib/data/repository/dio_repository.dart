import 'package:dio/dio.dart';
import 'package:fk_booster/domain/repository/repository.dart';

abstract class DioRepository<Entity> extends Repository<Entity> {
  const DioRepository({required this.dio});
  final Dio dio;

  Entity create(Entity entity)
}
