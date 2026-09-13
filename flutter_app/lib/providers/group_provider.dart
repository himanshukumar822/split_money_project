import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];

  bool _isLoading = false;

  List<Group> get groups => _groups;

  bool get isLoading => _isLoading;

  final GroupServices _service = GroupServices();

  Future<void> getGroups(
    String userId,
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load cached groups immediately
    final cachedGroups =
        prefs.getString('cached_groups_$userId');

    if (cachedGroups != null) {
      try {
        final List<dynamic> data =
            jsonDecode(cachedGroups);

        _groups = data
            .map(
              (g) => Group.fromJson(
                Map<String, dynamic>.from(g),
              ),
            )
            .toList();

        // Show cached groups immediately
        notifyListeners();
      } catch (e) {
        print("CACHE ERROR: $e");
      }
    }

    // 2. Fetch latest groups from backend
    _isLoading = cachedGroups == null;
    notifyListeners();

    try {
      final data =
          await _service.fetchGroups(userId, token);

      _groups = data
          .map((g) => Group.fromJson(g))
          .toList();

      // 3. Save latest groups to cache
      await prefs.setString(
        'cached_groups_$userId',
        jsonEncode(
          _groups.map((g) => g.toJson()).toList(),
        ),
      );
    } catch (e) {
      print("ERROR FETCHING GROUPS: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<dynamic> addGroup(
    String name,
    String userId,
    String token, {
    String groupType = "Home",
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.createGroup(
        name,
        userId,
        token,
        groupType: groupType,
      );

      final newGroup =
          Group.fromJson(data["group"]);

      _groups.add(newGroup);

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'cached_groups_$userId',
        jsonEncode(
          _groups.map((g) => g.toJson()).toList(),
        ),
      );

      _isLoading = false;
      notifyListeners();

      return data["group"];
    } catch (e) {
      print("ERROR CREATING GROUP: $e");

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }
}
