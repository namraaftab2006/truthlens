import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  // Set your API URL here once available
  static const String apiUrl = "https://your-ml-api.com/chat";

  /// Sends user message to ML API and returns response as String
  static Future<String> sendMessage(String message) async {
    try {
      // Example POST request structure; adapt to your API spec
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? "No reply from API";
      } else {
        return "AI service unavailable (HTTP ${response.statusCode})";
      }
    } catch (e) {
      return "AI service unavailable"; // failsafe
    }
  }
}
