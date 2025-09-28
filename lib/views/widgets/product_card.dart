import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../controllers/cart_controller.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const ProductCard({super.key, required this.product, this.onTap, this.onDoubleTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priceStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    return InkWell(
      onTap: onTap, onDoubleTap: onDoubleTap, onLongPress: onLongPress,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: Hero(
              tag: 'p-${product.id}',
              child: Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: Image.network(product.image, fit: BoxFit.contain),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Icon(Icons.star, size: 16, color: Colors.amber.shade600),
              const SizedBox(width: 4),
              Text(product.rating.rate.toStringAsFixed(1)),
              const SizedBox(width: 8),
              Text('(${product.rating.count})', style: theme.textTheme.bodySmall),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 8, 12),
            child: Row(children: [
              Text('\$${product.price.toStringAsFixed(2)}', style: priceStyle),
              const Spacer(),
              Tooltip(
                message: 'Add to cart',
                child: IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () => context.read<CartController>().add(product),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}