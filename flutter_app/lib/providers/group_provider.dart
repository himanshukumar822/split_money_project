import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_services.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];
  bool _isLoading = false;

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;

  final GroupServices _service = GroupServices();

  Future<void> getGroups(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.fetchGroups(token);
      _groups = data.map((g) => Group.fromJson(g)).toList();
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addGroup(String name, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.createGroup(name, token);

      // Convert response to Group model
      final newGroup = Group.fromJson(data);

      // Add to local list (important for UI update)
      _groups.add(newGroup);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      print(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
