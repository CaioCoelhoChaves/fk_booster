import 'package:example/features/product/domain/entity/product_entity.dart';
import 'package:example/l10n/l10n_extension.dart';
import 'package:example/pages/product_form/product_form_injection.dart';
import 'package:example/pages/product_form/product_form_view_model.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Product create/edit form page.
///
/// Demonstrates [ViewState] with a form, [Command1] for saving,
/// and [CommandBuilder] for loading existing product data.
class ProductFormPage extends StatefulWidget {
  const ProductFormPage({this.productId, super.key});

  final String? productId;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState
    extends ViewState<ProductFormPage, ProductFormViewModel> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  bool _active = true;

  @override
  DependencyInjection get injection =>
      ProductFormInjection(productId: widget.productId);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _quantityController = TextEditingController(text: '0');
  }

  @override
  Future<void> dispose() async {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    await super.dispose();
  }

  void _populateFields(ProductEntity product) {
    _nameController.text = product.name ?? '';
    _descriptionController.text = product.description ?? '';
    _priceController.text = product.price ?? '';
    _quantityController.text = product.quantity.toString();
    setState(() => _active = product.active);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final entity = ProductEntity(
      id: widget.productId ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      price: _priceController.text.trim(),
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      active: _active,
    );

    await viewModel.saveProduct.execute(entity);

    if (mounted && viewModel.saveProduct.completed) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.productSaved)),
      );
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.isEditing ? l10n.editProduct : l10n.newProduct,
        ),
        centerTitle: true,
      ),
      body: viewModel.isEditing ? _buildEditBody(l10n) : _buildForm(l10n),
    );
  }

  Widget _buildEditBody(AppLocalizations l10n) => CommandBuilder<ProductEntity>(
    command: viewModel.loadProduct,
    loadingBuilder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
    errorBuilder: (_) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const Gap.y(16),
          Text(l10n.errorLoadingProducts),
          const Gap.y(24),
          FilledButton.icon(
            onPressed: () => viewModel.loadProduct.execute(
              widget.productId!,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
          ),
        ],
      ),
    ),
    completedBuilder: (state) {
      // Populate form once when data arrives.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_nameController.text.isEmpty) {
          _populateFields(state.data);
        }
      });
      return _buildForm(l10n);
    },
  );

  Widget _buildForm(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                prefixIcon: const Icon(Icons.label_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.nameRequired;
                }
                return null;
              },
            ),
            const Gap.y(16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              maxLines: 3,
            ),
            const Gap.y(16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: l10n.price,
                prefixIcon: const Icon(Icons.attach_money_rounded),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.priceRequired;
                }
                if (double.tryParse(value.trim()) == null) {
                  return l10n.priceInvalid;
                }
                return null;
              },
            ),
            const Gap.y(16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: l10n.quantity,
                prefixIcon: const Icon(Icons.inventory_rounded),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value != null &&
                    value.trim().isNotEmpty &&
                    int.tryParse(value.trim()) == null) {
                  return l10n.quantityInvalid;
                }
                return null;
              },
            ),
            const Gap.y(16),
            SwitchListTile(
              title: Text(l10n.active),
              subtitle: Text(_active ? l10n.active : l10n.inactive),
              value: _active,
              onChanged: (value) => setState(() => _active = value),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const Gap.y(32),
            CommandBuilder<ProductEntity>(
              command: viewModel.saveProduct,
              loadingBuilder: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
              builder: (_) => FilledButton.icon(
                onPressed: _onSave,
                icon: const Icon(Icons.save_rounded),
                label: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
