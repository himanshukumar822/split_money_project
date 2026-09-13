import 'package:flutter/material.dart';
import 'package:split_money/screens/bottomnavi.dart/editprofile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:split_money/screens/login_screen.dart';
import 'package:split_money/providers/auth_provider.dart';
import 'package:split_money/providers/group_provider.dart';
import 'package:split_money/services/group_services.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "user";
  String email = "";

  final GroupServices _groupServices = GroupServices();

  List<Map<String, dynamic>> backupGroups = [];

  bool isLoadingBackup = false;
  bool isBackupOpening = false;

  String? restoringGroupId;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // ============================================================
  // USER DATA
  // ============================================================

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      name = prefs.getString('name') ?? "user";
      email = prefs.getString('email') ?? "";
    });
  }

  Future<void> saveName(String newName) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', newName);

    if (!mounted) return;

    setState(() {
      name = newName;
    });
  }

  // ============================================================
  // LOAD BACKUP
  // ============================================================

  Future<void> _loadBackupGroups() async {
    if (isLoadingBackup) return;

    setState(() {
      isLoadingBackup = true;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final groups = await _groupServices.getArchivedGroups(
        auth.userId,
        auth.token,
      );

      final convertedGroups = groups
          .map<Map<String, dynamic>>(
            (group) => Map<String, dynamic>.from(group),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        backupGroups = convertedGroups;
        isLoadingBackup = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingBackup = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load Backup: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // OPEN BACKUP
  // ============================================================

  Future<void> _openBackup() async {
    if (isBackupOpening) return;

    setState(() {
      isBackupOpening = true;
    });

    await _loadBackupGroups();

    if (!mounted) return;

    setState(() {
      isBackupOpening = false;
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            return _buildBackupSheet(sheetSetState);
          },
        );
      },
    );
  }

  // ============================================================
  // RESTORE GROUP
  // ============================================================

  Future<void> _restoreGroup(
    Map<String, dynamic> group,
    StateSetter sheetSetState,
  ) async {
    final groupId = group["_id"]?.toString() ?? group["id"]?.toString();

    final groupName = group["name"]?.toString() ?? "Group";

    if (groupId == null || groupId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Group ID is missing")));
      return;
    }

    if (restoringGroupId != null) return;

    // Immediately show loading on the clicked Restore button
    sheetSetState(() {
      restoringGroupId = groupId;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      print("RESTORING GROUP: $groupId");

      await _groupServices.restoreGroup(groupId, auth.token);

      // ========================================================
      // IMMEDIATELY REMOVE FROM BACKUP UI
      // ========================================================

      sheetSetState(() {
        backupGroups.removeWhere(
          (item) =>
              (item["_id"]?.toString() ?? item["id"]?.toString()) == groupId,
        );

        restoringGroupId = null;
      });

      // ========================================================
      // REFRESH NORMAL GROUPS SILENTLY
      // ========================================================

      await Provider.of<GroupProvider>(
        context,
        listen: false,
      ).getGroups(auth.userId, auth.token, showLoading: false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$groupName" restored successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print("RESTORE ERROR: $e");

      sheetSetState(() {
        restoringGroupId = null;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to restore group: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BACKUP SHEET
  // ============================================================

  Widget _buildBackupSheet(StateSetter sheetSetState) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: Color(0xFF0D0F18),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // HANDLE
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 22),

            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF3F4A8A)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.30),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.backup_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Backup",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Your archived groups",
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  // LIVE COUNT
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      "${backupGroups.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Expanded(
              child: isLoadingBackup
                  ? const Center(child: CircularProgressIndicator())
                  : backupGroups.isEmpty
                  ? _buildEmptyBackup()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 5, 18, 30),
                      itemCount: backupGroups.length,
                      itemBuilder: (context, index) {
                        final group = backupGroups[index];

                        return _buildBackupGroupCard(group, sheetSetState);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY BACKUP
  // ============================================================

  Widget _buildEmptyBackup() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withOpacity(0.10),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.25),
                ),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 42,
                color: Color(0xFF8B85FF),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Backup is empty",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Groups you move to Backup\nwill appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BACKUP GROUP CARD
  // ============================================================

  Widget _buildBackupGroupCard(
    Map<String, dynamic> group,
    StateSetter sheetSetState,
  ) {
    final groupName = group["name"]?.toString() ?? "Unnamed Group";

    final groupType = group["groupType"]?.toString() ?? "Others";

    final groupId = group["_id"]?.toString() ?? group["id"]?.toString() ?? "";

    final isRestoring = restoringGroupId == groupId;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.09),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3F4A8A)],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              _getGroupIcon(groupType),
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      size: 14,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      groupType,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // RESTORE
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: isRestoring
                  ? null
                  : () {
                      _restoreGroup(group, sheetSetState);
                    },
              child: Container(
                width: 88,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.30),
                  ),
                ),
                child: isRestoring
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF9B95FF),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restore_rounded,
                            color: Color(0xFF9B95FF),
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Restore",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GROUP ICON
  // ============================================================

  IconData _getGroupIcon(String groupType) {
    switch (groupType) {
      case "Home":
        return Icons.home_rounded;
      case "Trip":
        return Icons.luggage_rounded;
      case "Couple":
        return Icons.favorite_rounded;
      case "Personal":
        return Icons.person_rounded;
      case "Business":
        return Icons.work_rounded;
      case "Office":
        return Icons.apartment_rounded;
      case "Sports":
        return Icons.sports_tennis_rounded;
      case "Others":
        return Icons.groups_rounded;
      default:
        return Icons.groups_rounded;
    }
  }

  // ============================================================
  // MAIN PROFILE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Account",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // PROFILE HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5A67D8), Color(0xFF3F4A8A)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4B3F72).withOpacity(0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.14),
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // EDIT PROFILE
            _buildCard(
              icon: Icons.edit_rounded,
              title: "Edit Profile",
              subtitle: "Update your personal information",
              onTap: () async {
                final updatedName = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(name: name, email: email),
                  ),
                );

                if (updatedName != null) {
                  await saveName(updatedName);
                }
              },
            ),

            // BACKUP
            _buildCard(
              icon: Icons.backup_rounded,
              title: "Backup",
              subtitle: "Restore your archived groups",
              onTap: isBackupOpening ? () {} : _openBackup,
              trailing: isBackupOpening
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),

            // SETTINGS
            _buildCard(
              icon: Icons.settings_rounded,
              title: "Settings",
              subtitle: "Manage your preferences",
              onTap: () {},
            ),

            // LOGOUT
            _buildCard(
              icon: Icons.logout_rounded,
              title: "Logout",
              subtitle: "Sign out of your account",
              isLogout: true,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),

            const SizedBox(height: 25),

            const Text(
              "Split Money",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Manage money. Simplify life.",
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isLogout = false,
  }) {
    final iconColor = isLogout ? Colors.red : const Color(0xFF4B3F72);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.035)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          color: isLogout ? Colors.red : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                trailing ??
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text("Logout"),
          content: const Text("Do you really want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final prefs = await SharedPreferences.getInstance();

                await prefs.clear();

                if (!context.mounted) return;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
