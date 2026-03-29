import 'package:flutter/material.dart';
import 'package:split_money/screens/add_expense.dart';

class CreategroupScreen extends StatefulWidget {
  const CreategroupScreen({super.key});

  @override
  State<CreategroupScreen> createState() => _CreategroupScreenState();
}

class _CreategroupScreenState extends State<CreategroupScreen> {
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
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),

      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🏷 Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Create a group",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // ✏️ Input Field
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Group name",
                  hintText: "Enter a group name",
                  border: UnderlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // 📦 Grid Options
              GridView.builder(
                shrinkWrap: true,
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
                  // ❌ Cancel
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                  ),

                  // ✅ Create
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
                    onPressed: () {
                      String groupName = _controller.text.trim();

                      if (groupName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter group name"),
                          ),
                        );
                        return;
                      }

                      // 👉 Navigate to next screen (you'll define later)
                      print("Group: $groupName, Type: $selectedType");
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddExpenseScreen(),
                        ),
                      );
                      // Example:
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
                    },
                    child: const Text("Create"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
