import 'package:flutter/material.dart';
import '../models/group_model.dart';

class GroupCard extends StatelessWidget {
  final Group group;

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(group.name),
        leading: const Icon(Icons.group),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Later → navigate to group details
        },
      ),
    );
  }
}
