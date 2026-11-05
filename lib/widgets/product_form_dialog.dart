import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _brandController;
  late final TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _titleController = TextEditingController(text: product?.title ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _categoryController = TextEditingController(text: product?.category ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _stockController = TextEditingController(
      text: product == null ? '0' : product.stock.toString(),
    );
    _brandController = TextEditingController(text: product?.brand ?? '');
    _imageController = TextEditingController(text: product?.thumbnail ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final oldProduct = widget.product;
    final thumbnail = _imageController.text.trim();
    Navigator.pop(
      context,
      Product(
        id: oldProduct?.id ?? 0,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        discountPercentage: oldProduct?.discountPercentage ?? 0,
        rating: oldProduct?.rating ?? 0,
        stock: int.parse(_stockController.text.trim()),
        brand: _brandController.text.trim().isEmpty
            ? '-'
            : _brandController.text.trim(),
        thumbnail: thumbnail,
        images: thumbnail.isEmpty ? [] : [thumbnail],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit produk' : 'Tambah produk'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_titleController, 'Nama produk', required: true),
                _field(_categoryController, 'Kategori', required: true),
                _field(
                  _priceController,
                  'Harga',
                  required: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (value) {
                    final price = double.tryParse(value?.trim() ?? '');
                    if (price == null || price < 0) {
                      return 'Masukkan harga yang valid';
                    }
                    return null;
                  },
                ),
                _field(
                  _stockController,
                  'Stok',
                  required: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (int.tryParse(value?.trim() ?? '') == null) {
                      return 'Masukkan jumlah stok yang valid';
                    }
                    return null;
                  },
                ),
                _field(_brandController, 'Merek'),
                _field(_imageController, 'URL gambar'),
                _field(_descriptionController, 'Deskripsi', maxLines: 3),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator:
            validator ??
            (required
                ? (value) => value == null || value.trim().isEmpty
                      ? '$label wajib diisi'
                      : null
                : null),
      ),
    );
  }
}
