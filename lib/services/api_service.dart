import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/book_model.dart';

class ApiService {
  static final String _apiKey = dotenv.env['API_KEY']!;
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      validateStatus: (status) => status! < 500,
    ),
  );

  Future<List<Book>> getPopularBooks({int startIndex = 0}) async {
    try {
      final response = await _dio.get(
        'volumes',
        queryParameters: {
          'q': 'subject:fiction',
          'key': _apiKey,
          'maxResults': 40,
          'startIndex': startIndex,
          'orderBy': 'relevance',
          'printType': 'books',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['items'] == null) return [];

        // Sadece geçerli resmi olan kitapları al
        return (data['items'] as List)
            .map((e) => Book.fromJson(e))
            .where((book) => book.hasValidImage) // Resim filtresi
            .toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Ağ hatası: ${e.message}');
    } catch (e) {
      throw Exception('Bilinmeyen hata: $e');
    }
  }

  Future<Map<String, dynamic>> searchBooks(
    String query, {
    int startIndex = 0,
  }) async {
    try {
      final response = await _dio.get(
        'volumes',
        queryParameters: {
          'q': query,
          'key': _apiKey,
          'maxResults': 40,
          'startIndex': startIndex,
          'orderBy': 'relevance',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio Error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown Error: $e');
    }
  }

  final Map<String, String> _categoryMapping = {
    'Tümü': 'fiction',
    'Roman': 'fiction',
    'Tarih': 'history',
    'Biyografi': 'biography',
    'Çocuk': 'children',
    'Gençlik': 'young+adult',
    'Şiir': 'poetry',
    'Felsefe': 'philosophy',
    'Psikoloji': 'psychology',
    'Bilim': 'science',
    'Teknoloji': 'technology',
    'Sağlık': 'health',
    'Yemek': 'cooking',
    'Seyahat': 'travel',
    'Sanat': 'art',
    'Müzik': 'music',
    'Spor': 'sports',
    'Kişisel Gelişim': 'self+help',
    'İş Dünyası': 'business',
    'Ekonomi': 'economics',
    'Hukuk': 'law',
    'Eğitim': 'education',
    'Din': 'religion',
    'Mitoloji': 'mythology',
  };

  Future<List<Book>> getBooksByCategory(
    String category, {
    int startIndex = 0,
  }) async {
    try {
      if (category == 'Tümü') {
        return await getPopularBooks(startIndex: startIndex);
      }

      final englishCategory =
          _categoryMapping[category] ?? category.toLowerCase();

      final response = await _dio.get(
        'volumes',
        queryParameters: {
          'q': 'subject:$englishCategory',
          'key': _apiKey,
          'maxResults': 40,
          'startIndex': startIndex,
          'orderBy': 'relevance',
          'printType': 'books',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['items'] == null) return [];

        // Sadece geçerli resmi olan kitapları al
        return (data['items'] as List)
            .map((e) => Book.fromJson(e))
            .where((book) => book.hasValidImage) // Resim filtresi
            .toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Ağ hatası: ${e.message}');
    } catch (e) {
      throw Exception('Bilinmeyen hata: $e');
    }
  }
}
