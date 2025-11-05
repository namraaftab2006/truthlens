import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/api_service.dart';

class NewsController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<NewsArticle> newsList = [];
  bool isLoading = false;
  String currentCategory = 'forYou';
  String currentQuery = '';

  Future<void> fetchNews({
    String category = 'forYou',
    String query = '',
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      currentCategory = category;
      currentQuery = query;

      // ✅ Use valid categories for API calls
      final apiCategory = category == 'junior' ? 'education' : category;

      final articles = await _apiService.fetchNews(
        category: apiCategory,
        query: query,
      );

      // ✅ Teen-friendly filter & simplification
      if (category == 'junior') {
        final teenSafeKeywords = [
          'education',
          'science',
          'sports',
          'technology',
          'environment',
          'innovation',
          'space',
          'students',
        ];

        // 🧩 Keep only teen-relevant or positive topics
        newsList = articles
            .where((a) {
          final title = a.title.toLowerCase();
          final desc = (a.description ?? '').toLowerCase();
          return teenSafeKeywords.any((word) =>
          title.contains(word) || desc.contains(word));
        })
            .map((article) {
          return NewsArticle(
            title: _simplifyText(article.title),
            description: _simplifyText(article.description),
            imageUrl: article.imageUrl,
            link: article.link,
            category: article.category,
            source: article.source,
            pubDate: article.pubDate,
            content: _simplifyText(article.content ?? ''),
          );
        })
            .toList();

        // 🩵 If no matches found, fall back to simplified top news
        if (newsList.isEmpty) {
          final fallbackArticles =
          await _apiService.fetchNews(category: 'top');
          newsList = fallbackArticles.map((article) {
            return NewsArticle(
              title: _simplifyText(article.title),
              description: _simplifyText(article.description),
              imageUrl: article.imageUrl,
              link: article.link,
              category: article.category,
              source: article.source,
              pubDate: article.pubDate,
              content: _simplifyText(article.content ?? ''),
            );
          }).toList();
        }
      } else {
        newsList = articles;
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching news: $e');
      newsList = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTopHeadlines() async => fetchNews(category: 'top');

  void clearNews() {
    newsList = [];
    currentQuery = '';
    notifyListeners();
  }

  /// 🧠 Helper function to simplify complex words for Junior Mode
  String _simplifyText(String text) {
    return text
        .replaceAll(RegExp(r'\bapproximately\b', caseSensitive: false), 'about')
        .replaceAll(RegExp(r'\bindividuals\b', caseSensitive: false), 'people')
        .replaceAll(RegExp(r'\bchildren\b', caseSensitive: false), 'kids')
        .replaceAll(RegExp(r'\butilize\b', caseSensitive: false), 'use')
        .replaceAll(RegExp(r'\bhowever\b', caseSensitive: false), 'but')
        .replaceAll(RegExp(r'\btherefore\b', caseSensitive: false), 'so')
        .replaceAll(RegExp(r'\bcurrently\b', caseSensitive: false), 'now')
        .replaceAll(RegExp(r'\bapproximately\b', caseSensitive: false), 'around')
        .replaceAll(RegExp(r'\bencountered\b', caseSensitive: false), 'met')
        .replaceAll(RegExp(r'\bassist\b', caseSensitive: false), 'help')
        .replaceAll(RegExp(r'\bcommence\b', caseSensitive: false), 'start')
        .replaceAll(RegExp(r'\bterminate\b', caseSensitive: false), 'end');
  }
}
