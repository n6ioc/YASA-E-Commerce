import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/cart_item.dart';

class ApiService {
  static const _base = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts() async {
    try {
      final res = await http.get(Uri.parse('$_base/products?limit=30'));
      if (res.statusCode != 200) throw Exception('Failed to fetch products');
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Product.fromJson(e)).toList();
    } catch (_) {
      // Offline/CORS-safe fallback dataset (minimal set)
      return _fallbackProducts();
    }
  }

  Future<Product> fetchProduct(int id) async {
    try {
      final res = await http.get(Uri.parse('$_base/products/$id'));
      if (res.statusCode != 200) throw Exception('Product not found');
      return Product.fromJson(jsonDecode(res.body));
    } catch (_) {
      // Offline/CORS-safe fallback dataset (single product)
      return _fallbackProduct(id);
    }
  }

  Future<Map<String, dynamic>> createCart({
    required int userId,
    required DateTime date,
    required List<CartItem> items,
  }) async {
    final body = {
      'userId': userId,
      'date': date.toIso8601String().substring(0, 10),
      'products': items.map((e) => {'productId': e.product.id, 'quantity': e.quantity}).toList(),
    };
    final res = await http.post(
      Uri.parse('$_base/carts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode >= 400) {
      throw Exception('Checkout failed (${res.statusCode})');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  List<Product> _fallbackProducts() => <Product>[
        Product(
          id: 1,
          title: 'Classic Tee',
          price: 19.99,
          description: 'Soft cotton classic t-shirt',
          category: 'clothing',
          image: 'https://picsum.photos/seed/shirt/400/400',
          rating: const ProductRating(rate: 4.5, count: 120),
        ),
        Product(
          id: 2,
          title: 'Wireless Headphones',
          price: 59.99,
          description: 'Over-ear Bluetooth headphones',
          category: 'electronics',
          image: 'https://picsum.photos/seed/headphones/400/400',
          rating: const ProductRating(rate: 4.2, count: 86),
        ),
        Product(
          id: 3,
          title: 'Sport Sneakers',
          price: 74.99,
          description: 'Breathable running shoes',
          category: 'footwear',
          image: 'https://picsum.photos/seed/shoes/400/400',
          rating: const ProductRating(rate: 4.7, count: 203),
        ),
      ];

  Product _fallbackProduct(int id) {
    switch (id) {
      case 1:
        return Product(
          id: 1,
          title: 'Classic Tee',
          price: 19.99,
          description: 'Soft cotton classic t-shirt',
          category: 'clothing',
          image: 'https://picsum.photos/seed/shirt/400/400',
          rating: const ProductRating(rate: 4.5, count: 120),
        );
      case 2:
        return Product(
          id: 2,
          title: 'Wireless Headphones',
          price: 59.99,
          description: 'Over-ear Bluetooth headphones',
          category: 'electronics',
          image: 'https://picsum.photos/seed/headphones/400/400',
          rating: const ProductRating(rate: 4.2, count: 86),
        );
      case 3:
        return Product(
          id: 3,
          title: 'Sport Sneakers',
          price: 74.99,
          description: 'Breathable running shoes',
          category: 'footwear',
          image: 'https://picsum.photos/seed/shoes/400/400',
          rating: const ProductRating(rate: 4.7, count: 203),
        );
      default:
        return Product(
          id: id,
          title: 'Unknown Product',
          price: 0.0,
          description: 'Unknown product',
          category: 'unknown',
          image: 'https://picsum.photos/seed/unknown/400/400',
          rating: const ProductRating(rate: 0.0, count: 0),
        );
    }
  }
}