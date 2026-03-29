import 'package:flutter/material.dart';
import 'package:split_money/screens/creategroup_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => CreategroupScreen()),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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

            // 🧾 RECENT GROUPS TITLE
            const Text(
              "Recent Groups",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // 🔥 HORIZONTAL LIST
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // ➕ CREATE NEW
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => CreategroupScreen()),
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

                  const SizedBox(width: 16),

                  // 📦 GROUP ITEMS
                  _recentGroupItem("Goa"),
                  _recentGroupItem("Beach"),
                  _recentGroupItem("Trip"),
                ],
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

  // 📦 Recent Group Item
  Widget _recentGroupItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
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

              // ➕ small plus badge
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFF5A67D8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
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
      ),
    );
  }
}
