import 'dart:convert';
import 'package:http/http.dart' as http;

class BalanceService {
  final String baseUrl = "http://172.18.5.69:5000/api/groups";

  Future<List<dynamic>> getBalances(String groupId, String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$groupId/balance"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["transactions"];
    } else {
      throw Exception("Failed to load balances");
    }
  }
}
