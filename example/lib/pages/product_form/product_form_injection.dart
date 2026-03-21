import 'package:example/features/product/data/entity_parser/product_api_parser.dart';
import 'package:example/features/product/data/repository/product_api_repository.dart';
import 'package:example/features/product/domain/repository/product_repository.dart';
import 'package:example/pages/product_form/product_form_view_model.dart';
import 'package:fk_booster/fk_booster.dart';

/// Registers scoped dependencies for the product form page.
class ProductFormInjection extends DependencyInjection {
  ProductFormInjection({this.productId}) : super('ProductFormScope');

  /// If non-null, the form will load this product for editing.
  final String? productId;

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);

    i
      ..registerFactory<ProductApiParser>(ProductApiParser.new)
      ..registerFactory<ProductRepository>(
        () => ProductApiRepository(
          parser: i<ProductApiParser>(),
          dio: i<Dio>(),
        ),
      )
      ..registerFactory<ProductFormViewModel>(
        () => ProductFormViewModel(
          productRepository: i<ProductRepository>(),
          productId: productId,
        ),
      );
  }
}
