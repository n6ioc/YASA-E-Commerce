import 'package:flutter/material.dart';
import '../../models/cart_item.dart';

class CartTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQtyChanged;
  const CartTile({super.key, required this.item, required this.onQtyChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(radius: 24, backgroundImage: NetworkImage(item.product.image)),
      title: Text(item.product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('\$${item.product.price.toStringAsFixed(2)}'),
      trailing: _QtyStepper(value: item.quantity, onChanged: onQtyChanged),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _QtyStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(onPressed: () => onChanged((value - 1).clamp(1, 99)), icon: const Icon(Icons.remove)),
      Text('$value'),
      IconButton(onPressed: () => onChanged((value + 1).clamp(1, 99)), icon: const Icon(Icons.add)),
    ]);
  }
}