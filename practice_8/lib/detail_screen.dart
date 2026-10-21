import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(title: const Text('Title'), subtitle: Text(book.title)),
            ListTile(title: const Text('Author'), subtitle: Text(book.author)),
            ListTile(
              title: const Text('Pages'),
              subtitle: Text('${book.pages}'),
            ),
            ListTile(
              title: const Text('Year'),
              subtitle: Text(
                book.year == null ? 'Year unknown' : '${book.year}',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(BookAction.toggleRead);
              },
              child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                final delete = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: Text("Delete '${book.title}'?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );

                if (delete == true && context.mounted) {
                  Navigator.of(context).pop(BookAction.delete);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
