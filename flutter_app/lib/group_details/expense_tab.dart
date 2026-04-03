import 'package:flutter/material.dart';

class ExpenseTab extends StatelessWidget {
  const ExpenseTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.restaurant)),
          title: Text("Dinner"),
          subtitle: Text("Aman paid ₹150"),
          trailing: Text("₹50", style: TextStyle(color: Colors.red)),
        ),

        ListTile(
          leading: CircleAvatar(child: Icon(Icons.directions_bus)),
          title: Text("Bus ride"),
          subtitle: Text("You paid ₹150"),
          trailing: Text("₹100", style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}
