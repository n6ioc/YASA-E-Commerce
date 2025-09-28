import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/orders_controller.dart';
import '../../controllers/auth_controller.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});
  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  String? _loadedUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthController>();
    if (auth.isSignedIn && _loadedUid != auth.user!.uid) {
      _loadedUid = auth.user!.uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<OrdersController>().loadForUser(auth.user!.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final oc = context.watch<OrdersController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: !auth.isSignedIn
          ? const Center(child: Text('Sign in to view your orders'))
          : oc.loading
              ? const Center(child: CircularProgressIndicator())
              : oc.error != null
                  ? Center(child: Text('Error: ${oc.error}'))
                  : oc.orders.isEmpty
                      ? const Center(child: Text('No orders yet'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemCount: oc.orders.length,
                          itemBuilder: (context, index) {
                            final o = oc.orders[index];
                            return ListTile(
                              leading: const Icon(Icons.receipt_long),
                              title: Text('Order #${o.id} • ${o.status}'),
                              subtitle: Text('${o.itemCount} items • ${o.createdAt}'),
                              trailing: Text('\$${o.total.toStringAsFixed(2)}'),
                              onTap: () => context.go('/orders/${o.id}'),
                            );
                          },
                        ),
    );
  }
}
