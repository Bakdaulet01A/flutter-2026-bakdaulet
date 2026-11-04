import 'package:flutter/material.dart';

import 'cart_badge.dart';
import 'main.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({
    super.key,
    required this.cart,
    required this.total,
    required this.onAdd,
  });

  final List<Book> cart;
  final int total;
  final void Function(Book) onAdd;

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [
          CartBadge(
            count: cart.length,
            total: total,
          ),
        ],
      ),
      body: ListView(
        children: [
          for (final book in books)
            Builder(
              builder: (context) {
                debugPrint('row ${book.title}');

                final added = cart.contains(book);

                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  trailing: added
                      ? const Text('Added')
                      : OutlinedButton(
                    onPressed: () {
                      onAdd(book);
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