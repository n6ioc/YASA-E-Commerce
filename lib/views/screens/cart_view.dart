import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../widgets/cart_tile.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final items = cart.items;
    if (items.isEmpty) {
      return const Center(child: Text('Your cart is empty'));
    }
    return Column(children: [
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final it = items[i];
            return Dismissible(
              key: ValueKey(it.product.id),
              background: Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.delete)),
              secondaryBackground: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete)),
              onDismissed: (_) => context.read<CartController>().remove(it.product.id),
              child: CartTile(item: it, onQtyChanged: (q) => context.read<CartController>().updateQty(it.product.id, q)),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(children: [
          Expanded(child: Text('Total: \$${cart.subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium)),
          FilledButton.icon(
            onPressed: () => context.go('/checkout'),
            icon: const Icon(Icons.lock),
            label: const Text('Checkout'),
          ),
        ]),
      ),
    ]);
  }
}