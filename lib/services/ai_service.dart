import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  // ✅ Base URL of your Render ML API
  static const String baseUrl = "https://fake-newss.onrender.com";

  /// 💬 Sends a chat message to the chatbot endpoint
  static Future<String> sendMessage(String message) async {
    try {
      final Uri url = Uri.parse("$baseUrl/chatbot");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      print("Chatbot raw response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ??
            data['response'] ??
            data['answer'] ??
            "🤖 No reply from chatbot";
      } else {
        return "⚠️ Chatbot error: ${response.statusCode}";
      }
    } catch (e) {
      print("Chatbot error: $e");
      return "❌ Unable to connect to chatbot service.";
    }
  }

  /// 📰 Sends text to fake-news prediction endpoint
  static Future<String> predictNews(String text) async {
    try {
      final Uri url = Uri.parse("$baseUrl/predict");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      print("Predict raw response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Adjust if your API returns e.g. {"prediction": "Fake News"}
        return data['prediction'] ??
            data['result'] ??
            "📰 No prediction received";
      } else {
        return "⚠️ Prediction error: ${response.statusCode}";
      }
    } catch (e) {
      print("Prediction error: $e");
      return "❌ Unable to connect to prediction service.";
    }
  }
}
