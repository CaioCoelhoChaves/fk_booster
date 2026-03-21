// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$productListRoute];

RouteBase get $productListRoute => GoRouteData.$route(
  path: '/products',
  name: 'productList',

  factory: $ProductListRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: 'form',
      name: 'productForm',

      factory: $ProductFormRouteExtension._fromState,
    ),
  ],
);

extension $ProductListRouteExtension on ProductListRoute {
  static ProductListRoute _fromState(GoRouterState state) =>
      const ProductListRoute();

  String get location => GoRouteData.$location('/products');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ProductFormRouteExtension on ProductFormRoute {
  static ProductFormRoute _fromState(GoRouterState state) =>
      ProductFormRoute(productId: state.uri.queryParameters['product-id']);

  String get location => GoRouteData.$location(
    '/products/form',
    queryParams: {if (productId != null) 'product-id': productId},
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
