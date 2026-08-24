import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = "https://split-money-backend.onrender.com/api";

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    // return jsonDecode(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/auth/signup"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": name,
            "email": email,
            "password": password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return jsonDecode(response.body);
  }
}
