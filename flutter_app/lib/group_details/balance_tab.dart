import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/balance_service.dart';
import '../services/expense_services.dart';

class BalanceScreen extends StatefulWidget {
  final String groupId;

  const BalanceScreen({super.key, required this.groupId});

  @override
  BalanceScreenState createState() => BalanceScreenState();
}

class BalanceScreenState extends State<BalanceScreen>
    with AutomaticKeepAliveClientMixin {
  final BalanceService balanceService = BalanceService();
  final ExpenseService expenseService = ExpenseService();

  List<Map<String, dynamic>> transactions = [];

  bool isLoading = true;
  int? settlingIndex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ---------------------------------------------------------
  // REFRESH BALANCE
  // ---------------------------------------------------------

  Future<void> refreshBalances() async {
    await loadData();
  }

  Future<void> loadData() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final data = await balanceService.getBalances(widget.groupId, auth.token);

      if (!mounted) return;

      final newTransactions = List<Map<String, dynamic>>.from(
        data.map(
          (e) => {
            "from": e["from"],
            "to": e["to"],
            "amount": e["amount"],
            "isSettled": false,
          },
        ),
      );

      setState(() {
        transactions = newTransactions;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("BALANCE ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------
  // USER NAME
  // ---------------------------------------------------------

  String getUserName(String? name) {
    if (name == null || name.isEmpty) {
      return "Unknown";
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (name == auth.name) {
      return "You";
    }

    return name;
  }

  // ---------------------------------------------------------
  // SETTLE TRANSACTION
  // ---------------------------------------------------------

  Future<void> settleTransaction(
    Map<String, dynamic> transaction,
    int index,
  ) async {
    if (settlingIndex != null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final from = transaction["from"];
    final to = transaction["to"];
    final amount = transaction["amount"];

    setState(() {
      settlingIndex = index;
    });

    try {
      await expenseService.addExpense(
        description: "Settlement",
        amount: (amount as num).toDouble(),
        paidBy: to,
        splitBetween: [from],
        token: auth.token,
        groupId: widget.groupId,
        isSettlement: true,
      );

      if (!mounted) return;

      setState(() {
        transactions[index]["isSettled"] = true;
        settlingIndex = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Settlement recorded successfully"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      debugPrint("SETTLEMENT ERROR: $e");

      if (!mounted) return;

      setState(() {
        settlingIndex = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (isLoading && transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: refreshBalances,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 100),

            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 48,
                  color: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                "All settled up!",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                "Everyone is even in this group.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshBalances,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];

          final from = transaction["from"];
          final to = transaction["to"];
          final amount = transaction["amount"];

          final bool isSettled = transaction["isSettled"] == true;

          final bool isThisOneLoading = settlingIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // ------------------------------------------------
                  // HEADER
                  // ------------------------------------------------
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.orange,
                          size: 23,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          "Payment due",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      Text(
                        "₹${amount.toString()}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ------------------------------------------------
                  // PEOPLE
                  // ------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: _PersonCard(
                          name: getUserName(from),
                          icon: Icons.arrow_upward_rounded,
                          iconColor: Colors.red,
                          backgroundColor: Colors.red.withOpacity(0.08),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      Expanded(
                        child: _PersonCard(
                          name: getUserName(to),
                          icon: Icons.arrow_downward_rounded,
                          iconColor: Colors.green,
                          backgroundColor: Colors.green.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // SETTLE BUTTON
                  // ------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSettled || isThisOneLoading
                          ? null
                          : () {
                              settleTransaction(transaction, index);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: isSettled
                            ? Colors.green.withOpacity(0.15)
                            : Colors.grey.shade300,
                        disabledForegroundColor: isSettled
                            ? Colors.green
                            : Colors.grey,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isThisOneLoading
                          ? const SizedBox(
                              height: 21,
                              width: 21,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSettled
                                      ? Icons.check_circle_rounded
                                      : Icons.done_all_rounded,
                                  size: 19,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isSettled ? "Settled Up" : "Settle Up",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// PERSON CARD
// ============================================================

class _PersonCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _PersonCard({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_rounded, color: iconColor, size: 25),
          ),

          const SizedBox(height: 9),

          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),

          const SizedBox(height: 4),

          Icon(icon, color: iconColor, size: 18),
        ],
      ),
    );
  }
}
