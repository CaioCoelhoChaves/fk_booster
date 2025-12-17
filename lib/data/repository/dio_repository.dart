import 'package:dio/dio.dart';
import 'package:fk_booster/data/parser/entity_parser.dart';
import 'package:fk_booster/domain/repository/repository.dart';

abstract class DioRepository<Entity> extends Repository<Entity> {
  const DioRepository({required this.dio, required this.baseUrl});
  final Dio dio;
  final String baseUrl;

  String get createUrl => baseUrl;

  @override
  Future<TResponse> rawCreate<TResponse>({
    required Entity entity,
    required ToMap<Entity> entityParser,
    required FromMap<TResponse> responseParser,
  }) async {
    final response = await dio.post<dynamic>(
      createUrl,
      data: entityParser.toMap(entity),
    );
    return responseParser.fromMap(response.data as Map<String, dynamic>);
  }
}
