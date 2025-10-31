import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import '../utils/constants.dart';

class ApiService {
  Future<List<NewsArticle>> fetchNews({String category = 'forYou', String query = ''}) async {
    try {
      // Base URL setup
      String url = '${Constants.baseUrl}?apikey=${Constants.apiKey}&language=en';

      // Prioritize query → search results
      if (query.isNotEmpty) {
        url += '&q=$query';
      }
      // Otherwise category-based or top headlines
      else if (category != 'forYou' && category != 'top') {
        url += '&category=$category';
      } else {
        url += '&category=top';
      }

      print('Fetching news from URL: $url');

      final response = await http.get(Uri.parse(url));
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List articles = [];
        if (data['results'] != null) {
          articles = data['results'];
        } else if (data['articles'] != null) {
          articles = data['articles'];
        }

        // Junior mode filter (keep your old safe content logic)
        if (category == 'junior') {
          articles = articles.where((a) {
            final desc = (a['description'] ?? '').toString().toLowerCase();
            return !desc.contains('murder') &&
                !desc.contains('crime') &&
                !desc.contains('violence');
          }).toList();
        }

        return articles.map((e) => NewsArticle.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}
