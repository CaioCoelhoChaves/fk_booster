import 'package:example/pages/product_form/product_form_page.dart';
import 'package:example/pages/product_list/product_list_page.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

part 'router.g.dart';

/// Type-safe route for the product list page.
@TypedGoRoute<ProductListRoute>(
  name: 'productList',
  path: '/products',
  routes: [
    TypedGoRoute<ProductFormRoute>(
      name: 'productForm',
      path: 'form',
    ),
  ],
)
@immutable
class ProductListRoute extends GoRouteData {
  const ProductListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProductListPage();
  }
}

/// Type-safe route for the product create/edit form.
///
/// When [productId] is null, the form is in create mode.
/// When [productId] is provided (via query parameter),
/// the form is in edit mode.
@immutable
class ProductFormRoute extends GoRouteData {
  const ProductFormRoute({this.productId});

  final String? productId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProductFormPage(productId: productId);
  }
}

/// Application router configuration.
final GoRouter router = GoRouter(
  initialLocation: '/products',
  routes: $appRoutes,
);
