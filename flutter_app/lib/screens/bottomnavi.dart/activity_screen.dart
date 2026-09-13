import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:split_money/providers/auth_provider.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List allActivities = [];
  List activities = [];

  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchActivities();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // FETCH ACTIVITIES
  // =========================================================

  Future<void> fetchActivities() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final response = await http.get(
        Uri.parse(
          "https://split-money-backend.onrender.com/api/activity?owner=${auth.userId}",
        ),
      );

      debugPrint("Activity Response: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to load activities");
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      final loadedActivities = data["activities"] ?? [];

      setState(() {
        allActivities = loadedActivities;

        _applySearchFilter();

        isLoading = false;
      });
    } catch (e) {
      debugPrint("ACTIVITY ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void filterActivities(String query) {
    setState(() {
      _applySearchFilter();
    });
  }

  void _applySearchFilter() {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      activities = List.from(allActivities);
      return;
    }

    activities = allActivities.where((activity) {
      final message = (activity["message"] ?? "").toString().toLowerCase();

      return message.contains(query);
    }).toList();
  }

  // =========================================================
  // DATE / TIME
  // =========================================================

  String formatDate(dynamic dateValue) {
    if (dateValue == null) {
      return "";
    }

    try {
      final dt = DateTime.parse(dateValue.toString()).toLocal();

      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);

      final activityDay = DateTime(dt.year, dt.month, dt.day);

      final difference = today.difference(activityDay).inDays;

      if (difference == 0) {
        return "Today • ${DateFormat("hh:mm a").format(dt)}";
      }

      if (difference == 1) {
        return "Yesterday • ${DateFormat("hh:mm a").format(dt)}";
      }

      return DateFormat("dd MMM yyyy • hh:mm a").format(dt);
    } catch (e) {
      return "";
    }
  }

  // =========================================================
  // ACTIVITY TITLE
  // =========================================================

  String getActivityTitle(String? type) {
    switch (type) {
      case "GROUP_CREATED":
        return "Group Created";

      case "EXPENSE_ADDED":
        return "New Expense";

      case "SETTLEMENT":
        return "Settlement";

      default:
        return "Activity";
    }
  }

  // =========================================================
  // ICON
  // =========================================================

  IconData getIcon(String? type) {
    switch (type) {
      case "GROUP_CREATED":
        return Icons.groups_rounded;

      case "EXPENSE_ADDED":
        return Icons.receipt_long_rounded;

      case "SETTLEMENT":
        return Icons.payments_rounded;

      default:
        return Icons.notifications_rounded;
    }
  }

  // =========================================================
  // COLOR
  // =========================================================

  Color getColor(String? type) {
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

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),

      body: SafeArea(
        child: Column(
          children: [
            // =================================================
            // TOP HEADER
            // =================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Activity",
                              style: TextStyle(
                                fontSize: 29,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.7,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Everything happening in your groups",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ACTIVITY COUNT
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "${activities.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "events",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // SEARCH
                  // =================================================
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: filterActivities,
                      decoration: InputDecoration(
                        hintText: "Search activity...",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey[700],
                        ),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  searchController.clear();

                                  filterActivities("");
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // ACTIVITY CONTENT
            // =================================================
            Expanded(child: _buildActivityContent()),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ACTIVITY CONTENT
  // =========================================================

  Widget _buildActivityContent() {
    if (isLoading && activities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activities.isEmpty) {
      return RefreshIndicator(
        onRefresh: fetchActivities,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 100),

            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  searchController.text.isEmpty
                      ? Icons.notifications_none_rounded
                      : Icons.search_off_rounded,
                  size: 42,
                  color: Colors.grey[700],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                searchController.text.isEmpty
                    ? "No activity yet"
                    : "No results found",
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  searchController.text.isEmpty
                      ? "Your group activity will appear here."
                      : "Try searching with another name or group.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchActivities,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];

          final type = activity["type"]?.toString();

          final message = activity["message"]?.toString() ?? "";

          final color = getColor(type);

          return Container(
            margin: const EdgeInsets.only(bottom: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // ICON
                  // =================================================
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(getIcon(type), color: color, size: 25),
                  ),

                  const SizedBox(width: 14),

                  // =================================================
                  // CONTENT
                  // =================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                getActivityTitle(type),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),

                            Text(
                              "${index + 1}",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 9),

                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),

                            const SizedBox(width: 5),

                            Text(
                              formatDate(activity["createdAt"]),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
