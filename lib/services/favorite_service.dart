import 'package:hive/hive.dart';
import '../models/book_model.dart';

class FavoriteService {
  static const String _boxName = 'favorites';

  Future<void> toggleFavorite(Book book) async {
    final box = await _openBox();
    if (box.containsKey(book.id)) {
      await box.delete(book.id);
    } else {
      await box.put(book.id, book);
    }
  }

  Future<bool> isFavorite(Book book) async {
    final box = await _openBox();
    return box.containsKey(book.id);
  }

  Future<List<Book>> getFavorites() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<Box<Book>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Book>(_boxName);
    }
    return Hive.box<Book>(_boxName);
  }
}
