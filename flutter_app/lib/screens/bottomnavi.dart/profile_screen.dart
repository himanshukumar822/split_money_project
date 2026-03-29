import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_money/providers/auth_provider.dart';
import 'package:split_money/screens/bottomnavi.dart/editprofile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:split_money/screens/login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text("Account", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          // 🔵 Top Profile Section
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
                      authProvider.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      authProvider.email ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🧩 Action Blocks
          _buildCard(
            icon: Icons.edit,
            title: "Edit Profile",
            onTap: () async {
              final updatedName = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(
                    name: authProvider.name,
                    email: authProvider.email ?? "",
                  ),
                ),
              );

              if (updatedName != null) {
                final authProvider = Provider.of<AuthProvider>(
                  // ignore: use_build_context_synchronously
                  context,
                  listen: false,
                );

                authProvider.updateName(updatedName);
              }
            },
          ),
          _buildCard(icon: Icons.settings, title: "Settings", onTap: () {}),
          _buildCard(
            icon: Icons.logout,
            title: "Logout",
            onTap: () {
              _showLogoutDialog(context);
            },
            isLogout: true,
          ),
        ],
      ),
    );
  }

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
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');

                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                ); // close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // close dialog first

                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );

                await authProvider.logout(context);
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

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
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
              ),
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
