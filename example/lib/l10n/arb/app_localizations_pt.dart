// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Exemplo fk_booster';

  @override
  String get productsTitle => 'Produtos';

  @override
  String get newProduct => 'Novo Produto';

  @override
  String get editProduct => 'Editar Produto';

  @override
  String get name => 'Nome';

  @override
  String get description => 'Descrição';

  @override
  String get price => 'Preço';

  @override
  String get quantity => 'Quantidade';

  @override
  String get active => 'Ativo';

  @override
  String get inactive => 'Inativo';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get errorLoadingProducts => 'Falha ao carregar produtos.';

  @override
  String get errorSavingProduct => 'Falha ao salvar produto.';

  @override
  String get errorDeletingProduct => 'Falha ao excluir produto.';

  @override
  String get productDeleted => 'Produto excluído com sucesso.';

  @override
  String get productSaved => 'Produto salvo com sucesso.';

  @override
  String get emptyProducts => 'Nenhum produto encontrado.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get deleteConfirmTitle => 'Excluir Produto';

  @override
  String get deleteConfirmMessage =>
      'Tem certeza que deseja excluir este produto?';

  @override
  String get nameRequired => 'O nome é obrigatório.';

  @override
  String get priceRequired => 'O preço é obrigatório.';

  @override
  String get priceInvalid => 'Informe um preço válido.';

  @override
  String get quantityInvalid => 'Informe uma quantidade válida.';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produtos',
      one: '1 produto',
      zero: 'Nenhum produto',
    );
    return '$_temp0';
  }
}
