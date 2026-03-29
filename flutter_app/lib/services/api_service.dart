import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //static const baseUrl = "http://10.0.2.2:5000/api";
  static const baseUrl = "http://172.18.5.69:5000/api";

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
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

    return jsonDecode(response.body);
  }
}
