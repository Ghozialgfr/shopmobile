double _d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

class Dimensions {
  final double width, height, depth;
  const Dimensions({this.width = 0, this.height = 0, this.depth = 0});
  factory Dimensions.fromJson(Map<String, dynamic> j) => Dimensions(
    width: _d(j['width']),
    height: _d(j['height']),
    depth: _d(j['depth']),
  );
}

class Review {
  final int rating;
  final String comment, reviewerName;
  const Review({this.rating = 0, this.comment = '', this.reviewerName = ''});
  factory Review.fromJson(Map<String, dynamic> j) => Review(
    rating: j['rating'] ?? 0,
    comment: j['comment'] ?? '',
    reviewerName: j['reviewerName'] ?? '',
  );
}

class Meta {
  final String createdAt, updatedAt, barcode, qrCode;
  const Meta({
    this.createdAt = '',
    this.updatedAt = '',
    this.barcode = '',
    this.qrCode = '',
  });
  factory Meta.fromJson(Map<String, dynamic> j) => Meta(
    createdAt: j['createdAt'] ?? '',
    updatedAt: j['updatedAt'] ?? '',
    barcode: j['barcode'] ?? '',
    qrCode: j['qrCode'] ?? '',
  );
}

class Category {
  final String slug, name, url;
  const Category({this.slug = '', this.name = '', this.url = ''});
  factory Category.fromJson(Map<String, dynamic> j) => Category(
    slug: j['slug'] ?? '',
    name: j['name'] ?? '',
    url: j['url'] ?? '',
  );
}

class Product {
  final int id;
  final String title, description, category, brand, sku;
  final double price, discountPercentage, rating, weight;
  final int stock, minimumOrderQuantity;
  final List<String> tags, images;
  final Dimensions dimensions;
  final String warrantyInformation, shippingInformation, availabilityStatus;
  final String returnPolicy, thumbnail;
  final List<Review> reviews;
  final Meta meta;

  const Product({
    required this.id,
    this.title = '',
    this.description = '',
    this.category = '',
    this.price = 0,
    this.discountPercentage = 0,
    this.rating = 0,
    this.stock = 0,
    this.tags = const [],
    this.brand = '',
    this.sku = '',
    this.weight = 0,
    this.dimensions = const Dimensions(),
    this.warrantyInformation = '',
    this.shippingInformation = '',
    this.availabilityStatus = '',
    this.reviews = const [],
    this.returnPolicy = '',
    this.minimumOrderQuantity = 1,
    this.meta = const Meta(),
    this.thumbnail = '',
    this.images = const [],
  });

  // Dipakai saat select=title,price: field yang tidak dikirim server
  // otomatis jadi nilai default (karena ada "?? ''" dan "?? 0")
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    price: _d(json['price']),
    discountPercentage: _d(json['discountPercentage']),
    rating: _d(json['rating']),
    stock: json['stock'] ?? 0,
    tags: List<String>.from(json['tags'] ?? []),
    brand: json['brand'] ?? '',
    sku: json['sku'] ?? '',
    weight: _d(json['weight']),
    dimensions: Dimensions.fromJson(json['dimensions'] ?? {}),
    warrantyInformation: json['warrantyInformation'] ?? '',
    shippingInformation: json['shippingInformation'] ?? '',
    availabilityStatus: json['availabilityStatus'] ?? '',
    reviews: (json['reviews'] as List? ?? [])
        .map((e) => Review.fromJson(e))
        .toList(),
    returnPolicy: json['returnPolicy'] ?? '',
    minimumOrderQuantity: json['minimumOrderQuantity'] ?? 1,
    meta: Meta.fromJson(json['meta'] ?? {}),
    thumbnail: json['thumbnail'] ?? '',
    images: List<String>.from(json['images'] ?? []),
  );
}

class ProductsResponse {
  final List<Product> products;
  final int total, skip, limit;
  const ProductsResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['products'] as List? ?? [];
    return ProductsResponse(
      products: list.map((e) => Product.fromJson(e)).toList(),
      total: json['total'] ?? list.length,
      skip: json['skip'] ?? 0,
      limit: json['limit'] ?? 30,
    );
  }
}
