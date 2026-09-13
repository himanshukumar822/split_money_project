import 'package:flutter/material.dart';

import '../models/group_model.dart';
import '../services/group_services.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];
  bool _isLoading = false;

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;

  final GroupServices _service = GroupServices();

  // ============================================================
  // GET GROUPS
  // ============================================================
  void removeGroup(String groupId) {
    _groups.removeWhere((group) => group.id == groupId);
    notifyListeners();
  }

  Future<void> getGroups(
    String userId,
    String token, {
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final data = await _service.fetchGroups(userId, token);

      print("Fetched groups: $data");

      _groups = data.map((g) => Group.fromJson(g)).toList();
    } catch (e) {
      print("ERROR FETCHING GROUPS: $e");
    } finally {
      if (showLoading) {
        _isLoading = false;
        notifyListeners();
      } else {
        // Still update the UI with the new group list
        notifyListeners();
      }
    }
  }

  // ============================================================
  // ADD GROUP
  // ============================================================

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

      final newGroup = Group.fromJson(data["group"]);

      _groups.add(newGroup);

      _isLoading = false;
      notifyListeners();

      return data["group"];
    } catch (e) {
      print(e);

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }
}
