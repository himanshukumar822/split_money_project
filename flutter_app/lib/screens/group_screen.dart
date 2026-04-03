import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_money/providers/group_provider.dart';
import 'package:split_money/screens/creategroup_screen.dart';
import 'package:split_money/providers/auth_provider.dart';
import 'package:split_money/group_details/group_details_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  String userId = "";
  String token = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      String userId = auth.userId;
      String token = auth.token;

      print("Calling getGroups with userId: $userId");

      groupProvider.getGroups(userId, token);
    });

    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      userId = auth.userId;
      token = auth.token;

      Provider.of<GroupProvider>(
        context,
        listen: false,
      ).getGroups(userId, token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // 🔝 App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Groups", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CreateGroupSheet(),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 💳 SUMMARY CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5A67D8), Color(0xFF3F4A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _balanceItem(
                    title: "You owe",
                    amount: "₹500",
                    color: Colors.redAccent,
                  ),
                  Container(height: 40, width: 1, color: Colors.white30),
                  _balanceItem(
                    title: "You get",
                    amount: "₹1200",
                    color: Colors.greenAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Recent Groups",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // 🔥 GROUP LIST (WRAP)
            Expanded(
              child: Consumer<GroupProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // ➕ CREATE BUTTON
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const CreateGroupSheet(),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text("Create new"),
                          ],
                        ),
                      ),

                      // 🔥 DYNAMIC GROUPS
                      ...provider.groups.map((group) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GroupDetailScreen(group: group),
                              ),
                            );
                          },
                          child: _recentGroupItem(group.name),
                        );
                        // ignore: unnecessary_to_list_in_spreads
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟣 Balance Item
  Widget _balanceItem({
    required String title,
    required String amount,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 📦 Group Item
  Widget _recentGroupItem(String name) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.luggage, size: 30),
            ),

            // 🔥 PLUS ICON TOP RIGHT
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
