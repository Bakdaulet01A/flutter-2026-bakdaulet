import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');

    return Scaffold(
      appBar: AppBar(title: const Text('Books'), actions: const [CartBadge()]),
      body: ListView(
        children: [
          for (final book in books)
            Builder(
              builder: (context) {
                debugPrint('row ${book.title}');

                final added = context.watch<Cart>().items.contains(book);

                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  trailing: added
                      ? const Text('Added')
                      : OutlinedButton(
                          onPressed: () {
                            final ok = context.read<Cart>().add(book);

                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added')),
                              );
                            }
                          },
                          child: const Text('Add'),
                        ),
                );
              },
            ),
        ],
      ),
    );
  }
}
