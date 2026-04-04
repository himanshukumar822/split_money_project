import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';

class BalanceTab extends StatelessWidget {
  final String groupId;

  const BalanceTab({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, provider, child) {
        final group = provider.groups.firstWhere((g) => g.id == groupId);

        final balances = group.balances ?? [];

        if (balances.isEmpty) {
          return const Center(child: Text("No balances yet"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: balances.length,
          itemBuilder: (context, index) {
            final b = balances[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 👤 FROM
                  Column(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(height: 4),
                      Text(b['from']['name']),
                    ],
                  ),

                  // 💰 AMOUNT
                  Column(
                    children: [
                      Text(
                        "₹${b['amount']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text("will pay"),
                    ],
                  ),

                  // 👤 TO
                  Column(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(height: 4),
                      Text(b['to']['name']),
                    ],
                  ),

                  // 🔘 BUTTON
                  ElevatedButton(
                    onPressed: () {
                      // future: settle logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Settle Up"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
