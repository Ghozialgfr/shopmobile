import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiService {
  /// Emulator Android: http://10.0.2.2:8082
  /// HP asli: http://IP_LAPTOP:8082
  /// Chrome/Windows: http://localhost:8082
  static const String host = 'http://192.168.1.62:8082';
  static const String _base = '$host/products';

  static const _headers = {'Content-Type': 'application/json'};
  static const _timeout = Duration(seconds: 15);

  static Map<String, dynamic> _body(Product p) => {
    'title': p.title,
    'description': p.description,
    'category': p.category,
    'price': p.price,
    'stock': p.stock,
    'brand': p.brand,
    'thumbnail': p.thumbnail,
    'images': p.images,
  };

  static Product _parseProduct(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    final json = data['product'] is Map<String, dynamic>
        ? data['product'] as Map<String, dynamic>
        : data;
    return Product.fromJson(json);
  }

  static void _check(http.Response res, String action) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Gagal $action (${res.statusCode}): ${res.body}');
    }
  }

  /// READ semua produk (limit=0 -> semua).
  static Future<List<Product>> fetchProducts() async {
    final res = await http.get(Uri.parse('$_base?limit=0')).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat produk (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    return (data['products'] as List).map((e) => Product.fromJson(e)).toList();
  }

  static Future<List<Product>> searchProducts(String query) async {
    final res = await http
        .get(
          Uri.parse(
            '$_base/search?q=${Uri.encodeQueryComponent(query)}&limit=0',
          ),
        )
        .timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Gagal mencari produk (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    return (data['products'] as List).map((e) => Product.fromJson(e)).toList();
  }

  /// CREATE: POST /products/add
  static Future<Product> createProduct(Product p) async {
    final res = await http
        .post(
          Uri.parse('$_base/add'),
          headers: _headers,
          body: jsonEncode(_body(p)),
        )
        .timeout(_timeout);
    _check(res, 'menambah produk');
    return _parseProduct(res.body);
  }

  /// UPDATE: PATCH /products/{id}
  static Future<Product> updateProduct(Product p) async {
    final res = await http
        .patch(
          Uri.parse('$_base/${p.id}'),
          headers: _headers,
          body: jsonEncode(_body(p)),
        )
        .timeout(_timeout);
    _check(res, 'mengubah produk');
    return _parseProduct(res.body);
  }

  /// DELETE: DELETE /products/{id}
  static Future<void> deleteProduct(int id) async {
    final res = await http.delete(Uri.parse('$_base/$id')).timeout(_timeout);
    _check(res, 'menghapus produk');
  }
}
