import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class BookItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;

  const BookItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Resim bölümü - DEĞİŞTİRİLDİ: Arkaplan rengi eklendi
          Container(
            height: 180,
            color: Colors.grey[200],
            child: ImageHelper.bookImage(
              imageUrl,
              fit: BoxFit.contain, // Resmi oranlı şekilde sığdır
            ),
          ),

          // Kitap bilgileri
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
