import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ppb_produk_bawaan/models/product.dart';
import 'package:ppb_produk_bawaan/widgets/product_form_dialog.dart';

void main() {
  testWidgets('form validates and creates a product', (tester) async {
    Product? createdProduct;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                createdProduct = await showDialog<Product>(
                  context: context,
                  builder: (_) => const ProductFormDialog(),
                );
              },
              child: const Text('Open form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();
    expect(find.text('Nama produk wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Produk Uji');
    await tester.enterText(find.byType(TextFormField).at(1), 'kategori-uji');
    await tester.enterText(find.byType(TextFormField).at(2), '12500.5');
    await tester.enterText(find.byType(TextFormField).at(3), '8');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(createdProduct?.title, 'Produk Uji');
    expect(createdProduct?.category, 'kategori-uji');
    expect(createdProduct?.price, 12500.5);
    expect(createdProduct?.stock, 8);
  });
}
