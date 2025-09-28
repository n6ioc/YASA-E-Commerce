import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/cart_controller.dart';
import 'product_list_view.dart';
import 'cart_view.dart';
import 'settings_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final pc = context.watch<ProfileController>();
    final cart = context.watch<CartController>();
    final cartCount = cart.items.length;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('YASA Ecommerce'),
            if (auth.isSignedIn)
              Text(
                (pc.profile?.name.isNotEmpty == true)
                    ? 'Signed in as ${pc.profile!.name}'
                    : (auth.user?.email?.isNotEmpty ?? false)
                        ? 'Signed in as ${auth.user!.email}'
                        : 'Signed in',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Checkout',
            onPressed: () => context.go('/checkout'),
            icon: const Icon(Icons.payments),
          ),
          PopupMenuButton<String>(
            icon: Icon(auth.isSignedIn ? Icons.person : Icons.person_outline),
            onSelected: (v) {
              if (v == 'signin') context.go('/signin');
              if (v == 'signout') auth.signOut();
              if (v == 'orders') context.go('/orders');
            },
            itemBuilder: (c) => [
              if (!auth.isSignedIn) const PopupMenuItem(value: 'signin', child: Text('Sign In')),
              if (auth.isSignedIn) const PopupMenuItem(value: 'orders', child: Text('Orders')),
              if (auth.isSignedIn) PopupMenuItem(value: 'signout', child: Text('Sign Out (${auth.user?.email ?? 'Guest'})')),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: const [ProductListView(), CartView(), SettingsView()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.storefront), label: 'Shop'),
          NavigationDestination(
            icon: cartCount > 0
                ? Badge(label: Text('$cartCount'), child: const Icon(Icons.shopping_cart))
                : const Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          const NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
