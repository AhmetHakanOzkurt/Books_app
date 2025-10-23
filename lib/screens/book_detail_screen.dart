import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book_model.dart';
import '../services/favorite_service.dart';
import '../utils/image_helper.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final favoriteService = FavoriteService();

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Book>('favorites').listenable(),
        builder: (context, Box<Book> box, child) {
          final isFavorite = box.containsKey(book.id);
          return CustomScrollView(
            slivers: [
              // SliverAppBar'da kapak resmi
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ImageHelper.bookImage(
                    book.imageUrl,
                    book: book, // Book nesnesini de gönder
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),

                      if (book.authors != null && book.authors!.isNotEmpty)
                        Text(
                          'Yazar: ${book.authors!.join(", ")}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                      const SizedBox(height: 16),

                      // Açıklama için sabit yükseklik ve kaydırma
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            book.description ?? "Açıklama bulunamadı.",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Küçük kapak
                      Center(
                        child: ImageHelper.bookImage(
                          book.imageUrl,
                          width: 150,
                          height: 225,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Favori butonu
                      Center(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                          label: Text(
                            isFavorite
                                ? "Favorilerden Çıkar"
                                : "Favorilere Ekle",
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () async {
                            await favoriteService.toggleFavorite(book);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
