import 'package:flutter/material.dart';
import 'group_screen.dart';
import 'package:split_money/screens/bottomnavi.dart/activity_screen.dart';
//import 'package:split_money/screens/bottomnavi.dart/activity_screen.dart';
import 'package:split_money/screens/bottomnavi.dart/friends_screen.dart';
import 'package:split_money/screens/bottomnavi.dart/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens; // 🔥 declare only

  @override
  void initState() {
    super.initState();

    _screens = [
      const GroupsScreen(),
      const FriendsScreen(),
      const ActivityScreen(),
      const ProfilePage(),
    ];
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTap,
          type: BottomNavigationBarType.fixed, // 🔥 IMPORTANT (for 4 tabs)
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.group), label: "Groups"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: "Activity",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
