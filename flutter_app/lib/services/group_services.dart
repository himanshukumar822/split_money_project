import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupServices {
  final String baseurl = "http://172.18.5.69:5000/api";

  // ✅ GET GROUPS (FIXED)
  Future<List<dynamic>> fetchGroups(String userId, String token) async {
    final url = Uri.parse("$baseurl/groups/$userId");
    print("✅ CALLING: $url");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RAW RESPONSE: ${response.body}");

    // 🔥 CHECK BEFORE DECODING
    if (response.body.startsWith("<!DOCTYPE html>")) {
      throw Exception("❌ Wrong API URL or backend route not found");
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["groups"];
    } else {
      throw Exception("Failed to load groups");
    }
  }

  // ✅ CREATE GROUP (FIXED)
  Future<Map<String, dynamic>> createGroup(
    String name,
    String userId,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse("$baseurl/groups"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ok even if unused
      },
      body: jsonEncode({
        "name": name,
        "members": [userId], // ⭐ REQUIRED
        // "createdBy": userId, // ⭐ REQUIRED
      }),
    );

    print("Create Group Response: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create group");
    }
  }
}
