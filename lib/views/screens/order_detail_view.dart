import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/orders_controller.dart';

class OrderDetailView extends StatefulWidget {
  final int orderId;
  const OrderDetailView({super.key, required this.orderId});
  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersController>().loadOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final oc = context.watch<OrdersController>();
    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId}')),
      body: oc.loading
          ? const Center(child: CircularProgressIndicator())
          : oc.error != null
              ? Center(child: Text('Error: ${oc.error}'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemCount: oc.items.length,
                  itemBuilder: (context, index) {
                    final it = oc.items[index];
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(it.image)),
                      title: Text(it.title),
                      subtitle: Text('x${it.qty}'),
                      trailing: Text('\$${(it.price * it.qty).toStringAsFixed(2)}'),
                    );
                  },
                ),
    );
  }
}
