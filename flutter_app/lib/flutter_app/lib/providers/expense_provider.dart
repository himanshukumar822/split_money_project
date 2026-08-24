import 'package:flutter/material.dart';
import 'package:split_money/services/expense_services.dart';

class ExpenseProvider with ChangeNotifier {
  List expenses = [];

  Future<void> fetchExpenses(String groupId, String token) async {
    final data = await ExpenseService().getExpenses(groupId, token);
    expenses = data;
    notifyListeners();
  }
}
