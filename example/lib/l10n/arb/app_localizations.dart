import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'fk_booster Example'**
  String get appTitle;

  /// Title for the products list page
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// Title for the new product form
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get newProduct;

  /// Title for the edit product form
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// Label for the name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Label for the description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Label for the price field
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Label for the quantity field
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Label for the active toggle
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Label when product is inactive
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Label for the save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Label for the delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Label for the cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Error message when product list fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load products.'**
  String get errorLoadingProducts;

  /// Error message when saving a product fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save product.'**
  String get errorSavingProduct;

  /// Error message when deleting a product fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product.'**
  String get errorDeletingProduct;

  /// Success message after deleting a product
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully.'**
  String get productDeleted;

  /// Success message after saving a product
  ///
  /// In en, this message translates to:
  /// **'Product saved successfully.'**
  String get productSaved;

  /// Message shown when the product list is empty
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get emptyProducts;

  /// Label for the retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Title for the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteConfirmTitle;

  /// Message in the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get deleteConfirmMessage;

  /// Validation message for empty name field
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get nameRequired;

  /// Validation message for empty price field
  ///
  /// In en, this message translates to:
  /// **'Price is required.'**
  String get priceRequired;

  /// Validation message for invalid price
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price.'**
  String get priceInvalid;

  /// Validation message for invalid quantity
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity.'**
  String get quantityInvalid;

  /// Label showing the number of products
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No products} =1{1 product} other{{count} products}}'**
  String productCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
