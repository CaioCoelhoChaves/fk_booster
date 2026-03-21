import 'dart:async';

import 'package:example/features/product/domain/entity/product_entity.dart';
import 'package:example/features/product/domain/repository/product_repository.dart';
import 'package:fk_booster/fk_booster.dart';

/// ViewModel for the product create/edit form.
///
/// Uses [Command1] for both saving and loading product data.
/// Determines create vs update behavior based on whether [productId] is set.
class ProductFormViewModel extends StatelessViewModel {
  ProductFormViewModel({
    required ProductRepository productRepository,
    this.productId,
  }) : _productRepository = productRepository;

  final ProductRepository _productRepository;

  /// If non-null, the form is in edit mode for this product.
  final String? productId;

  /// Whether the form is editing an existing product.
  bool get isEditing => productId != null;

  /// Loads an existing product for editing.
  late final Command1<ProductEntity, String> loadProduct = Command1(
    _productRepository.getById,
  );

  /// Saves a product — creates new or updates existing.
  late final Command1<ProductEntity, ProductEntity> saveProduct = Command1(
    (entity) {
      if (isEditing) {
        return _productRepository.update(entity);
      }
      return _productRepository.create(entity);
    },
  );

  @override
  void onViewInit() {
    if (productId != null) {
      unawaited(loadProduct.execute(productId!));
    }
  }
}
