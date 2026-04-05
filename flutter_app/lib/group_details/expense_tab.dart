import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/expense_services.dart';
import '../providers/auth_provider.dart';

class ExpenseTab extends StatefulWidget {
  final String groupId;

  const ExpenseTab({super.key, required this.groupId});

  @override
  State<ExpenseTab> createState() => _ExpenseTabState();
}

class _ExpenseTabState extends State<ExpenseTab> {
  List expenses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final data = await ExpenseService().getExpenses(
        widget.groupId,
        auth.token,
      );

      setState(() {
        expenses = data; // ✅ already filtered from backend
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching expenses: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (expenses.isEmpty) {
      return const Center(child: Text("No expenses yet"));
    }

    return RefreshIndicator(
      onRefresh: fetchExpenses,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final e = expenses[index];

          final paidByName = e["paidBy"] ?? "Unknown";
          final isYouPaid = paidByName == "You";

          final date =
              DateTime.tryParse(e["createdAt"] ?? "") ?? DateTime.now();
          final formattedDate = DateFormat("dd MMM").format(date);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DATE
                Column(
                  children: [
                    Text(formattedDate, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Expense",
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                /// CARD
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.orange.withOpacity(0.2),
                        child: const Icon(Icons.receipt, color: Colors.orange),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e["description"] ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isYouPaid
                                  ? "You paid ₹${e["amount"]}"
                                  : "$paidByName paid ₹${e["amount"]}",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "₹${e["amount"]}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isYouPaid ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
