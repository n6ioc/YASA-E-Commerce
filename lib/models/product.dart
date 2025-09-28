class ProductRating {
  final double rate;
  final int count;
  const ProductRating({required this.rate, required this.count});
  factory ProductRating.fromJson(Map<String, dynamic> j) =>
      ProductRating(rate: (j['rate'] as num?)?.toDouble() ?? 0, count: j['count'] as int? ?? 0);
}
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final ProductRating rating;
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });
  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'] as int,
    title: j['title'] as String? ?? '',
    price: (j['price'] as num?)?.toDouble() ?? 0,
    description: j['description'] as String? ?? '',
    category: j['category'] as String? ?? '',
    image: j['image'] as String? ?? '',
    rating: j['rating'] != null
        ? ProductRating.fromJson(j['rating'])
        : const ProductRating(rate: 0, count: 0),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'description': description,
    'category': category,
    'image': image,
    'rating': {'rate': rating.rate, 'count': rating.count},
  };
}