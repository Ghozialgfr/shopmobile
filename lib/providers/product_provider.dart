import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/api_service_products.dart';

class ProductProvider extends ChangeNotifier {
  final ApiServiceProducts _api = ApiServiceProducts();

  static const int limit = 10; // produk per halaman

  List<Product> _products = [];
  List<String> _categoryList = [];
  bool _loading = false;
  String? _error;
  int _total = 0;
  int _skip = 0;
  String _selectedCategory = '';
  String _query = '';
  String _sortKey = 'default';
  bool _compact = false; // mode select=title,price,...

  // ---- getter (dibaca oleh UI) ----
  List<Product> get products => _products;
  List<String> get categoryList => _categoryList;
  bool get loading => _loading;
  String? get error => _error;
  int get total => _total;
  String get selectedCategory => _selectedCategory;
  String get sortKey => _sortKey;
  bool get compact => _compact;

  // pagination hanya aktif saat tidak sedang search / filter kategori
  bool get isPaged => _query.isEmpty && _selectedCategory.isEmpty;
  bool get hasNext => isPaged && _skip + limit < _total;
  bool get hasPrev => isPaged && _skip > 0;
  int get page => (_skip ~/ limit) + 1;

  // ---- satu fungsi pemuat data, memilih endpoint sesuai kondisi ----
  Future<void> _load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      ProductsResponse res;
      if (_query.isNotEmpty) {
        res = await _api.searchProducts(_query);
      } else if (_selectedCategory.isNotEmpty) {
        res = await _api.getProductsByCategory(_selectedCategory);
      } else {
        String? sortBy;
        String order = 'asc';
        switch (_sortKey) {
          case 'price_asc':
            sortBy = 'price';
            order = 'asc';
            break;
          case 'price_desc':
            sortBy = 'price';
            order = 'desc';
            break;
          case 'title_asc':
            sortBy = 'title';
            order = 'asc';
            break;
        }
        res = await _api.getProducts(
          limit: limit,
          skip: _skip,
          sortBy: sortBy,
          order: order,
          select: _compact ? 'title,price,thumbnail,brand' : null,
        );
      }
      _products = res.products;
      _total = res.total;
    } catch (e) {
      _error = 'Gagal memuat data. Periksa koneksi internet.\n$e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ---- aksi yang dipanggil dari UI ----
  Future<void> fetchProducts() {
    _skip = 0;
    _query = '';
    _selectedCategory = '';
    return _load();
  }

  Future<void> fetchCategories() async {
    try {
      _categoryList = await _api.getCategoryList();
      notifyListeners();
    } catch (_) {
      // kalau gagal, dropdown kategori kosong saja
    }
  }

  Future<void> search(String q) {
    _query = q.trim();
    _selectedCategory = '';
    _skip = 0;
    return _load();
  }

  Future<void> filterByCategory(String category) {
    if (category.isEmpty) return fetchProducts();
    _selectedCategory = category;
    _query = '';
    _skip = 0;
    return _load();
  }

  Future<void> setSort(String key) {
    _sortKey = key;
    _query = '';
    _selectedCategory = '';
    _skip = 0;
    return _load();
  }

  Future<void> setCompact(bool value) {
    _compact = value;
    return _load();
  }

  Future<void> nextPage() {
    if (!hasNext) return Future.value();
    _skip += limit;
    return _load();
  }

  Future<void> prevPage() {
    if (!hasPrev) return Future.value();
    _skip -= limit;
    return _load();
  }
}
