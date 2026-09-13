import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String baseUrl =
      "https://split-money-backend.onrender.com/api/ai";

  Future<String> sendMessage({
    required String userId,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "message": message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["reply"] ?? "";
    }

    throw Exception("Failed to get AI response");
  }

  Future<List<Map<String, dynamic>>> getChatHistory({
    required String userId,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/history/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List chats = data["chats"] ?? [];

      return chats.map((chat) => Map<String, dynamic>.from(chat)).toList();
    }

    throw Exception("Failed to load AI history");
  }
}
