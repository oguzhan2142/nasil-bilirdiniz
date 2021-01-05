import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final removeLiked = '%s beğenisini kaldırdı';
final liked = '%s bir gönderiyi beğendi';
final updatedPost = '%s duvarinda gonderisini güncelledi';
final followed = '%s takip etti';
final unfollowed = '%s takipten çıktı';
final posted = '%s duvarinda gonderi paylaştı';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> init() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
}

Future<void> showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, 'plain title', 'plain body', platformChannelSpecifics,
      payload: 'item x');
}

Future selectNotification(String payload) async {
  if (payload != null) {}
}

Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  // display a dialog with the notification details, tap ok to go to another page
}

Future<void> showGroupedNotifications(List<String> notifications) async {
  const String groupKey = 'com.android.example.WORK_EMAIL';
  const String groupChannelId = 'grouped channel id';
  const String groupChannelName = 'grouped channel name';
  const String groupChannelDescription = 'grouped channel description';
  // example based on https://developer.android.com/training/notify-user/group.html
  const AndroidNotificationDetails notificationAndroidSpecifics =
      AndroidNotificationDetails(
    groupChannelId,
    groupChannelName,
    groupChannelDescription,
    importance: Importance.max,
    priority: Priority.high,
    groupKey: groupKey,
  );
  const NotificationDetails notificationPlatformSpecifics =
      NotificationDetails(android: notificationAndroidSpecifics);

  for (int i = 0; i < notifications.length; i++) {
    await flutterLocalNotificationsPlugin.show(
      (i + 1),
      'Nasil Bilirdiniz?',
      notifications[i],
      notificationPlatformSpecifics,
    );

  }
  // Create the summary notification to support older devices that pre-date
  /// Android 7.0 (API level 24).
  ///
  /// Recommended to create this regardless as the behaviour may vary as
  /// mentioned in https://developer.android.com/training/notify-user/group

  
 
  
  
}
