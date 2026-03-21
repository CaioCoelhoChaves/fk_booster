// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'fk_booster Example';

  @override
  String get productsTitle => 'Products';

  @override
  String get newProduct => 'New Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get quantity => 'Quantity';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get errorLoadingProducts => 'Failed to load products.';

  @override
  String get errorSavingProduct => 'Failed to save product.';

  @override
  String get errorDeletingProduct => 'Failed to delete product.';

  @override
  String get productDeleted => 'Product deleted successfully.';

  @override
  String get productSaved => 'Product saved successfully.';

  @override
  String get emptyProducts => 'No products found.';

  @override
  String get retry => 'Retry';

  @override
  String get deleteConfirmTitle => 'Delete Product';

  @override
  String get deleteConfirmMessage =>
      'Are you sure you want to delete this product?';

  @override
  String get nameRequired => 'Name is required.';

  @override
  String get priceRequired => 'Price is required.';

  @override
  String get priceInvalid => 'Please enter a valid price.';

  @override
  String get quantityInvalid => 'Please enter a valid quantity.';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'No products',
    );
    return '$_temp0';
  }
}
