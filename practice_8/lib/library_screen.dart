import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];

  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((book) => book.read).toList(),
  };

  Future<void> _openDetail(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute(builder: (_) => DetailScreen(book: book)),
    );

    if (!mounted) return;

    switch (action) {
      case BookAction.toggleRead:
        setState(() {
          book.read = !book.read;
        });
        break;

      case BookAction.delete:
        setState(() {
          _books.remove(book);
        });
        break;

      case null:
        break;
    }
  }

  Future<void> _addBook() async {
    final book = await Navigator.of(context)
        .push<Book>(MaterialPageRoute(builder: (_) => const AddBookScreen()));

    if (book == null || !mounted) return;

    setState(() {
      _books.add(book);
    });
  }

  Widget _stat(String value, String label) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Text(value, style: textTheme.headlineSmall),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${_visible.length})')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _stat('${_books.length}', 'Books'),
                  _stat('${totalPages(_books)}', 'Pages'),
                  _stat('${unread(_books).length}', 'Unread'),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == Filter.all,
                onSelected: (_) {
                  setState(() {
                    _filter = Filter.all;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Unread'),
                selected: _filter == Filter.unread,
                onSelected: (_) {
                  setState(() {
                    _filter = Filter.unread;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Read'),
                selected: _filter == Filter.read,
                onSelected: (_) {
                  setState(() {
                    _filter = Filter.read;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _visible.length,
              itemBuilder: (context, index) {
                final book = _visible[index];

                return GestureDetector(
                  onTap: () {
                    _openDetail(book);
                  },
                  child: BookTile(
                    book: book,
                    onToggle: () {
                      setState(() {
                        book.read = !book.read;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        child: const Icon(Icons.add),
      ),
    );
  }
}
