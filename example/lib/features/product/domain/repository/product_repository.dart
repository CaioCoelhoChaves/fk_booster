import 'package:example/features/product/domain/entity/paginated_response.dart';
import 'package:example/features/product/domain/entity/product_entity.dart';
import 'package:fk_booster/fk_booster.dart';

/// Domain contract for product data operations.
///
/// Extends [Repository] with standard CRUD mixins and adds custom methods
/// for paginated listing and void-returning delete.
abstract class ProductRepository extends Repository<ProductEntity>
    with
        Create<ProductEntity, ProductEntity>,
        GetById<ProductEntity, String>,
        Update<ProductEntity, ProductEntity> {
  /// Fetches a paginated, filterable list of products.
  Future<PaginatedResponse<ProductEntity>> getProducts({
    int page = 1,
    int perPage = 10,
    String? name,
    bool? active,
    double? minPrice,
    double? maxPrice,
  });

  /// Deletes a product by its [id]. Returns nothing (204 No Content).
  Future<void> deleteProduct(String id);
}
