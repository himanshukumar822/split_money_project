// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:split_money/screens/login_screen.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ✅ VARIABLES
  String? _userId;
  String? _token;
  String? _name;
  String? _email;

  // ✅ GETTERS
  String get userId => _userId ?? "";
  String get token => _token ?? "";

  // 🔥 IMPORTANT (ADD THIS)
  String get userName => _name ?? "User";

  String get name => _name ?? "User";
  String? get email => _email;

  // 🔥 LOGIN
  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);

      print("Login Response: $response");

      if (response["token"] != null && response["user"] != null) {
        final prefs = await SharedPreferences.getInstance();

        final user = response["user"];

        // ✅ STORE DATA
        _userId = user["_id"];
        _name = user["name"];
        _email = user["email"];
        _token = response["token"];

        // 💾 SAVE LOCALLY
        await prefs.setString("userId", _userId!);
        await prefs.setString("token", _token!);
        await prefs.setString("email", _email!);
        await prefs.setString("name", _name!);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Login Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 SIGNUP
  Future<Map<String, dynamic>?> signup(
    String name,
    String email,
    String password,
    BuildContext context,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.signup(name, email, password);

      print("Signup Response: $response");

      if (response["message"] == "User created successfully") {
        final prefs = await SharedPreferences.getInstance();

        _name = name;
        _email = email;

        await prefs.setString("name", name);
        await prefs.setString("email", email);

        return {"name": name, "email": email};
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response["message"])));
        return null;
      }
    } catch (e) {
      print("Signup Error: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 LOAD USER
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    _userId = prefs.getString("userId");
    _token = prefs.getString("token");
    _email = prefs.getString("email");
    _name = prefs.getString("name") ?? "User";

    notifyListeners();
  }

  // 🔥 LOGOUT
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _userId = null;
    _token = null;
    _name = null;
    _email = null;

    notifyListeners();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // 🔥 UPDATE NAME
  Future<void> updateName(String newName) async {
    _name = newName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", newName);

    notifyListeners();
  }
}
