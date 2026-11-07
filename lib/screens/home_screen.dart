import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<Product> _products = [];
  String _selectedCategory = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await ApiService.fetchProducts();
      if (!mounted) return;
      setState(() => _products = products);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  Future<void> _addProduct() async {
    final product = await showDialog<Product>(
      context: context,
      builder: (_) => const ProductFormDialog(),
    );
    if (product == null || !mounted) return;

    try {
      final created = await ApiService.createProduct(product);
      if (!mounted) return;
      setState(() {
        _products = [created, ..._products];
        _selectedCategory = created.category.trim();
      });
      _showMessage('Produk berhasil ditambahkan');
    } catch (e) {
      _showMessage('$e');
    }
  }

  Future<void> _editProduct(Product product) async {
    final edited = await showDialog<Product>(
      context: context,
      builder: (_) => ProductFormDialog(product: product),
    );
    if (edited == null || !mounted) return;

    try {
      final updated = await ApiService.updateProduct(edited);
      if (!mounted) return;
      setState(() {
        _products = _products
            .map((item) => item.id == product.id ? updated : item)
            .toList();
        _clearMissingCategory();
      });
      _showMessage('Produk berhasil diperbarui');
    } catch (e) {
      _showMessage('$e');
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('Produk "${product.title}" akan dihapus dari daftar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ApiService.deleteProduct(product.id);
      if (!mounted) return;
      setState(() {
        _products.removeWhere((item) => item.id == product.id);
        _clearMissingCategory();
      });
      _showMessage('Produk berhasil dihapus');
    } catch (e) {
      _showMessage('$e');
    }
  }

  void _clearMissingCategory() {
    if (_selectedCategory.isNotEmpty &&
        !_products.any((product) => product.category == _selectedCategory)) {
      _selectedCategory = '';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final categories =
        _products
            .map((product) => product.category.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final visibleProducts = _products.where((product) {
      final matchesCategory =
          _selectedCategory.isEmpty || product.category == _selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          product.title.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        icon: const Icon(Icons.add),
        label: const Text('Produk Baru'),
        tooltip: 'Tambah produk baru',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.pinkLight, AppColors.pinkMedium],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Halo, Selamat datang Ghozi 👋',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Temukan Produk Favoritmu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: _onChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: const TextStyle(color: AppColors.textSoft),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.pink,
                      ),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.textSoft,
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                            ),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _categoryChip('', 'Semua'),
                        ...categories.map(
                          (category) =>
                              _categoryChip(category, _categoryLabel(category)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildProductList(visibleProducts)),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String category, String label) {
    final selected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _selectedCategory = category),
        backgroundColor: Colors.white.withValues(alpha: 0.62),
        selectedColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: TextStyle(
          color: selected ? AppColors.pink : AppColors.text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _categoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'beauty':
        return 'Kecantikan';
      case 'skin-care':
        return 'Perawatan Kulit';
      default:
        return category
            .split('-')
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
    }
  }

  Widget _buildProductList(List<Product> products) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.pink),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.pinkMedium),
            const SizedBox(height: 8),
            const Text(
              'Gagal memuat data',
              style: TextStyle(color: AppColors.text),
            ),
            TextButton(
              onPressed: _loadProducts,
              child: const Text(
                'Coba lagi',
                style: TextStyle(color: AppColors.pink),
              ),
            ),
          ],
        ),
      );
    }
    if (products.isEmpty) {
      return const Center(
        child: Text(
          'Produk tidak ditemukan 🌸',
          style: TextStyle(color: AppColors.textSoft),
        ),
      );
    }

    final isWide = MediaQuery.of(context).size.width >= 900;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isWide ? 0.95 : 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(product: product)),
          ),
          onEdit: () => _editProduct(product),
          onDelete: () => _deleteProduct(product),
        );
      },
    );
  }
}

Product productWithId(Product product, int id) => Product(
  id: id,
  title: product.title,
  description: product.description,
  category: product.category,
  price: product.price,
  discountPercentage: product.discountPercentage,
  rating: product.rating,
  stock: product.stock,
  brand: product.brand,
  thumbnail: product.thumbnail,
  images: product.images,
);
