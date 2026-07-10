import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/balance_service.dart';
import '../services/expense_services.dart';
import '../providers/auth_provider.dart';

class BalanceScreen extends StatefulWidget {
  final String groupId;

  const BalanceScreen({super.key, required this.groupId});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final BalanceService balanceService = BalanceService();
  final ExpenseService expenseService = ExpenseService();

  List transactions = [];
  bool isLoading = true;
  bool isSettling = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  String getUserName(String? name) {
    if (name == null || name.isEmpty) return "Unknown";

    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (name == auth.name) {
      return "You";
    }

    return name;
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final data = await balanceService.getBalances(widget.groupId, auth.token);

      print("Transactions: $data");

      transactions = List<Map<String, dynamic>>.from(
        data.map(
          (e) => {
            "from": e["from"]?.toString(),
            "to": e["to"]?.toString(),
            "amount": e["amount"] ?? 0,
          },
        ),
      );

      setState(() => isLoading = false);
    } catch (e) {
      print("Balance error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> settleTransaction(Map t) async {
    setState(() => isSettling = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      await expenseService.addExpense(
        description: "Settlement",
        amount: (t["amount"] ?? 0).toDouble(),
        paidBy: t["to"],
        splitBetween: [t["from"]],
        token: auth.token,
        groupId: widget.groupId,
        isSettlement: true,
      );

      await loadData();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Settlement recorded ✅")));
    } catch (e) {
      print("Settlement error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to settle ❌")));
    } finally {
      setState(() => isSettling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty) {
      return const Center(child: Text("No transactions"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 25),
                    const SizedBox(height: 6),
                    Text(
                      getUserName(t["from"]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  Text(
                    "₹${t["amount"]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text("will pay"),
                ],
              ),

              Expanded(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 25),
                    const SizedBox(height: 6),
                    Text(getUserName(t["to"]), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: isSettling ? null : () => settleTransaction(t),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: isSettling
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Settle Up"),
              ),
            ],
          ),
        );
      },
    );
  }
}
