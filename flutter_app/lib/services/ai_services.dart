import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String baseUrl = "https://split-money-backend.onrender.com/api";

  Future<String> sendMessage({
    required String userId,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/ai/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "message": message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["reply"] ?? "No reply received.";
    }

    throw Exception("AI request failed: ${response.body}");
  }
}
