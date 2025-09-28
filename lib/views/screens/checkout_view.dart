import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../services/firebase_service.dart';
import '../../controllers/orders_controller.dart';
import '../../models/order_models.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});
  @override State<CheckoutView> createState() => _CheckoutState();
}

class _CheckoutState extends State<CheckoutView> {
  bool _processing = false;
  String? _result;
  String _payment = 'cash';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final auth = context.watch<AuthController>();
    final signedIn = auth.isSignedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _processing
            ? const Center(child: CircularProgressIndicator())
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Items: ${cart.items.length}'),
                const SizedBox(height: 8),
                Text('Total: \$${cart.subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                Text('Payment Method', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: 'cash',
                        groupValue: _payment,
                        title: const Text('Cash on Delivery'),
                        subtitle: const Text('Pay with cash when you receive your order'),
                        onChanged: (v) => setState(() => _payment = v!),
                      ),
                      const Divider(height: 0),
                      RadioListTile<String>(
                        value: 'card',
                        groupValue: _payment,
                        title: const Text('Card (Mock Payment)'),
                        subtitle: const Text('Simulated card payment for demo'),
                        onChanged: (v) => setState(() => _payment = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!signedIn)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.lock_outline),
                      title: Text('Sign in required'),
                      subtitle: Text('Sign in or continue as guest to place order'),
                      trailing: SizedBox.shrink(), // button in AppBar menu
                    ),
                  ),
                if (_result != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_result!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: (!signedIn || cart.items.isEmpty) ? null : () => _onCheckout(context),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Place Order'),
                ),
              ]),
      ),
    );
  }

  Future<void> _onCheckout(BuildContext context) async {
    setState(() => _processing = true);
    try {
      final api = context.read<ApiService>();
      final cart = context.read<CartController>();
      final fb = context.read<FirebaseService>();
      final auth = context.read<AuthController>();
      final orders = context.read<OrdersController>();

      if (_payment == 'card') {
        await Future.delayed(const Duration(milliseconds: 600));
      }
      await fb.logEvent('checkout', {'items': cart.items.length});

      final List<OrderItemModel> orderItems = cart.items.map((ci) => OrderItemModel(
            orderId: 0,
            productId: ci.product.id,
            title: ci.product.title,
            price: ci.product.price,
            qty: ci.quantity,
            image: ci.product.image,
          )).toList();
      final orderId = await orders.placeOrder(
        uid: auth.user!.uid,
        total: cart.subtotal,
        items: orderItems,
      );
      // fire and forget demo API call
      // ignore: discarded_futures
      api
          .createCart(userId: 1, date: DateTime.now(), items: cart.items)
          .catchError((_) => <String, dynamic>{});

      await cart.clear();
      setState(() => _result = 'Order saved (id: $orderId) • Payment: ${_payment == 'cash' ? 'Cash' : 'Card'}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_payment == 'cash' ? 'Order placed for Cash on Delivery' : 'Payment successful, order placed')),
        );
      }
    } catch (e) {
      setState(() => _result = e.toString());
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }
}