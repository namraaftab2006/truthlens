import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/api_service.dart';

class NewsController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<NewsArticle> newsList = [];
  bool isLoading = false;
  String currentCategory = 'forYou';

  /// Fetch news from API with optional category or search query
  Future<void> fetchNews({String category = 'forYou', String query = ''}) async {
    try {
      isLoading = true;
      notifyListeners();

      currentCategory = category;
      final articles = await _apiService.fetchNews(category: category, query: query);
      newsList = articles;
    } catch (e) {
      debugPrint('Error fetching news: $e');
      newsList = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
