import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _clearCart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear cart?'),
          content: const Text('All books will be removed from the cart.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            onPressed: () {
              _clearCart(context);
            },
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear cart',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) {
                return ListView(
                  children: [
                    for (final book in cart.items)
                      ListTile(
                        title: Text(book.title),
                        subtitle: Text('${book.author} • ${book.price} ₸'),
                        leading: Text('×${cart.qtyOf(book)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cart.increment(book);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                cart.remove(book);
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Consumer<Cart>(
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payments_outlined),
                SizedBox(width: 8),
                Text('Cart total'),
              ],
            ),
            builder: (context, cart, child) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    child!,
                    const SizedBox(width: 12),
                    Text(
                      '${cart.total} ₸',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
