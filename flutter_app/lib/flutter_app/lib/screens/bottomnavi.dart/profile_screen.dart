import 'package:flutter/material.dart';
import 'package:split_money/screens/bottomnavi.dart/editprofile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:split_money/screens/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "user";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // 🔥 LOAD USER DATA FROM STORAGE
  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('name') ?? "user";
      email = prefs.getString('email') ?? "";
    });
  }

  // 🔥 SAVE UPDATED NAME
  Future<void> saveName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', newName);

    setState(() {
      name = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Account", style: TextStyle(color: Colors.black)),
      ),

      body: Column(
        children: [
          // 🔵 PROFILE SECTION
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),

                const SizedBox(width: 15),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(email, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ✏️ EDIT PROFILE
          _buildCard(
            icon: Icons.edit,
            title: "Edit Profile",
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

          // ⚙️ SETTINGS
          _buildCard(icon: Icons.settings, title: "Settings", onTap: () {}),

          // 🚪 LOGOUT
          _buildCard(
            icon: Icons.logout,
            title: "Logout",
            isLogout: true,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // 🔥 LOGOUT DIALOG
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("Logout"),
          content: const Text("Do you really want to logout?"),
          actions: [
            // ❌ CANCEL
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            // ✅ LOGOUT
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final prefs = await SharedPreferences.getInstance();

                // 🔥 CLEAR ALL DATA
                await prefs.clear();

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

  // 🔧 CARD WIDGET
  Widget _buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLogout ? Colors.red : const Color(0xFF4B3F72),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isLogout ? Colors.red : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
