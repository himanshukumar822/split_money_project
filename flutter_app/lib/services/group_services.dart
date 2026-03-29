import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupServices {
  final String baseurl = "http://172.19.15.238:5000/api";

  // ✅ GET GROUPS
  Future<List<dynamic>> fetchGroups(String token) async {
    final response = await http.get(
      Uri.parse("$baseurl/groups"), // 🔥 FIXED
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load groups");
    }
  }

  // ✅ ADD THIS FUNCTION
  Future<Map<String, dynamic>> createGroup(String name, String token) async {
    final response = await http.post(
      Uri.parse("$baseurl/groups"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"name": name}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to create group");
    }
  }
}
