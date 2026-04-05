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

  // ✅ Track settled transactions (LOCAL ONLY)
  Set<String> settledIds = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final data = await balanceService.getBalances(widget.groupId, auth.token);

      setState(() {
        transactions = data;
        isLoading = false;
      });
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
        amount: t["amount"].toDouble(),
        paidBy: t["from"],
        splitBetween: [t["to"]],
        token: auth.token,
        groupId: widget.groupId,
        isSettlement: true,
      );

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

        final id = "${t["from"]}-${t["to"]}-${t["amount"]}";
        final isSettled = settledIds.contains(id);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSettled ? Colors.red[50] : Colors.white, // 🔥 RED LIGHT
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// FROM
              Column(
                children: [
                  const CircleAvatar(radius: 25),
                  const SizedBox(height: 6),
                  Text(t["from"]),
                ],
              ),

              /// AMOUNT
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

              /// TO
              Column(
                children: [
                  const CircleAvatar(radius: 25),
                  const SizedBox(height: 6),
                  Text(t["to"]),
                ],
              ),

              /// BUTTON
              ElevatedButton(
                onPressed: (isSettling || isSettled)
                    ? null
                    : () async {
                        // ✅ ONLY UI change
                        setState(() {
                          settledIds.add(id);
                        });

                        // ✅ Backend update (for balances)
                        await settleTransaction(t);

                        // ❌ NO loadData() → stays visible
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSettled ? Colors.red : Colors.green,
                ),
                child: isSettled
                    ? const Text("Settled") // 🔥 RED STATE
                    : isSettling
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
