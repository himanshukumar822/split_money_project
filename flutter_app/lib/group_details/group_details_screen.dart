import 'package:flutter/material.dart';
import 'package:split_money/group_details/balance_tab.dart';
//import 'package:split_money/group_details/balance_tab.dart';
import 'package:split_money/group_details/expense_tab.dart';
import 'package:split_money/screens/add_expense.dart';

class GroupDetailScreen extends StatefulWidget {
  final dynamic group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // only 2 tabs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [Icon(Icons.settings), SizedBox(width: 10)],
      ),

      body: Column(
        children: [
          // 🔥 Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            tabs: [
              Tab(text: "Expense"),
              Tab(text: "Balance"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ExpenseTab(groupId: widget.group.id),
                BalanceScreen(groupId: widget.group.id),
              ],
            ),
          ),
        ],
      ),

      // ➕ Floating button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(groupId: widget.group.id),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
