// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:split_money/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;

  const EditProfilePage({super.key, required this.name, required this.email});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  // late TextEditingController emailController;
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    //emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    //  emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 Greeting
            const Text(
              "Hello again!!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Let's edit your profile quickly",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // ✏️ Name
            const Text("Name", style: TextStyle(fontWeight: FontWeight.w500)),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(border: UnderlineInputBorder()),
            ),

            const SizedBox(height: 25),

            // 📧 Email (readonly)
            const Text(
              "Email Address",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: TextEditingController(text: widget.email),
              readOnly: true,
              decoration: const InputDecoration(border: UnderlineInputBorder()),
            ),

            const Spacer(),

            // 🔘 Finalize Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // 👉 Return updated name
                  final newName = nameController.text.trim();
                  if (newName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Name cannot be empty")),
                    );
                    return;
                  }
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString("name", newName);

                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );

                  await authProvider.updateName(newName); // 🔥 update provider

                  Navigator.pop(context, newName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Finalize", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
