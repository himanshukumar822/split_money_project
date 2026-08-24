// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_money/screens/add_expense.dart';
import 'package:split_money/providers/auth_provider.dart';
import 'package:split_money/providers/group_provider.dart';

class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final TextEditingController _controller = TextEditingController();
  String selectedType = "Home";

  final List<Map<String, dynamic>> groupTypes = [
    {"name": "Home", "icon": Icons.home},
    {"name": "Trip", "icon": Icons.luggage},
    {"name": "Couple", "icon": Icons.favorite},
    {"name": "Personal", "icon": Icons.person},
    {"name": "Business", "icon": Icons.work},
    {"name": "Office", "icon": Icons.apartment},
    {"name": "Sports", "icon": Icons.sports_tennis},
    {"name": "Others", "icon": Icons.group},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          // ✅ IMPORTANT FIX
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔘 Drag handle
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // 🏷 Title
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Create a group",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                // ✏️ Input
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: "Group name",
                    border: UnderlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // 📦 Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupTypes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final item = groupTypes[index];
                    final isSelected = selectedType == item["name"];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = item["name"];
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF5A67D8).withOpacity(0.2)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item["icon"],
                              color: isSelected
                                  ? const Color(0xFF5A67D8)
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(item["name"]),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🔘 Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    // Create
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        String groupName = _controller.text.trim();

                        if (groupName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter group name"),
                            ),
                          );
                          return;
                        }
                        final auth = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final groupProvider = Provider.of<GroupProvider>(
                          context,
                          listen: false,
                        );

                        String userId = auth.userId;
                        String token = auth.token;

                        print("Creating group with userId: $userId");
                        final group = await groupProvider.addGroup(
                          groupName,
                          userId,
                          token,
                        );

                        if (group != null) {
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddExpenseScreen(
                                groupId: group["_id"], // ✅ IMPORTANT
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text("Create"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
