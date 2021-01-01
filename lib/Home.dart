import 'package:flutter/material.dart';
import 'package:kpss_tercih/profile.dart';
import 'package:kpss_tercih/profile_page/person_profile.dart';
import 'firebase/database.dart' as db;
import 'search_page/search_page.dart';
import 'notification_page/notification.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController a = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    db.initDisplayName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: getPage(),
        bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: 'Notifications'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
            currentIndex: _selectedIndex,
            elevation: 0,
            onTap: _onItemTapped,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            iconSize: 28,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black.withOpacity(0.91)));
  }

  Widget getPage() {
    if (_selectedIndex == 0)
      return Search();
    else if (_selectedIndex == 1)
      return NotificationPage();
    else if (_selectedIndex == 2)
      return Profile(isAuthProfile: false);
    // return PersonProfle();
    else
      return null;
  }

  void _onItemTapped(int value) {
    setState(() {
      _selectedIndex = value;
    });
  }
}
