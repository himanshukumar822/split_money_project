import 'dart:convert';

import 'package:http/http.dart' as http;

class GroupServices {
  final String baseurl = "https://split-money-backend.onrender.com/api";

  // GET GROUPS
  Future<List<dynamic>> fetchGroups(String userId, String token) async {
    final url = Uri.parse("$baseurl/groups/$userId");

    print("CALLING: $url");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RAW RESPONSE: ${response.body}");

    if (response.body.startsWith("<!DOCTYPE html>")) {
      throw Exception("Wrong API URL or backend route not found");
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["groups"];
    } else {
      throw Exception("Failed to load groups");
    }
  }

  // CREATE GROUP
  Future<Map<String, dynamic>> createGroup(
    String name,
    String userId,
    String token, {
    String groupType = "Home",
  }) async {
    print("SENDING GROUP TYPE: $groupType");

    final response = await http.post(
      Uri.parse("$baseurl/groups/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "members": [userId],
        "createdBy": userId,
        "groupType": groupType,
      }),
    );

    print("Status Code: ${response.statusCode}");
    print("Create Group Response: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create group");
    }
  }

  // MOVE GROUP TO BACKUP
  Future<void> archiveGroup(String groupId, String token) async {
    final url = Uri.parse("$baseurl/groups/$groupId/archive");

    print("ARCHIVE URL: $url");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("ARCHIVE STATUS: ${response.statusCode}");
    print("ARCHIVE RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Archive failed: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // GET BACKUP GROUPS
  Future<List<dynamic>> getArchivedGroups(String userId, String token) async {
    final response = await http.get(
      Uri.parse("$baseurl/groups/$userId/backup"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("Backup Status: ${response.statusCode}");
    print("Backup Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["groups"] ?? [];
    } else {
      throw Exception("Failed to load Backup groups");
    }
  }

  // RESTORE GROUP FROM BACKUP
  Future<void> restoreGroup(String groupId, String token) async {
    final response = await http.post(
      Uri.parse("$baseurl/groups/$groupId/restore"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("Restore Status: ${response.statusCode}");
    print("Restore Response: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to restore group");
    }
  }
}
