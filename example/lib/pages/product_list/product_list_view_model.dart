import 'dart:async';

import 'package:example/features/product/domain/entity/paginated_response.dart';
import 'package:example/features/product/domain/entity/product_entity.dart';
import 'package:example/features/product/domain/repository/product_repository.dart';
import 'package:fk_booster/fk_booster.dart';

/// ViewModel for the product list page.
///
/// Uses [Command0] to fetch the paginated product list and
/// [Command1] to delete a product by ID.
class ProductListViewModel extends StatelessViewModel {
  ProductListViewModel({required ProductRepository productRepository})
    : _productRepository = productRepository;

  final ProductRepository _productRepository;

  /// Fetches the paginated list of products.
  late final Command0<PaginatedResponse<ProductEntity>> fetchProducts =
      Command0(_productRepository.getProducts);

  /// Deletes a product by its ID, then refreshes the list.
  late final Command1<void, String> deleteProduct = Command1(
    (id) async {
      await _productRepository.deleteProduct(id);
      await fetchProducts.execute();
    },
  );

  @override
  void onViewInit() => unawaited(fetchProducts.execute());
}
