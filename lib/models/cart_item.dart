import 'product.dart';
class CartItem {
  final Product product;
  final int quantity;
  const CartItem({required this.product, required this.quantity});
  CartItem copyWith({Product? product, int? quantity}) =>
      CartItem(product: product ?? this.product, quantity: quantity ?? this.quantity);
  Map<String, dynamic> toJson() => {'product': product.toJson(), 'quantity': quantity};
  factory CartItem.fromJson(Map<String, dynamic> j) =>
      CartItem(product: Product.fromJson(j['product']), quantity: j['quantity'] as int? ?? 1);
  double get lineTotal => product.price * quantity;
}