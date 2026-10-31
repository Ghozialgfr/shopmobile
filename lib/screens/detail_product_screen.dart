import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class DetailProductScreen extends StatefulWidget {
  const DetailProductScreen({super.key, required this.id});

  final int id;

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  late Future<Product> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchProduct();
  }

  Future<Product> _fetchProduct() async {
    final res = await http.get(
      Uri.parse('https://dummyjson.com/products/${widget.id}'),
    );
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat produk (${res.statusCode})');
    }
    return Product.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.blue)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() => _future = _fetchProduct()),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        return _buildDetail(context, snapshot.data!);
      },
    );
  }

  Widget _buildDetail(BuildContext context, Product product) {
    final images = product.images.isNotEmpty
        ? product.images
        : [product.thumbnail];
    final price = product.price.toDouble();
    final discount = product.discountPercentage.toDouble();
    final finalPrice = price * (1 - discount / 100);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 280,
            child: Hero(
              tag: 'product-${product.id}',
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, i) => Image.network(
                  images[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Center(child: Icon(Icons.broken_image, size: 64)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(product.brand, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Chip(label: Text(product.category)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${finalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (discount > 0) ...[
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '-${discount.toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(product.rating.toDouble().toStringAsFixed(1)),
                    const SizedBox(width: 16),
                    Text('Stok: ${product.stock.toInt()}'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(product.description),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: product.tags
                      .map((t) => Chip(label: Text(t)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ulasan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...product.reviews.map(
                  (r) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(r.reviewerName),
                    subtitle: Text(r.comment),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        Text('${r.rating.toInt()}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
