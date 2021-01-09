import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kpss_tercih/profile.dart';
import 'notification_page/notification.dart';
import 'package:kpss_tercih/notifications.dart' as notifications;
import 'search_page/search_page.dart';
import 'package:kpss_tercih/firebase/database.dart' as db;

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

    handleNotifications();
  }

  void handleNotifications() async {
    notifications.init().whenComplete(() async {
      Map notificationMap = await db.fetchNotifications();
      if (notificationMap == null) return;
      List<String> not = List();
      notificationMap.forEach((key, value) {
        bool isPushed = value['isPushed'];

        if (!isPushed) {
          not.add(value['message']);
          db.setNotificationAsPushed(key);
        }
      });
      notifications.showGroupedNotifications(not);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: getPage(),
        bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Ara'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: 'Bildirimler'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profil'),
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
      return Profile(
        isAuthProfile: true,
        profileID: FirebaseAuth.instance.currentUser.uid,
      );
    else
      return null;
  }

  void _onItemTapped(int value) {
    setState(() {
      _selectedIndex = value;
    });
  }
}
