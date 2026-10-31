import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Produk DummyJSON')),
      body: Column(
        children: [
          // 1. Kolom search (X = reset semua filter)
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari produk (contoh: phone)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    prov.fetchProducts();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (v) =>
                  v.trim().isEmpty ? prov.fetchProducts() : prov.search(v),
            ),
          ),

          // 2. Dropdown kategori + sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Kategori'),
                    value: prov.selectedCategory.isEmpty
                        ? null
                        : prov.selectedCategory,
                    items: prov.categoryList
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        _searchCtrl.clear();
                        prov.filterByCategory(v);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: prov.sortKey,
                    items: const [
                      DropdownMenuItem(
                        value: 'default',
                        child: Text('Urutan default'),
                      ),
                      DropdownMenuItem(
                        value: 'price_asc',
                        child: Text('Harga termurah'),
                      ),
                      DropdownMenuItem(
                        value: 'price_desc',
                        child: Text('Harga termahal'),
                      ),
                      DropdownMenuItem(
                        value: 'title_asc',
                        child: Text('Judul A-Z'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        _searchCtrl.clear();
                        prov.setSort(v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. Mode select (tugas: limit/skip/select)
          SwitchListTile(
            dense: true,
            title: const Text('Mode ringkas (select=title,price,...)'),
            value: prov.compact,
            onChanged: (v) => prov.setCompact(v),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total di server: ${prov.total} | Tampil: ${prov.products.length}',
              ),
            ),
          ),

          // 4. Daftar produk
          Expanded(child: _buildBody(prov)),

          // 5. Pagination
          if (prov.isPaged)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: prov.hasPrev ? prov.prevPage : null,
                    child: const Text('Sebelumnya'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Halaman ${prov.page}'),
                  ),
                  OutlinedButton(
                    onPressed: prov.hasNext ? prov.nextPage : null,
                    child: const Text('Berikutnya'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(ProductProvider prov) {
    if (prov.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(prov.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: prov.fetchProducts,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (prov.products.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan'));
    }
    return ListView.builder(
      itemCount: prov.products.length,
      itemBuilder: (context, i) {
        final p = prov.products[i];
        return ListTile(
          leading: CachedNetworkImage(
            imageUrl: p.thumbnail,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            placeholder: (_, _) => const SizedBox(
              width: 56,
              height: 56,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, _, _) => const Icon(Icons.image_not_supported),
          ),
          title: Text(p.title),
          subtitle: Text(
            p.brand.isEmpty ? p.category : '${p.brand} • ${p.category}',
          ),
          trailing: Text('\$${p.price.toStringAsFixed(2)}'),
          onTap: () => context.push('/detail/${p.id}'),
        );
      },
    );
  }
}
