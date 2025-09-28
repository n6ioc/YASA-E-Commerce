import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../widgets/product_card.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});
  @override State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final _search = TextEditingController();
  @override void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProductController>();
    if (ctrl.loading && ctrl.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.error != null && ctrl.products.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Could not load products'),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => context.read<ProductController>().refreshFromNetwork(),
            child: const Text('Retry'),
          ),
        ]),
      );
    }

    final products = ctrl.products;
    final cats = ctrl.categories;
    final selectedIndex = ctrl.category == null ? 0 : cats.indexOf(ctrl.category!);
    final initialTab = selectedIndex >= 0 ? selectedIndex : 0;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: TextField(
          controller: _search,
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: ctrl.query.isNotEmpty
                ? IconButton(
                    onPressed: () { _search.clear(); context.read<ProductController>().setQuery(''); },
                    icon: const Icon(Icons.clear),
                  )
                : null,
          ),
          onChanged: (v) => context.read<ProductController>().setQuery(v),
        ),
      ),
      DefaultTabController(
        length: cats.length,
        initialIndex: initialTab,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      isScrollable: true,
                      tabs: cats.map((c) => Tab(text: c)).toList(),
                      onTap: (i) => context.read<ProductController>().setCategory(cats[i]),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => context.read<ProductController>().refreshFromNetwork(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (!ctrl.loading && products.isEmpty)
        const Padding(padding: EdgeInsets.only(top: 48), child: Text('No products match your filters')),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () => context.read<ProductController>().refreshFromNetwork(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              // Responsive column count: more columns on wider screens
              int cols = 2;
              if (w >= 1400) {
                cols = 5;
              } else if (w >= 1100) cols = 4; else if (w >= 800) cols = 3;
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length + (ctrl.hasMore ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i >= products.length) {
                    return Center(
                      child: ctrl.loadingMore
                          ? const CircularProgressIndicator()
                          : OutlinedButton(
                              onPressed: () => context.read<ProductController>().loadMore(),
                              child: const Text('Load more'),
                            ),
                    );
                  }
                  final p = products[i];
                  return ProductCard(
                    product: p,
                    onTap: () => context.go('/product/${p.id}'),
                    onDoubleTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('♥'))),
                    onLongPress: () {
                      context.read<CartController>().add(p);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    ]);
  }
}
