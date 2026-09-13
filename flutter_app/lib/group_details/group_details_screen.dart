import 'package:flutter/material.dart';
import '../group_details/expense_tab.dart';
import '../group_details/balance_tab.dart';
import '../screens/add_expense.dart';

class GroupDetailScreen extends StatefulWidget {
  final dynamic group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final GlobalKey<ExpenseTabState> _expenseKey = GlobalKey<ExpenseTabState>();

  final GlobalKey<BalanceScreenState> _balanceKey =
      GlobalKey<BalanceScreenState>();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(groupId: widget.group.id),
      ),
    );

    if (result == true && mounted) {
      await _expenseKey.currentState?.refreshExpenses();
      await _balanceKey.currentState?.refreshBalances();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,

        title: Text(
          widget.group.name,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
              elevation: 3,
              shadowColor: Colors.black26,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _addExpense,
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.receipt_long_rounded, size: 19),
                  text: "Expenses",
                ),
                Tab(
                  icon: Icon(Icons.account_balance_wallet_rounded, size: 19),
                  text: "Balance",
                ),
              ],
            ),
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          ExpenseTab(key: _expenseKey, groupId: widget.group.id),
          BalanceScreen(key: _balanceKey, groupId: widget.group.id),
        ],
      ),
    );
  }
}
