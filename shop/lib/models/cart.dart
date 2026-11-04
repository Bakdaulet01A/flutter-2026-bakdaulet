import 'package:flutter/foundation.dart';

import 'book.dart';

class Cart extends ChangeNotifier {
  final Map<Book, int> _qty = {};

  List<Book> get items => _qty.keys.toList();

  int get count => _qty.length;

  int get total =>
      _qty.entries.fold(0, (sum, entry) => sum + entry.key.price * entry.value);

  int qtyOf(Book book) => _qty[book] ?? 0;

  bool add(Book book) {
    if (_qty.containsKey(book)) {
      return false;
    }

    _qty[book] = 1;
    notifyListeners();
    return true;
  }

  void increment(Book book) {
    final current = _qty[book];

    if (current == null) {
      return;
    }

    _qty[book] = current + 1;
    notifyListeners();
  }

  void remove(Book book) {
    _qty.remove(book);
    notifyListeners();
  }

  void clear() {
    _qty.clear();
    notifyListeners();
  }
}
