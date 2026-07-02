import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/balance_service.dart';
import '../services/expense_services.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';

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

  /// ✅ SAFE USER NAME (NO CRASH EVER)
  String getUserName(String? userId) {
    if (userId == null) return "Unknown";

    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (userId == auth.userId) return "You";

    final userMap = buildUserMap();

    final user = userMap[userId];

    return user?["name"] ?? "Unknown";
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final data = await balanceService.getBalances(widget.groupId, auth.token);

      // ✅ FORCE SAFE LIST
      final List safeList = (data ?? []) as List;

      // ✅ CLEAN EACH ITEM
      transactions = safeList.map((e) {
        if (e is Map) {
          return {
            "from": e["from"]?.toString(),
            "to": e["to"]?.toString(),
            "amount": e["amount"] ?? 0,
          };
        }
        return {};
      }).toList();

      setState(() => isLoading = false);
    } catch (e) {
      print("Balance error: $e");
      setState(() => isLoading = false);
    }
  }

  Map<String, dynamic> buildUserMap() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    final group = groupProvider.groups.firstWhere(
      (g) => g.id == widget.groupId,
    );

    return {for (var user in group.members) user["_id"]: user};
  }

  Future<void> settleTransaction(Map t) async {
    setState(() => isSettling = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final amount = (t["amount"] ?? 0).toDouble();
      final from = t["from"]?.toString();
      final to = t["to"]?.toString();

      if (from == null || to == null) return;

      await expenseService.addExpense(
        description: "Settlement",
        amount: amount,
        paidBy: to,
        splitBetween: [from],
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
        if (index >= transactions.length) return const SizedBox();

        final t = transactions[index] ?? {};

        final fromId = t["from"]?.toString();
        final toId = t["to"]?.toString();
        final amount = t["amount"] ?? 0;

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
              /// FROM
              Expanded(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 25),
                    const SizedBox(height: 6),
                    Text(getUserName(fromId), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),

              /// AMOUNT
              Column(
                children: [
                  Text(
                    "₹$amount",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text("will pay"),
                ],
              ),

              /// TO
              Expanded(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 25),
                    const SizedBox(height: 6),
                    Text(getUserName(toId), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              /// BUTTON
              ElevatedButton(
                onPressed: isSettling
                    ? null
                    : () async {
                        await settleTransaction(t);
                      },
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
