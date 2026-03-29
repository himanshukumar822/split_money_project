import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:split_money/screens/contact_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  List<Map<String, dynamic>> members = [
    {"name": "You", "isYou": true},
  ];

  String paidBy = "You";

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool isEqualSplit = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Add Expense", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👥 Add Friends + Members
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final contact = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactsScreen()),
                    );

                    if (contact != null) {
                      setState(() {
                        if (!members.any(
                          (m) => m["name"] == contact.displayName,
                        )) {
                          members.add({
                            "name": contact.displayName ?? "No Name",
                            "contact": contact,
                            "isYou": false,
                          });
                        }
                      });
                    }
                  },
                  child: Column(
                    children: const [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                      SizedBox(height: 6),
                      Text("Add Friends"),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: members.map((member) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _memberChip(member),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 📦 FORM CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: paidBy,
                    items: members.map<DropdownMenuItem<String>>((member) {
                      return DropdownMenuItem<String>(
                        value: member["name"] as String,
                        child: Text(member["name"] as String),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        paidBy = val!;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Paid By"),
                  ),

                  const SizedBox(height: 20),

                  // 🔀 Split Toggle
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => isEqualSplit = true);
                          },
                          child: _splitButton("Equally", isEqualSplit),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => isEqualSplit = false);
                          },
                          child: _splitButton("Unequally", !isEqualSplit),
                        ),
                      ),
                    ],
                  ),

                  if (isEqualSplit) _buildEqualSplitUI(),

                  const SizedBox(height: 20),

                  // 🚀 Submit Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                    ),
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Expense Added")),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          "Submit Expense",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 Split Button
  Widget _splitButton(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF5A67D8)
            : const Color(0xFF5A67D8).withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // 💰 Equal Split UI
  Widget _buildEqualSplitUI() {
    double total = double.tryParse(amountController.text) ?? 0;
    int count = members.length;

    double share = count > 0 ? total / count : 0;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Split Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...members.map((m) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(m["name"]), Text("₹${share.toStringAsFixed(2)}")],
            );
          }),

          const Divider(),

          Text(
            "$paidBy paid ₹${total.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          ...members
              .where((m) => m["name"] != paidBy)
              .map(
                (m) => Text(
                  "${m["name"]} owes ₹${share.toStringAsFixed(2)} to $paidBy",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
        ],
      ),
    );
  }

  // 👤 Member Chip
  Widget _memberChip(Map<String, dynamic> member) {
    return Stack(
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              child: Text(member["name"][0].toUpperCase()),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: Text(
                member["name"],
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                members.remove(member);
                if (paidBy == member["name"]) {
                  paidBy = members.first["name"];
                }
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
