import 'package:go_router/go_router.dart';

import '../views/screens/home_screen.dart';
import '../views/screens/product_detail_view.dart';
import '../views/screens/cart_view.dart';
import '../views/screens/settings_view.dart';
import '../views/screens/checkout_view.dart';
import '../views/auth/sign_in_view.dart';
import '../views/screens/orders_view.dart';
import '../views/screens/order_detail_view.dart';

GoRouter createRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'product/:id',
          builder: (c, st) => ProductDetailView(
            productId: int.parse(st.pathParameters['id']!),
          ),
        ),
        GoRoute(path: 'cart', builder: (_, __) => const CartView()),
        GoRoute(path: 'settings', builder: (_, __) => const SettingsView()),
        GoRoute(path: 'checkout', builder: (_, __) => const CheckoutView()),
        GoRoute(path: 'orders', builder: (_, __) => const OrdersView()),
        GoRoute(
          path: 'orders/:id',
          builder: (c, st) => OrderDetailView(orderId: int.parse(st.pathParameters['id']!)),
        ),
        GoRoute(path: 'signin', builder: (_, __) => const SignInView()),
      ],
    ),
  ],
);