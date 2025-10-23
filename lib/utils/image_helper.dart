import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/book_model.dart';

class ImageHelper {
  static Widget bookImage(
    String? url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Book? book, // Book nesnesini de alabilir
  }) {
    // Book nesnesi verilmişse ve geçerli bir resmi yoksa placeholder göster
    if (book != null && !book.hasValidImage) {
      return _buildPlaceholder(width: width, height: height);
    }

    if (url == null || url.isEmpty) {
      return _buildPlaceholder(width: width, height: height);
    }

    // URL'yi kontrol et ve gerekirse düzelt
    String finalUrl = _validateUrl(url);

    return CachedNetworkImage(
      imageUrl: finalUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholder: (context, url) =>
          _buildPlaceholder(width: width, height: height),
      errorWidget: (context, url, error) {
        print('Resim yükleme hatası: $url - $error');
        return _buildPlaceholder(width: width, height: height);
      },
      httpHeaders: const {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
      },
    );
  }

  static String _validateUrl(String url) {
    // Bazı sunucular user-agent ister
    if (url.startsWith('https://books.google.com')) {
      return url.contains('?')
          ? '$url&printsec=frontcover'
          : '$url?printsec=frontcover';
    }
    return url;
  }

  static Widget _buildPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Resim Yok',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
