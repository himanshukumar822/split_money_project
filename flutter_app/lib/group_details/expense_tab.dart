import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/expense_services.dart';
import '../providers/auth_provider.dart';

class ExpenseTab extends StatefulWidget {
  final String groupId;

  const ExpenseTab({
    super.key,
    required this.groupId,
  });

  @override
  ExpenseTabState createState() => ExpenseTabState();
}

class ExpenseTabState extends State<ExpenseTab>
    with AutomaticKeepAliveClientMixin {
  final ExpenseService expenseService = ExpenseService();

  List expenses = [];
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  // ---------------------------------------------------------
  // REFRESH EXPENSES
  // ---------------------------------------------------------

  Future<void> refreshExpenses() async {
    await fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    try {
      final auth = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      final data = await expenseService.getExpenses(
        widget.groupId,
        auth.token,
      );

      if (!mounted) return;

      setState(() {
        expenses = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("EXPENSE ERROR: $e");

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

    final auth = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    if (name == auth.name) {
      return "You";
    }

    return name;
  }

  // ---------------------------------------------------------
  // DATE / TIME
  // ---------------------------------------------------------

  DateTime? getLocalDate(dynamic createdAt) {
    if (createdAt == null) {
      return null;
    }

    try {
      return DateTime.parse(
        createdAt.toString(),
      ).toLocal();
    } catch (e) {
      debugPrint("DATE ERROR: $e");
      return null;
    }
  }

  String formatExpenseDate(dynamic createdAt) {
    final date = getLocalDate(createdAt);

    if (date == null) {
      return "";
    }

    return DateFormat(
      "dd MMM yyyy, hh:mm a",
    ).format(date);
  }

  // ---------------------------------------------------------
  // EXPENSE DETAIL SCREEN
  // ---------------------------------------------------------

  void openExpenseDetail(
    Map<String, dynamic> expense,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseDetailScreen(
          expense: expense,
          getUserName: getUserName,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (isLoading && expenses.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // -------------------------------------------------------
    // EMPTY STATE
    // -------------------------------------------------------

    if (expenses.isEmpty) {
      return RefreshIndicator(
        onRefresh: refreshExpenses,
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
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 44,
                  color: Colors.grey[700],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                "No expenses yet",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Text(
                "Add your first expense using the + button above.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      );
    }

    // -------------------------------------------------------
    // EXPENSE LIST
    // -------------------------------------------------------

    return RefreshIndicator(
      onRefresh: refreshExpenses,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          30,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = Map<String, dynamic>.from(
            expenses[index],
          );

          final description =
              expense["description"] ?? "Expense";

          final amount = expense["amount"] ?? 0;

          final paidBy = expense["paidBy"];

          final createdAt = expense["createdAt"];

          final formattedDate =
              formatExpenseDate(createdAt);

          return GestureDetector(
            onTap: () {
              openExpenseDetail(expense);
            },
            child: Container(
              margin: const EdgeInsets.only(
                bottom: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.045),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // -----------------------------------------
                    // EXPENSE ICON
                    // -----------------------------------------

                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06),
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 27,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // -----------------------------------------
                    // EXPENSE INFORMATION
                    // -----------------------------------------

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            description.toString(),
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Icon(
                                Icons
                                    .person_outline_rounded,
                                size: 15,
                                color: Colors.grey[600],
                              ),

                              const SizedBox(width: 4),

                              Expanded(
                                child: Text(
                                  "Paid by ${getUserName(paidBy?.toString())}",
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (formattedDate.isNotEmpty) ...[
                            const SizedBox(height: 4),

                            Row(
                              children: [
                                Icon(
                                  Icons
                                      .access_time_rounded,
                                  size: 14,
                                  color:
                                      Colors.grey[500],
                                ),

                                const SizedBox(width: 4),

                                Expanded(
                                  child: Text(
                                    formattedDate,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // -----------------------------------------
                    // AMOUNT
                    // -----------------------------------------

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${amount.toString()}",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green
                                .withOpacity(0.10),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Expense",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 2),

                    // -----------------------------------------
                    // ARROW
                    // -----------------------------------------

                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey[400],
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// EXPENSE DETAIL SCREEN
// ============================================================

class ExpenseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> expense;
  final String Function(String?) getUserName;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
    required this.getUserName,
  });

  // ---------------------------------------------------------
  // DATE / TIME
  // ---------------------------------------------------------

  DateTime? getLocalDate(dynamic createdAt) {
    if (createdAt == null) {
      return null;
    }

    try {
      return DateTime.parse(
        createdAt.toString(),
      ).toLocal();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final description =
        expense["description"] ?? "Expense";

    final amount =
        (expense["amount"] as num?)?.toDouble() ?? 0;

    final paidBy = expense["paidBy"];

    final splitBetween =
        expense["splitBetween"] is List
            ? List.from(expense["splitBetween"])
            : [];

    final createdAt = expense["createdAt"];

    final date = getLocalDate(createdAt);

    final double share =
        splitBetween.isNotEmpty
            ? amount / splitBetween.length
            : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Expense Details",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------
            // TOP EXPENSE ICON
            // ------------------------------------------------

            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 38,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ------------------------------------------------
            // DESCRIPTION
            // ------------------------------------------------

            Center(
              child: Text(
                description.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ------------------------------------------------
            // TOTAL
            // ------------------------------------------------

            Center(
              child: Text(
                "₹${amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // PAID BY
            // ------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color:
                          Colors.blue.withOpacity(0.10),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Paid by",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          getUserName(
                            paidBy?.toString(),
                          ),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------
            // DATE
            // ------------------------------------------------

            if (date != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.orange
                            .withOpacity(0.10),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons
                            .calendar_month_rounded,
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 13),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date & time",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          DateFormat(
                            "dd MMM yyyy, hh:mm a",
                          ).format(date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            // ------------------------------------------------
            // SPLIT BETWEEN
            // ------------------------------------------------

            const Text(
              "Split Between",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (splitBetween.isEmpty)
              const Text(
                "No members",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

            ...splitBetween.map(
              (member) {
                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Colors.grey.shade100,
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          getUserName(
                            member.toString(),
                          ),
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      Text(
                        "₹${share.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}