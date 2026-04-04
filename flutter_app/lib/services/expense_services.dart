import 'dart:convert';
import 'package:http/http.dart' as http;

class ExpenseService {
  final String baseUrl = "http://172.18.5.69:5000/api";

  Future<void> addExpense({
    required String description,
    required double amount,
    required String paidBy,
    required List members,
    required String token,
    required String groupId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/expenses/add"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "description": description,
        "amount": amount,
        "paidBy": paidBy,
        "members": members,
        "groupId": groupId,
      }),
    );

    print("Expense Response: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add expense");
    }
  }
}
