import 'package:dio/dio.dart';

import '../models/product_model.dart';

class ApiServiceProducts {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Tugas 1, 4, 5: GET /products?limit=..&skip=..&select=..&sortBy=..&order=..
  Future<ProductsResponse> getProducts({
    int limit = 30,
    int skip = 0,
    String? sortBy,
    String order = 'asc',
    String? select,
  }) async {
    final params = <String, dynamic>{'limit': limit, 'skip': skip};
    if (sortBy != null) {
      params['sortBy'] = sortBy;
      params['order'] = order;
    }
    if (select != null) params['select'] = select;

    final res = await _dio.get('/products', queryParameters: params);
    return ProductsResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // Tugas 2: GET /products/1
  Future<Product> getProduct(int id) async {
    final res = await _dio.get('/products/$id');
    return Product.fromJson(res.data as Map<String, dynamic>);
  }

  // Tugas 3: GET /products/search?q=phone
  Future<ProductsResponse> searchProducts(String query) async {
    final res = await _dio.get(
      '/products/search',
      queryParameters: {'q': query},
    );
    return ProductsResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // Tugas 6: GET /products/categories  (berisi objek slug, name, url)
  Future<List<Category>> getCategories() async {
    final res = await _dio.get('/products/categories');
    return (res.data as List).map((e) => Category.fromJson(e)).toList();
  }

  // Tugas 7: GET /products/category-list  (array string)
  Future<List<String>> getCategoryList() async {
    final res = await _dio.get('/products/category-list');
    return (res.data as List).map((e) => e.toString()).toList();
  }

  // Tugas 8: GET /products/category/smartphones
  Future<ProductsResponse> getProductsByCategory(String category) async {
    final res = await _dio.get('/products/category/$category');
    return ProductsResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
