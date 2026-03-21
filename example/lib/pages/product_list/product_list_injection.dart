import 'package:example/features/product/data/entity_parser/product_api_parser.dart';
import 'package:example/features/product/data/repository/product_api_repository.dart';
import 'package:example/features/product/domain/repository/product_repository.dart';
import 'package:example/pages/product_list/product_list_view_model.dart';
import 'package:fk_booster/fk_booster.dart';

/// Registers scoped dependencies for the product list page.
class ProductListInjection extends DependencyInjection {
  ProductListInjection() : super('ProductListScope');

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
      ..registerFactory<ProductListViewModel>(
        () => ProductListViewModel(
          productRepository: i<ProductRepository>(),
        ),
      );
  }
}
