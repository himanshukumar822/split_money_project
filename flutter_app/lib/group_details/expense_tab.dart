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

      if (!mounted) return;

      setState(() {
        expenses = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching expenses: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
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

    return NumberFormat.currency(
      locale: "en_IN",
      symbol: "₹",
      decimalDigits: 0,
    ).format(value);
  }

  String formatFullDate(DateTime date) {
    return DateFormat("dd MMM yyyy • hh:mm a").format(date);
  }

  String formatTime(DateTime date) {
    return DateFormat("hh:mm a").format(date);
  }

  double calculateShare(dynamic amount, int memberCount) {
    final total = double.tryParse(amount.toString()) ?? 0;

    if (memberCount == 0) {
      return 0;
    }

    return total / memberCount;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (expenses.isEmpty) {
      return RefreshIndicator(
        onRefresh: fetchExpenses,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 150),
            Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Center(
              child: Text(
                "No expenses yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                "Your group expenses will appear here.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchExpenses,

      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: expenses.length,

        itemBuilder: (context, index) {
          final e = expenses[index];

          final description = e["description"]?.toString() ?? "Expense";

          final amount = e["amount"] ?? 0;

          final paidByRaw = e["paidBy"]?.toString();

          final paidByName = getUserName(paidByRaw);

          final isYouPaid = paidByName == "You";

          final splitBetween =
              (e["splitBetween"] as List?)
                  ?.map((item) => item.toString())
                  .toList() ??
              [];

          final date =
              DateTime.tryParse(e["createdAt"]?.toString() ?? "") ??
              DateTime.now();

          return _buildExpenseCard(
            expense: e,
            description: description,
            amount: amount,
            paidByName: paidByName,
            isYouPaid: isYouPaid,
            splitBetween: splitBetween,
            date: date,
          );
        },
      ),
    );
  }

  Widget _buildExpenseCard({
    required Map expense,
    required String description,
    required dynamic amount,
    required String paidByName,
    required bool isYouPaid,
    required List<String> splitBetween,
    required DateTime date,
  }) {
    return GestureDetector(
      onTap: () {
        _showExpenseDetails(
          expense: expense,
          description: description,
          amount: amount,
          paidByName: paidByName,
          splitBetween: splitBetween,
          date: date,
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // EXPENSE ICON
                  Container(
                    width: 54,
                    height: 54,

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),

                      borderRadius: BorderRadius.circular(17),
                    ),

                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // DESCRIPTION
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),

                            const SizedBox(width: 4),

                            Text(
                              formatTime(date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // AMOUNT
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: [
                      Text(
                        formatAmount(amount),

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isYouPaid
                              ? const Color(0xFF159957)
                              : const Color(0xFFE53935),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // DIVIDER
              Container(height: 1, color: Colors.grey[100]),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 17,
                    color: Colors.grey[600],
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      isYouPaid
                          ? "You paid this expense"
                          : "$paidByName paid this expense",

                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.09),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      "${splitBetween.length} people",

                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5A67D8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpenseDetails({
    required Map expense,
    required String description,
    required dynamic amount,
    required String paidByName,
    required List<String> splitBetween,
    required DateTime date,
  }) {
    final share = calculateShare(amount, splitBetween.length);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),

          child: SafeArea(
            child: Column(
              children: [
                // DRAG HANDLE
                Container(
                  margin: const EdgeInsets.only(top: 10),

                  width: 45,
                  height: 5,

                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const SizedBox(height: 12),

                        // HEADER
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,

                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                ),

                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    description,

                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    formatFullDate(date),

                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // AMOUNT CARD
                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(22),

                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),

                            borderRadius: BorderRadius.circular(24),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "TOTAL EXPENSE",

                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                formatAmount(amount),

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // PAID BY
                        _detailSection(
                          title: "PAID BY",
                          child: Container(
                            padding: const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              color: Colors.grey[50],

                              borderRadius: BorderRadius.circular(18),

                              border: Border.all(color: Colors.grey[200]!),
                            ),

                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 23,

                                  backgroundColor: const Color(0xFF667EEA),

                                  child: Text(
                                    paidByName.isNotEmpty
                                        ? paidByName[0].toUpperCase()
                                        : "?",

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        paidByName,

                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        "Paid ${formatAmount(amount)}",

                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // MEMBERS
                        _detailSection(
                          title: "SPLIT BETWEEN • ${splitBetween.length}",

                          child: Column(
                            children: splitBetween.map((member) {
                              final name = getUserName(member);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),

                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.grey[50],

                                  borderRadius: BorderRadius.circular(16),
                                ),

                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 19,

                                      backgroundColor: Colors.grey[200],

                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : "?",

                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 11),

                                    Expanded(
                                      child: Text(
                                        name,

                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    Text(
                                      formatAmount(share),

                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // DATE / TIME
                        _detailSection(
                          title: "TIMESTAMP",

                          child: Container(
                            padding: const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              color: Colors.grey[50],

                              borderRadius: BorderRadius.circular(18),
                            ),

                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,

                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF667EEA,
                                    ).withOpacity(0.1),

                                    borderRadius: BorderRadius.circular(14),
                                  ),

                                  child: const Icon(
                                    Icons.calendar_month_rounded,
                                    color: Color(0xFF5A67D8),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      DateFormat("dd MMMM yyyy").format(date),

                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(height: 3),

                                    Text(
                                      DateFormat("hh:mm:ss a").format(date),

                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // CLOSE BUTTON
                        SizedBox(
                          width: double.infinity,

                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,

                              foregroundColor: Colors.white,

                              padding: const EdgeInsets.symmetric(vertical: 16),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            child: const Text(
                              "Close",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
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
    );
  }

  Widget _detailSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.grey[600],
            letterSpacing: 1.1,
          ),
        ),

        const SizedBox(height: 10),

        child,
      ],
    );
  }

  // ignore: unused_element
  Widget _memberChip(Map<String, dynamic> member) {
    final name = member["name"] ?? "";

    return Padding(
      padding: const EdgeInsets.only(right: 10),

      child: Column(
        children: [
          CircleAvatar(
            radius: 28,

            backgroundColor: Colors.grey[300],

            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",

              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 4),

          SizedBox(
            width: 65,

            child: Text(
              name,

              overflow: TextOverflow.ellipsis,

              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
