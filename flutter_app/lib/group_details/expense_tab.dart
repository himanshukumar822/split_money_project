import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';

class ExpenseTab extends StatelessWidget {
  final String groupId;

  const ExpenseTab({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, provider, child) {
        final group = provider.groups.firstWhere((g) => g.id == groupId);

        final expenses = group.expenses ?? [];

        if (expenses.isEmpty) {
          return const Center(child: Text("No expenses yet"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final e = expenses[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.receipt)),

                title: Text(
                  e.description ?? "No description",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Text("${e.paidBy['name']} paid ₹${e.amount}"),

                trailing: Text(
                  "₹${(e.amount / (group.members.length)).toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
