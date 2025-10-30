import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import '../utils/constants.dart';

class ApiService {
  Future<List<NewsArticle>> fetchNews({String category = 'forYou', String query = ''}) async {
    try {
      String url = '${Constants.baseUrl}?apikey=${Constants.apiKey}&language=en';

      if (query.isNotEmpty) {
        url += '&q=$query';
      } else if (category != 'forYou') {
        url += '&category=$category';
      }

      print('Fetching news from URL: $url'); // debug

      final response = await http.get(Uri.parse(url));
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Adjust for different APIs
        List articles = [];
        if (data['results'] != null) {
          articles = data['results'];
        } else if (data['articles'] != null) {
          articles = data['articles'];
        }

        // Junior Mode filtering (safe content)
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
