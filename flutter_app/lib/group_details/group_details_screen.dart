import 'package:flutter/material.dart';

import 'package:split_money/group_details/balance_tab.dart';
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

  int _currentTab = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7FC),
        elevation: 0,

        title: Text(
          widget.group.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        actions: [
          IconButton(
            onPressed: () {
              // Settings can be added here later.
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
          ),

          const SizedBox(width: 6),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: TabBar(
            controller: _tabController,

            indicatorSize: TabBarIndicatorSize.tab,

            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(width: 4, color: Color(0xFF5A67D8)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),

            labelColor: const Color(0xFF5A67D8),

            unselectedLabelColor: Colors.grey[600],

            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),

            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),

            tabs: const [
              Tab(text: "Expenses"),
              Tab(text: "Balance"),
            ],
          ),
        ),
      ),

      body: IndexedStack(
        index: _currentTab,

        children: [
          ExpenseTab(
            key: const PageStorageKey("expense_tab"),
            groupId: widget.group.id,
          ),

          BalanceScreen(
            key: const PageStorageKey("balance_tab"),
            groupId: widget.group.id,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF111111),

        foregroundColor: Colors.white,

        elevation: 8,

        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(groupId: widget.group.id),
            ),
          );

          // Refresh the currently visible tab
          // when returning from Add Expense.
          if (mounted) {
            setState(() {});
          }
        },

        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
