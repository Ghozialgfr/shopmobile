import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _imgIndex = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = p.images.isNotEmpty ? p.images : [p.thumbnail];
    final discounted = p.price * (1 - p.discountPercentage / 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ===== Gambar =====
          Stack(
            children: [
              Container(
                height: 320,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.pinkLight,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(36)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 16),
                    child: Hero(
                      tag: 'product-${p.id}',
                      child: Image.network(
                        images[_imgIndex],
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                            Icons.image_not_supported,
                            color: AppColors.pink,
                            size: 60),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: AppColors.pink),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ===== Thumbnail =====
          if (images.length > 1)
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: images.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => _imgIndex = i),
                  child: Container(
                    width: 48,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: i == _imgIndex
                            ? AppColors.pink
                            : AppColors.pinkLight,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(images[i], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          // ===== Info =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.pinkLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(p.category,
                        style: const TextStyle(
                            color: AppColors.pink,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
                  const SizedBox(height: 10),
                  Text(p.title,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.pinkMedium, size: 20),
                      Text(' ${p.rating.toStringAsFixed(1)}',
                          style: const TextStyle(color: AppColors.textSoft)),
                      const SizedBox(width: 14),
                      Text('Brand: ${p.brand}',
                          style: const TextStyle(color: AppColors.textSoft)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${discounted.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pink)),
                      const SizedBox(width: 10),
                      if (p.discountPercentage > 0)
                        Text('\$${p.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textSoft)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Deskripsi',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.text)),
                  const SizedBox(height: 6),
                  Text(p.description,
                      style: const TextStyle(
                          height: 1.5, color: AppColors.textSoft)),
                  const SizedBox(height: 14),
                  Text('Stok tersedia: ${p.stock}',
                      style: const TextStyle(color: AppColors.text)),
                ],
              ),
            ),
          ),
          // ===== Tombol =====
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Tambah ke Keranjang'),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.pinkMedium,
                      content: Text('${p.title} ditambahkan 🌸'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
