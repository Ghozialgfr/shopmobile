import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String _base = 'https://dummyjson.com/products';

  /// Ambil seluruh produk (limit=0 -> semua produk).
  static Future<List<Product>> fetchProducts() async {
    final res = await http.get(Uri.parse('$_base?limit=0'));
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat produk (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    return (data['products'] as List).map((e) => Product.fromJson(e)).toList();
  }

  /// Cari produk lewat endpoint search DummyJSON.
  static Future<List<Product>> searchProducts(String query) async {
    final res = await http.get(
      Uri.parse('$_base/search?q=${Uri.encodeQueryComponent(query)}&limit=0'),
    );
    if (res.statusCode != 200) {
      throw Exception('Gagal mencari produk (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    return (data['products'] as List).map((e) => Product.fromJson(e)).toList();
  }
}
