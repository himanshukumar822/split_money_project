import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List allActivities = []; // 🔥 full list
  List activities = []; // 🔥 filtered list
  bool isLoading = true;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    try {
      final response = await http.get(
        Uri.parse("http://172.18.5.69:5000/api/activity"),
      );

      final data = jsonDecode(response.body);

      setState(() {
        allActivities = data["activities"] ?? [];
        activities = allActivities; // initial full list
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  /// 🔍 SEARCH FUNCTION
  void filterActivities(String query) {
    if (query.isEmpty) {
      setState(() {
        activities = allActivities;
      });
      return;
    }

    final filtered = allActivities.where((activity) {
      final message = (activity["message"] ?? "").toLowerCase();
      return message.contains(query.toLowerCase());
    }).toList();

    setState(() {
      activities = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activity"), elevation: 0),

      body: Column(
        children: [
          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: filterActivities,
              decoration: InputDecoration(
                hintText: "Search by group or name...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          /// CONTENT
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : activities.isEmpty
                ? const Center(child: Text("No results found"))
                : RefreshIndicator(
                    onRefresh: fetchActivities,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 5),
                            ],
                          ),
                          child: Row(
                            children: [
                              /// ICON
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: getColor(activity["type"]),
                                child: Icon(
                                  getIcon(activity["type"]),
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// TEXT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity["message"] ?? "",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatDate(activity["createdAt"]),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// 📅 DATE FORMAT
  String formatDate(String date) {
    final dt = DateTime.parse(date).toLocal();
    return "${dt.day}/${dt.month}/${dt.year} • "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  /// ICONS
  IconData getIcon(String type) {
    switch (type) {
      case "GROUP_CREATED":
        return Icons.group;
      case "EXPENSE_ADDED":
        return Icons.receipt_long;
      case "SETTLEMENT":
        return Icons.payments;
      default:
        return Icons.notifications;
    }
  }

  /// COLORS
  Color getColor(String type) {
    switch (type) {
      case "GROUP_CREATED":
        return Colors.blue;
      case "EXPENSE_ADDED":
        return Colors.orange;
      case "SETTLEMENT":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
