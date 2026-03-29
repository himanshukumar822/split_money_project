import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final permission = await FlutterContacts.requestPermission(readonly: true);

    if (permission) {
      final fetchedContacts = await FlutterContacts.getContacts(
        withProperties: true,
      );

      setState(() {
        contacts = fetchedContacts;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Friend")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
          ? const Center(child: Text("No contacts found"))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final name = contact.displayName;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?"),
                  ),

                  title: Text(name.isNotEmpty ? name : "No Name"),

                  subtitle: Text(
                    contact.phones.isNotEmpty
                        ? contact.phones.first.number
                        : "No number",
                  ),

                  onTap: () {
                    Navigator.pop(context, contact);
                  },
                );
              },
            ),
    );
  }
}
