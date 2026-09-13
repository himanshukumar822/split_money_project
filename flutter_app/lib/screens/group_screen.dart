import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:split_money/providers/group_provider.dart';
import 'package:split_money/screens/creategroup_screen.dart';
import 'package:split_money/providers/auth_provider.dart';
import 'package:split_money/group_details/group_details_screen.dart';
import 'package:split_money/services/group_services.dart';

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

  final GroupServices _groupServices = GroupServices();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      userId = auth.userId;
      token = auth.token;

      print("USER NAME: ${auth.userName}");

      groupProvider.getGroups(userId, token);
      fetchSummary();
    });
  }

  Future<void> fetchSummary() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final url =
          "https://split-money-backend.onrender.com/api/balances/summary/${auth.userName}";

      print("CALLING API: $url");

      final response = await http.get(Uri.parse(url));

      print("API RESPONSE: ${response.body}");

      final data = jsonDecode(response.body);

      if (!mounted) return;

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

  void _openCreateGroupSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateGroupSheet(),
    );
  }

  Future<void> _moveToBackup(dynamic group) async {
    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Move to Backup?"),
          content: Text('Do you want to move "${group.name}" to Backup?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Move to Backup"),
            ),
          ],
        );
      },
    );

    if (shouldArchive != true) return;

    try {
      await _groupServices.archiveGroup(group.id, token);

      if (!mounted) return;

      Provider.of<GroupProvider>(context, listen: false).removeGroup(group.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Group moved to Backup")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to move group to Backup: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Groups", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _openCreateGroupSheet,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SUMMARY CARD
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

            // GROUP LIST
            Expanded(
              child: Consumer<GroupProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: provider.groups.length + 1,
                    itemBuilder: (context, index) {
                      // CREATE NEW GROUP
                      if (index == 0) {
                        return _buildCreateGroupItem();
                      }

                      // GROUP
                      final group = provider.groups[index - 1];

                      print("GROUP UI: ${group.name} -> ${group.groupType}");

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailScreen(group: group),
                            ),
                          );

                          fetchSummary();
                        },
                        onLongPress: () {
                          _moveToBackup(group);
                        },
                        child: _recentGroupItem(group.name, group.groupType),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CREATE GROUP ITEM
  Widget _buildCreateGroupItem() {
    return GestureDetector(
      onTap: _openCreateGroupSheet,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          const SizedBox(
            width: 70,
            child: Text(
              "Create new",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 2),
          const SizedBox(width: 70, height: 16),
        ],
      ),
    );
  }

  // BALANCE ITEM
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

  // GROUP ITEM
  Widget _recentGroupItem(String name, String groupType) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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
              child: Icon(_getGroupIcon(groupType), size: 30),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 70,
          child: Text(
            groupType,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  // GROUP ICON
  IconData _getGroupIcon(String groupType) {
    switch (groupType) {
      case "Home":
        return Icons.home;
      case "Trip":
        return Icons.luggage;
      case "Couple":
        return Icons.favorite;
      case "Personal":
        return Icons.person;
      case "Business":
        return Icons.work;
      case "Office":
        return Icons.apartment;
      case "Sports":
        return Icons.sports_tennis;
      case "Others":
        return Icons.group;
      default:
        return Icons.group;
    }
  }
}
