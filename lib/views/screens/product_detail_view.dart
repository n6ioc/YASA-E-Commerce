import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';

class ProductDetailView extends StatelessWidget {
  final int productId;
  const ProductDetailView({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final p = context.read<ProductController>().byId(productId);
    return FutureBuilder<Product>(
      future: p != null ? Future.value(p) : context.read<ProductController>().api.fetchProduct(productId),
      builder: (c, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final product = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Hero(
                  tag: 'p-${product.id}',
                  child: Card(
                    child: Padding(padding: const EdgeInsets.all(16), child: Image.network(product.image, fit: BoxFit.contain)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(product.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.star, size: 18), const SizedBox(width: 4), Text('${product.rating.rate} (${product.rating.count})')]),
              const SizedBox(height: 16),
              Text(product.description),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.read<CartController>().add(product);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add to Cart'),
          ),
        );
      },
    );
  }
}