import 'dart:convert';
import 'package:http/http.dart' as http;

class ExpenseService {
  final String baseUrl = "http://172.18.5.69:5000/api";

  Future<void> addExpense({
    required String description,
    required double amount,
    required String paidBy,
    required List splitBetween,
    required String token,
    required String groupId,
    bool isSettlement = false,
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
        "splitBetween": splitBetween,
        "groupId": groupId,
        "isSettlement": isSettlement,
      }),
    );

    print("Expense Response: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add expense");
    }
  }

  Future<List<dynamic>> getExpenses(String groupId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/expenses/$groupId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Expenses Fetch Response: ${response.body}");

    if (response.body.startsWith("<!DOCTYPE html>")) {
      throw Exception("❌ Wrong expense API route");
    }

    final data = jsonDecode(response.body);

    return data["expenses"];
  }

  Future<void> settleExpense(String expenseId, String token) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/expenses/settle/$expenseId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("Settle Response: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to settle expense");
    }
  }
}
