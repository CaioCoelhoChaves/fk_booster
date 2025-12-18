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

  String get getByIdUrl => '$baseUrl/:id';
  @override
  Future<Entity> rawGetById<ID>({
    required ID id,
    required GetId<Entity, ID> idParser,
    required FromMap<Entity> entityParser,
  }) async {
    final url = getByIdUrl.replaceAll(':id', id.toString());
    final response = await dio.get<dynamic>(url);
    return entityParser.fromMap(response.data as Map<String, dynamic>);
  }

  String get getAllUrl => baseUrl;
  @override
  Future<List<Entity>> rawGetAll({
    required FromMap<Entity> entityParser,
  }) async {
    final response = await dio.get<dynamic>(getAllUrl);
    final list = response.data as List<dynamic>;
    return list
        .map((item) => entityParser.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  String get updateUrl => '$baseUrl/:id';
  @override
  Future<TResponse> rawUpdate<TResponse, ID>({
    required Entity entity,
    required ToMap<Entity> entityParser,
    required GetId<Entity, ID> idParser,
    required FromMap<TResponse> responseParser,
  }) async {
    final id = idParser.getId(entity);
    final url = updateUrl.replaceAll(':id', id.toString());
    final response = await dio.put<dynamic>(
      url,
      data: entityParser.toMap(entity),
    );
    return responseParser.fromMap(response.data as Map<String, dynamic>);
  }

  String get deleteUrl => '$baseUrl/:id';
  @override
  Future<TResponse> rawDelete<TResponse, ID>({
    required Entity entity,
    required GetId<Entity, ID> idParser,
    required FromMap<TResponse> responseParser,
  }) async {
    final id = idParser.getId(entity);
    final url = deleteUrl.replaceAll(':id', id.toString());
    final response = await dio.delete<dynamic>(url);
    return responseParser.fromMap(response.data as Map<String, dynamic>);
  }
}
