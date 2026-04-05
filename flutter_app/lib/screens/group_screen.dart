import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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

  double youOwe = 0;
  double youGet = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      userId = auth.userId;
      token = auth.token;

      print("USER NAME: ${auth.userName}"); // 🔥 DEBUG

      groupProvider.getGroups(userId, token);

      fetchSummary();
    });
  }

  // 🔥 FETCH TOTAL BALANCE
  Future<void> fetchSummary() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final url =
          "http://172.18.5.69:5000/api/balances/summary/${auth.userName}";

      print("CALLING API: $url"); // 🔥 DEBUG

      final response = await http.get(Uri.parse(url));

      print("API RESPONSE: ${response.body}"); // 🔥 DEBUG

      final data = jsonDecode(response.body);

      setState(() {
        youOwe = (data["youOwe"] ?? 0).toDouble();
        youGet = (data["youGet"] ?? 0).toDouble();
      });

      print("YOU OWE: $youOwe");
      print("YOU GET: $youGet");
    } catch (e) {
      print("SUMMARY ERROR: $e");
    }
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
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _balanceItem(
                    title: "You owe",
                    amount: "₹${youOwe.toInt()}",
                    color: Colors.redAccent,
                  ),
                  Container(height: 40, width: 1, color: Colors.white30),
                  _balanceItem(
                    title: "You get",
                    amount: "₹${youGet.toInt()}",
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

            // 🔥 GROUP LIST
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
                      // ➕ CREATE GROUP
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
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            const Text("Create new"),
                          ],
                        ),
                      ),

                      // 🔥 GROUP ITEMS
                      ...provider.groups.map((group) {
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GroupDetailScreen(group: group),
                              ),
                            );

                            // 🔥 REFRESH AFTER RETURN
                            fetchSummary();
                          },
                          child: _recentGroupItem(group.name),
                        );
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
        Text(title, style: const TextStyle(color: Colors.white70)),
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
              child: const Icon(Icons.luggage),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
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
