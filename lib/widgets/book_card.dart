import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book_model.dart';
import '../screens/book_detail_screen.dart';
import '../utils/image_helper.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool showFavorite;

  const BookCard({super.key, required this.book, this.showFavorite = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 340, maxHeight: 360),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kitap kapağı
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Hero(
                      tag: 'book-image-${book.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: ImageHelper.bookImage(
                          book.imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Kitap bilgileri
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Kitap başlığı
                          Flexible(
                            child: Text(
                              book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Yazar bilgisi
                          if (book.authors != null && book.authors!.isNotEmpty)
                            Flexible(
                              child: Text(
                                book.authors!.join(', '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                  fontSize: 12,
                                  height: 1.1,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Favori butonu
              if (showFavorite)
                Positioned(
                  top: 8,
                  right: 8,
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box<Book>('favorites').listenable(),
                    builder: (context, Box<Book> box, child) {
                      final isFavorite = box.containsKey(book.id);
                      return GestureDetector(
                        onTap: () {
                          if (isFavorite) {
                            box.delete(book.id);
                          } else {
                            box.put(book.id, book);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
