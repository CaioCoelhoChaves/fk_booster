import 'package:example/features/product/data/entity_parser/product_api_parser.dart';
import 'package:example/features/product/domain/entity/paginated_response.dart';
import 'package:example/features/product/domain/entity/product_entity.dart';
import 'package:example/features/product/domain/repository/product_repository.dart';
import 'package:fk_booster/fk_booster.dart';

/// Concrete HTTP implementation of [ProductRepository].
///
/// Extends [DioRepository] for standard CRUD helpers and adds custom
/// implementations for paginated listing and void-returning delete.
class ProductApiRepository extends DioRepository<ProductEntity>
    implements ProductRepository {
  const ProductApiRepository({
    required this.parser,
    required super.dio,
  }) : super(baseUrl: '/api/v1/products');

  final ProductApiParser parser;

  @override
  Future<ProductEntity> create(ProductEntity entity) => rawCreate(
    entity: entity,
    entityParser: parser,
    responseParser: parser,
  );

  @override
  Future<ProductEntity> getById(String id) => rawGetById(
    id: id,
    idParser: parser,
    entityParser: parser,
  );

  @override
  Future<ProductEntity> update(ProductEntity entity) => rawUpdate(
    entity: entity,
    entityParser: parser,
    idParser: parser,
    responseParser: parser,
  );

  /// Custom paginated getProducts — bypasses [rawGetAll] because the API
  /// returns a paginated object instead of a raw list.
  @override
  Future<PaginatedResponse<ProductEntity>> getProducts({
    int page = 1,
    int perPage = 10,
    String? name,
    bool? active,
    double? minPrice,
    double? maxPrice,
  }) async {
    final response = await dio.get<dynamic>(
      baseUrl,
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'name': ?name,
        'active': ?active,
        'min_price': ?minPrice,
        'max_price': ?maxPrice,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>)
        .map((e) => parser.fromMap(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<ProductEntity>(
      items: items,
      total: data['total'] as int,
      page: data['page'] as int,
      perPage: data['per_page'] as int,
      totalPages: data['total_pages'] as int,
    );
  }

  /// Custom delete — the API returns 204 No Content with no body,
  /// so [rawDelete] (which expects a parseable response) cannot be used.
  @override
  Future<void> deleteProduct(String id) async {
    await dio.delete<dynamic>('$baseUrl/$id');
  }
}
