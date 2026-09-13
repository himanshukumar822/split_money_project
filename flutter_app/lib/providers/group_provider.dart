import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_services.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];
  bool _isLoading = false;

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;

  final GroupServices _service = GroupServices();

  // ✅ FIXED: add userId
  Future<void> getGroups(String userId, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.fetchGroups(userId, token);

      print("Fetched groups: $data"); // ⭐ DEBUG

      _groups = data.map((g) => Group.fromJson(g)).toList();
    } catch (e) {
      print("ERROR FETCHING GROUPS: $e"); // ⭐ DEBUG
    } finally {
      _isLoading = false; // ⭐ VERY IMPORTANT
      notifyListeners();
    }
  }

  // ✅ FIXED: add userId + fix response
  Future<dynamic> addGroup(String name, String userId, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.createGroup(name, userId, token);

      // ⭐ FIXED (important)
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
