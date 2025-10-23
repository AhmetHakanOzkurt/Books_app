import 'package:hive/hive.dart';

part 'book_model.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<String>? authors;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final DateTime? publishedDate;

  Book({
    required this.id,
    required this.title,
    this.authors,
    this.imageUrl,
    this.description,
    this.publishedDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Kitabın geçerli bir resmi olup olmadığını kontrol eden yardımcı method
  bool get hasValidImage {
    if (imageUrl == null || imageUrl!.isEmpty) return false;

    final lowerUrl = imageUrl!.toLowerCase();

    // Kapsamlı placeholder resim tespiti
    final invalidPatterns = [
      'no-image',
      'placeholder',
      'default_cover',
      'book_cover',
      'nocover',
      'no-cover',
      'notavailable',
      'unavailable',
      'image_not_available',
      'no_cover',
      'default',
      'blank',
      'missing',
      'error',
      'broken',
      'invalid',
      'null',
      'undefined',
      'empty',
      'none',
      'na',
      'n/a',
      'noimage',
      'no_image',
      'no_thumbnail',
      'no_thumb',
      'thumbnail_not_available',
      'cover_not_available',
      'book_not_available',
      'image_placeholder',
      'cover_placeholder',
      'book_placeholder',
    ];

    // Geçersiz patternleri kontrol et
    if (invalidPatterns.any((pattern) => lowerUrl.contains(pattern))) {
      return false;
    }

    // URL'nin geçerli bir resim URL'si olup olmadığını kontrol et
    if (!lowerUrl.contains('.jpg') &&
        !lowerUrl.contains('.jpeg') &&
        !lowerUrl.contains('.png') &&
        !lowerUrl.contains('.gif') &&
        !lowerUrl.contains('.webp') &&
        !lowerUrl.contains('googleusercontent.com') &&
        !lowerUrl.contains('books.google.com')) {
      return false;
    }

    return true;
  }

  // Başlık temizleme fonksiyonu
  static String cleanTitle(String? title) {
    if (title == null || title.isEmpty) return 'Başlıksız Kitap';

    // Önce temel temizlik
    title = title.trim().replaceAll(RegExp(r'\s+'), ' ');

    // Sistem mesajlarını ve geçersiz içerikleri filtrele
    final invalidPatterns = [
      'ekran',
      'alıntı',
      'görüntüsü',
      'panoya',
      'kopyalandı',
      'screenshot',
      'copy',
      'paste',
      'ekran alıntısı aracı',
      'ekran görüntüsü',
    ];

    final lowerTitle = title.toLowerCase();
    if (invalidPatterns.any((pattern) => lowerTitle.contains(pattern))) {
      return 'Geçersiz Kitap Başlığı';
    }

    // Özel durumlar için düzeltmeler
    title = title
        .replaceAll('EKREM HAKKI', 'Ekrem Hakkı')
        .replaceAll('AYVERDİ', 'Ayverdi')
        .replaceAll('HÂTIRA', 'Hâtıra')
        .replaceAll('KİTABI', 'Kitabı')
        .replaceAll('KENDİKLER', 'Kendikler');

    // Her kelimenin ilk harfini büyük yap (özel isimler hariç)
    List<String> words = title.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        // Özel kelimeleri kontrol et
        if (words[i] == 'VE' ||
            words[i] == 'VEYA' ||
            words[i] == 'İLE' ||
            words[i] == 'DE' ||
            words[i] == 'DA') {
          words[i] = words[i].toLowerCase();
        } else {
          words[i] =
              words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
        }
      }
    }

    return words.join(' ');
  }

  // Yazar temizleme fonksiyonu
  static List<String>? cleanAuthors(List<dynamic>? authors) {
    if (authors == null) return null;

    return authors.map((author) {
      String cleanedAuthor = author.toString().trim();

      // Yazar adlarını düzelt
      cleanedAuthor = cleanedAuthor
          .replaceAll('S. Kemal Sandıkçı', 'S. Kemal Sandıkçı')
          .replaceAll('Bilge Ercılasun', 'Bilge Ercilasun')
          .replaceAll('Selçuk Çıkla', 'Selçuk Çıkla')
          .replaceAll('Feriha Büyükünel', 'Feriha Büyükünel')
          .replaceAll('Bilal Eryılmaz', 'Bilal Eryılmaz');

      // Yazar adı formatını düzelt
      List<String> nameParts = cleanedAuthor.split(' ');
      if (nameParts.length > 1) {
        // İsim ve soyisim formatını düzelt
        String firstName = nameParts[0];
        String lastName = nameParts.length > 1
            ? nameParts[nameParts.length - 1]
            : '';

        // Ara kısımları kontrol et (orta isimler vs.)
        if (nameParts.length > 2) {
          for (int i = 1; i < nameParts.length - 1; i++) {
            if (nameParts[i].length > 1) {
              firstName += " ${nameParts[i]}";
            } else {
              // Kısaltmaları büyük harfle tut
              firstName += " ${nameParts[i].toUpperCase()}.";
            }
          }
        }

        cleanedAuthor = "$firstName $lastName";
      }

      return cleanedAuthor;
    }).toList();
  }

  // Açıklama temizleme fonksiyonu
  static String cleanDescription(String? description) {
    if (description == null || description.isEmpty) return 'Açıklama yok';

    // Açıklamadaki özel karakterleri ve HTML tag'larını temizle
    description = description
        .replaceAll(RegExp(r'<[^>]*>'), '') // HTML tag'larını kaldır
        .replaceAll(
          RegExp(r'\[.*?\]'),
          '',
        ) // Köşeli parantez içindekileri kaldır
        .replaceAll(RegExp(r'\s+'), ' ') // Çoklu boşlukları temizle
        .trim();

    // İlk 150 karakteri al ve noktalı şekilde kes
    if (description.length > 150) {
      description = '${description.substring(0, 150)}...';
    }

    return description;
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    // Resim URL'sini düzeltme fonksiyonu
    String? fixThumbnailUrl(String? url) {
      if (url == null || url.isEmpty) return null;

      // Daha kapsamlı URL düzeltme
      String fixedUrl = url
          .replaceAll('http://', 'https://')
          .replaceAll('&edge=curl', '')
          .replaceAll('&zoom=1', '')
          .replaceAll('&source=gbs_api', '')
          .replaceAll('&printsec=frontcover', '')
          .replaceAll('img=1&zoom=1', '')
          .replaceAll('&w=256', '')
          .replaceAll('&h=256', '')
          .replaceAll('&pid=1.7', '')
          .replaceAll('&fit=crop', '');

      // Kapsamlı placeholder resim tespiti - bu kitaplar hiç gösterilmesin
      final invalidPatterns = [
        'no-image',
        'placeholder',
        'default_cover',
        'book_cover',
        'nocover',
        'no-cover',
        'notavailable',
        'unavailable',
        'image_not_available',
        'no_cover',
        'default',
        'blank',
        'missing',
        'error',
        'broken',
        'invalid',
        'null',
        'undefined',
        'empty',
        'none',
        'na',
        'n/a',
        'noimage',
        'no_image',
        'no_thumbnail',
        'no_thumb',
        'thumbnail_not_available',
        'cover_not_available',
        'book_not_available',
        'image_placeholder',
        'cover_placeholder',
        'book_placeholder',
      ];

      // URL'yi küçük harfe çevir ve kontrol et
      final lowerUrl = fixedUrl.toLowerCase();

      // Geçersiz patternleri kontrol et
      if (invalidPatterns.any((pattern) => lowerUrl.contains(pattern))) {
        return null;
      }

      // URL'nin geçerli bir resim URL'si olup olmadığını kontrol et
      if (!lowerUrl.contains('.jpg') &&
          !lowerUrl.contains('.jpeg') &&
          !lowerUrl.contains('.png') &&
          !lowerUrl.contains('.gif') &&
          !lowerUrl.contains('.webp') &&
          !lowerUrl.contains('googleusercontent.com') &&
          !lowerUrl.contains('books.google.com')) {
        return null;
      }

      return fixedUrl;
    }

    // Tarihi işleme
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      if (dateStr.length == 4) return DateTime(int.parse(dateStr));
      return DateTime.tryParse(dateStr);
    }

    // Yazarları işleme
    List<String>? parsedAuthors;
    if (json['volumeInfo']['authors'] != null) {
      parsedAuthors = cleanAuthors(json['volumeInfo']['authors'] as List);
    }

    return Book(
      id: json['id'] as String,
      title: cleanTitle(json['volumeInfo']['title'] as String?),
      authors: parsedAuthors,
      imageUrl: fixThumbnailUrl(
        json['volumeInfo']['imageLinks']?['thumbnail'] as String?,
      ),
      description: cleanDescription(
        json['volumeInfo']['description'] as String?,
      ),
      publishedDate: parseDate(json['volumeInfo']['publishedDate'] as String?),
    );
  }
}
