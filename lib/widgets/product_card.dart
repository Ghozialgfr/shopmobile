import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.pinkMedium.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.pinkLight,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: Image.network(
                          product.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.pink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (product.discountPercentage > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: PopupMenuButton<String>(
                        tooltip: 'Aksi produk',
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (action) {
                          if (action == 'edit') onEdit();
                          if (action == 'delete') onDelete();
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_outline),
                              title: Text('Hapus'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.pinkMedium,
                          ),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSoft,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
