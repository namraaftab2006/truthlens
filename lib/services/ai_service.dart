import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {

  static const String baseUrl = "https://fake-newss.onrender.com";


  static Future<String> getApiInfo() async {
    try {
      final Uri url = Uri.parse("$baseUrl/");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? "Welcome to the Fake News Detection API";
      } else {
        return "⚠️ API info error: ${response.statusCode}";
      }
    } catch (e) {
      print("API Info error: $e");
      return "❌ Unable to connect to API info endpoint.";
    }
  }


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

        // Flask returns "prediction" and "confidence"
        final prediction = data['prediction'] ?? "No prediction";
        final confidence = data['confidence'] ?? "N/A";

        return "📰 Result: $prediction (Confidence: $confidence)";
      } else {
        return "⚠️ Prediction error: ${response.statusCode}";
      }
    } catch (e) {
      print("Prediction error: $e");
      return "❌ Unable to connect to prediction service.";
    }
  }


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


        return data['response'] ??
            data['reply'] ??
            "🤖 No reply from chatbot.";
      } else {
        return "⚠️ Chatbot error: ${response.statusCode}";
      }
    } catch (e) {
      print("Chatbot error: $e");
      return "❌ Unable to connect to chatbot service.";
    }
  }
}
