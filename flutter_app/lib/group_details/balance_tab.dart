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

  // Stores the index of the balance currently being settled.
  // null means nothing is being settled.
  int? settlingIndex;

  @override
  void initState() {
    super.initState();
    loadData();
  }

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

  String formatAmount(dynamic amount) {
    final value = double.tryParse(amount.toString()) ?? 0;

    return "₹${value.toStringAsFixed(0)}";
  }

  // showLoading is true only when we want the
  // full-screen loading indicator.
  //
  // After settling an expense, we call:
  // loadData(showLoading: false)
  //
  // so the current UI remains visible while
  // the balance list refreshes.
  Future<void> loadData({bool showLoading = true}) async {
    if (mounted && showLoading) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final data = await balanceService.getBalances(widget.groupId, auth.token);

      print("Transactions: $data");

      final newTransactions = List<Map<String, dynamic>>.from(
        data.map(
          (e) => {
            "from": e["from"]?.toString(),
            "to": e["to"]?.toString(),
            "amount": e["amount"] ?? 0,
          },
        ),
      );

      if (!mounted) return;

      setState(() {
        transactions = newTransactions;
        isLoading = false;
      });
    } catch (e) {
      print("Balance error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> settleTransaction(Map t, int index) async {
    // Prevent another settlement from being
    // started while one is already processing.
    if (settlingIndex != null) {
      return;
    }

    // Immediately mark ONLY this transaction
    // as being settled.
    setState(() {
      settlingIndex = index;
    });

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

      // Refresh the balances WITHOUT showing
      // the full-screen loading indicator.
      await loadData(showLoading: false);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Settlement recorded ✅")));
    } catch (e) {
      print("Settlement error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to settle ❌")));
    } finally {
      if (mounted) {
        setState(() {
          settlingIndex = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only the initial load shows the full-screen loader.
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => loadData(showLoading: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 130),

            Icon(
              Icons.account_balance_wallet_rounded,
              size: 68,
              color: Colors.grey,
            ),

            SizedBox(height: 18),

            Center(
              child: Text(
                "All settled up",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),

            SizedBox(height: 8),

            Center(
              child: Text(
                "No outstanding balances in this group.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => loadData(showLoading: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),

        children: [
          _buildOverviewCard(),

          const SizedBox(height: 24),

          Row(
            children: [
              const Text(
                "Outstanding balances",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  "${transactions.length}",

                  style: const TextStyle(
                    color: Color(0xFF5A67D8),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Use indexes so we know exactly
          // which balance is being settled.
          ...transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final t = entry.value;

            return _buildBalanceCard(t, index);
          }),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    double total = 0;

    for (final transaction in transactions) {
      total += double.tryParse(transaction["amount"].toString()) ?? 0;
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.25),

            blurRadius: 22,

            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),

                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  "Group Balance",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            "TOTAL OUTSTANDING",

            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            formatAmount(total),

            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "${transactions.length} settlement${transactions.length == 1 ? '' : 's'} pending",

            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(Map t, int index) {
    final fromName = getUserName(t["from"]);

    final toName = getUserName(t["to"]);

    final amount = t["amount"];

    final isYouOwing = fromName == "You";

    // ONLY this card is currently settling.
    final isThisSettling = settlingIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),

            blurRadius: 18,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            Row(
              children: [
                _personAvatar(fromName, isYouOwing),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        fromName,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        isYouOwing
                            ? "You need to pay $toName"
                            : "$fromName needs to pay $toName",

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),

                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF5A67D8),
                    size: 21,
                  ),
                ),

                const SizedBox(width: 12),

                _personAvatar(toName, !isYouOwing),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.grey[50],

                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          isYouOwing
                              ? "You owe $toName"
                              : "$fromName pays $toName",

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          formatAmount(amount),

                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,

                            color: isYouOwing
                                ? const Color(0xFFE53935)
                                : const Color(0xFF159957),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    // Only prevent settlement while
                    // another settlement is processing.
                    onPressed: settlingIndex != null
                        ? null
                        : () {
                            _confirmSettlement(t, index);
                          },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),

                      foregroundColor: Colors.white,

                      disabledBackgroundColor: Colors.grey[400],

                      elevation: 0,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: isThisSettling
                        ? const SizedBox(
                            height: 18,
                            width: 18,

                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18,
                              ),

                              SizedBox(width: 6),

                              Text(
                                "Settle",

                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _personAvatar(String name, bool highlighted) {
    return Container(
      width: 50,
      height: 50,

      decoration: BoxDecoration(
        gradient: highlighted
            ? const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              )
            : null,

        color: highlighted ? null : Colors.grey[200],

        shape: BoxShape.circle,
      ),

      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",

          style: TextStyle(
            color: highlighted ? Colors.white : Colors.black87,

            fontWeight: FontWeight.w800,

            fontSize: 18,
          ),
        ),
      ),
    );
  }

  void _confirmSettlement(Map t, int index) {
    final fromName = getUserName(t["from"]);

    final toName = getUserName(t["to"]);

    final amount = t["amount"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),

          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  width: 45,
                  height: 5,

                  decoration: BoxDecoration(
                    color: Colors.grey[300],

                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: 64,
                  height: 64,

                  decoration: BoxDecoration(
                    color: const Color(0xFF159957).withOpacity(0.1),

                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.account_balance_wallet_rounded,

                    color: Color(0xFF159957),

                    size: 32,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Confirm Settlement",

                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 8),

                Text(
                  "$fromName will pay $toName",

                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),

                const SizedBox(height: 8),

                Text(
                  formatAmount(amount),

                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF159957),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: settlingIndex != null
                        ? null
                        : () async {
                            Navigator.pop(context);

                            await settleTransaction(t, index);
                          },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    child: const Text(
                      "Confirm & Settle",

                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,

                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
