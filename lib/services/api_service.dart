import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import '../utils/constants.dart';

class ApiService {
  Future<List<NewsArticle>> fetchNews({
    String category = 'forYou',
    String query = '',
  }) async {
    try {
      String url = '${Constants.baseUrl}?apikey=${Constants.apiKey}&language=en';

      if (query.isNotEmpty) {
        url += '&q=$query';
      } else if (category != 'forYou' && category != 'top') {
        url += '&category=$category';
      } else {
        url += '&category=top';
      }

      print('📡 Fetching news from URL: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<dynamic> articles = [];
        if (data['results'] != null && data['results'] is List) {
          articles = data['results'];
        } else if (data['articles'] != null && data['articles'] is List) {
          articles = data['articles'];
        }

        if (category == 'junior') {
          articles = articles.where((a) {
            final desc = (a['description'] ?? '').toString().toLowerCase();
            final title = (a['title'] ?? '').toString().toLowerCase();

            final bannedWords = [
              'murder',
              'crime',
              'violence',
              'suicide',
              'war',
              'bomb',
              'rape',
              'terror',
              'kill',
              'attack',
              'gun',
              'drugs',
            ];

            return !bannedWords.any((word) =>
            desc.contains(word) || title.contains(word));
          }).toList();

          articles = articles.where((a) {
            final title = (a['title'] ?? '').toString().toLowerCase();
            final desc = (a['description'] ?? '').toString().toLowerCase();
            return title.contains('science') ||
                title.contains('space') ||
                title.contains('technology') ||
                title.contains('education') ||
                title.contains('student') ||
                title.contains('discovery') ||
                title.contains('nature') ||
                title.contains('sports') ||
                title.contains('game') ||
                title.contains('health') ||
                desc.contains('learn') ||
                desc.contains('discover') ||
                desc.contains('fun') ||
                desc.contains('kids');
          }).toList();

          articles = articles.map((a) {
            String desc = a['description']?.toString() ?? '';
            desc = desc
                .replaceAll(
                RegExp(r'\b(complex|controversial|political)\b',
                    caseSensitive: false),
                'simple')
                .replaceAll(
                RegExp(r'\b(according to reports|sources say)\b',
                    caseSensitive: false),
                'it is said')
                .replaceAll(
                RegExp(r'\b(officials)\b', caseSensitive: false), 'people')
                .replaceAll(
                RegExp(r'\b(government)\b', caseSensitive: false),
                'leaders')
                .replaceAll(RegExp(r'\b(situation)\b', caseSensitive: false),
                'event')
                .replaceAll(RegExp(r'\b(difficult|critical)\b',
                caseSensitive: false), 'hard');

            a['description'] = desc;
            return a;
          }).toList();

          if (articles.length < 10) {
            final extraCategories = ['science', 'sports', 'education', 'health'];
            for (String cat in extraCategories) {
              final extraUrl =
                  '${Constants.baseUrl}?apikey=${Constants.apiKey}&language=en&category=$cat';
              print('🔄 Fetching extra safe articles from: $extraUrl');
              final extraResponse = await http.get(Uri.parse(extraUrl));

              if (extraResponse.statusCode == 200) {
                final Map<String, dynamic> extraData =
                json.decode(extraResponse.body);
                if (extraData['results'] != null &&
                    extraData['results'] is List) {
                  final List<dynamic> extra = extraData['results'];
                  articles.addAll(extra.where((a) {
                    final title = (a['title'] ?? '').toString().toLowerCase();
                    return !title.contains('crime') &&
                        !title.contains('war') &&
                        !title.contains('bomb') &&
                        !title.contains('attack');
                  }));
                }
              }

              if (articles.length >= 15) break;
            }
          }

          articles = articles.take(15).toList();
        }

        return articles
            .where((e) => e is Map<String, dynamic>)
            .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching news: $e');
      rethrow;
    }
  }
}
