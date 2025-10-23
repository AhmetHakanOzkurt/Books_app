import 'package:flutter/foundation.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';

class BookProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Book> _books = [];
  bool _isLoading = false;
  String _error = '';
  int _currentPage = 0;
  bool _hasMore = true;
  String _currentQuery = 'Tümü';

  // Kategori sayfalama için değişkenler
  int _categoryPage = 0;
  bool _categoryHasMore = true;
  String _currentCategory = 'Tümü';

  // Tümü (popüler) kategorisi için sayfalama
  int _popularPage = 0;
  bool _popularHasMore = true;

  Set<String> _bookIds = {};
  int _totalItems = 0;

  String _selectedCategory = 'Tümü';

  // Yeni değişkenler
  bool _isLoadingMore = false;
  bool _hasNextPage = true;

  // Getter'lar
  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasMore => _hasMore;
  String get currentQuery => _currentQuery;
  bool get categoryHasMore => _categoryHasMore;
  String get selectedCategory => _selectedCategory;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _hasNextPage;

  List<String> categories = [
    'Tümü',
    'Roman',
    'Tarih',
    'Biyografi',
    'Çocuk',
    'Gençlik',
    'Şiir',
    'Felsefe',
    'Psikoloji',
    'Bilim',
    'Teknoloji',
    'Sağlık',
    'Yemek',
    'Seyahat',
    'Sanat',
    'Müzik',
    'Spor',
    'Kişisel Gelişim',
    'İş Dünyası',
    'Ekonomi',
    'Hukuk',
    'Eğitim',
    'Din',
    'Mitoloji',
  ];

  /// Kategori seçildiğinde çağrılır
  void selectCategory(String category) {
    _selectedCategory = category;
    _currentCategory = category;
    _currentQuery = '';
    _categoryPage = 0;
    _categoryHasMore = true;
    _bookIds.clear();
    notifyListeners();

    if (category == 'Tümü') {
      fetchPopularBooks();
    } else {
      fetchBooksByCategory(category);
    }
  }

  /// Kategoriye göre kitapları getirir
  Future<void> fetchBooksByCategory(
    String category, {
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _books = [];
      _categoryPage = 0;
      _categoryHasMore = true;
      _hasNextPage = true;
      _bookIds.clear();
      notifyListeners();
    }

    if (!_categoryHasMore || _isLoading) return;

    _isLoading = true;
    if (loadMore) {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final books = await _apiService.getBooksByCategory(
        category,
        startIndex: _categoryPage * 40,
      );

      // TÜM kitapları al, filtreleme YOK
      final newBooks = books
          .where((book) => !_bookIds.contains(book.id))
          .toList();

      _bookIds.addAll(newBooks.map((book) => book.id));

      // Eğer hiç kitap gelmezse veya gelen kitap sayısı 40'dan azsa daha fazla sayfa olmadığını işaretle
      if (books.isEmpty || books.length < 40) {
        _categoryHasMore = false;
        _hasNextPage = false;
      }

      if (loadMore) {
        _books.addAll(newBooks);
      } else {
        _books = newBooks;
      }

      _categoryPage++;
      _error = '';
    } catch (e) {
      _error = 'Kitaplar yüklenirken hata oluştu: ${e.toString()}';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Tümü (popüler) kitapları getirir
  Future<void> fetchPopularBooks({bool loadMore = false}) async {
    if (!loadMore) {
      _books = [];
      _popularPage = 0;
      _popularHasMore = true;
      _hasNextPage = true;
      _bookIds.clear();
      notifyListeners();
    }

    if (!_popularHasMore || _isLoading) return;

    _isLoading = true;
    if (loadMore) {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final books = await _apiService.getPopularBooks(
        startIndex: _popularPage * 40,
      );

      // TÜM kitapları al, filtreleme YOK
      final newBooks = books
          .where((book) => !_bookIds.contains(book.id))
          .toList();

      _bookIds.addAll(newBooks.map((book) => book.id));

      // Eğer hiç kitap gelmezse veya gelen kitap sayısı 40'dan azsa daha fazla sayfa olmadığını işaretle
      if (books.isEmpty || books.length < 40) {
        _popularHasMore = false;
        _hasNextPage = false;
      }

      if (loadMore) {
        _books.addAll(newBooks);
      } else {
        _books = newBooks;
      }

      _popularPage++;
      _error = '';
    } catch (e) {
      _error = 'Kitaplar yüklenirken hata oluştu: ${e.toString()}';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Daha fazla kitap yükle
  void loadMoreBooks() {
    if (_selectedCategory != 'Tümü') {
      fetchBooksByCategory(_selectedCategory, loadMore: true);
    } else {
      fetchPopularBooks(loadMore: true);
    }
  }

  /// Kitap arama
  Future<void> searchBooks(String query, {bool reset = false}) async {
    if (reset) {
      _books = [];
      _currentPage = 0;
      _hasMore = true;
      _currentQuery = query;
      _totalItems = 0;
      _bookIds.clear();
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.searchBooks(
        query,
        startIndex: _currentPage * 40,
      );

      _totalItems = response['totalItems'] ?? 0;

      final newBooks = (response['items'] as List)
          .map((e) => Book.fromJson(e))
          .toList();

      // Sadece geçerli resmi olan ve yinelenmeyen kitapları al
      final newBooksWithImages = newBooks
          .where((book) => book.hasValidImage && !_bookIds.contains(book.id))
          .toList();

      _bookIds.addAll(newBooksWithImages.map((book) => book.id));

      if (newBooksWithImages.isEmpty ||
          (_books.length + newBooksWithImages.length) >= _totalItems) {
        _hasMore = false;
      }

      _books.addAll(newBooksWithImages);
      _currentPage++;
      _error = '';
    } catch (e) {
      if (e.toString().contains('400')) {
        _error = 'Arama geçersiz, lütfen farklı bir terim deneyin';
      } else if (e.toString().contains('socket')) {
        _error = 'İnternet bağlantınızı kontrol edin';
      } else {
        _error = 'Kitaplar yüklenirken hata oluştu: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resetleme
  void reset() {
    _books = [];
    _currentPage = 0;
    _hasMore = true;
    _error = '';
    _bookIds.clear();
    notifyListeners();
  }

  void clearResults() {
    _books = [];
    _currentPage = 0;
    _hasMore = true;
    _currentQuery = '';
    _isLoading = false;
    _error = '';
    _bookIds.clear();
    notifyListeners();
  }

  void resetToPopular() {
    clearResults();
    fetchPopularBooks();
  }
}
