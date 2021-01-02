import 'package:flutter/material.dart';
import 'package:kpss_tercih/firebase/database.dart' as db;
import 'package:kpss_tercih/notification_page/notification_item.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Widget> notificationWidgetsList = List();

  @override
  void initState() {
    super.initState();

    updateNotifications();
  }

  void updateNotifications() {
    db.fetchNotifications().then((notificationMap) {
      if (notificationMap == null) return;
      List<Widget> temp = List();

      DateTime nowDateTime = DateTime.now();
      notificationMap.forEach((key, notification) {
        NotificationType type;
        if (notification['type'] == NotificationType.post.toString())
          type = NotificationType.post;
        else if (notification['type'] == NotificationType.like.toString())
          type = NotificationType.like;
        else if (notification['type'] == NotificationType.followed.toString())
          type = NotificationType.followed;
        else if (notification['type'] == NotificationType.unfollowed.toString())
          type = NotificationType.unfollowed;

        DateTime dateTime = DateTime.parse(notification['date']);

        Duration diff = nowDateTime.difference(dateTime);

        String date = '';
        if (diff.inHours == 0)
          date = '${diff.inMinutes} dakika önce';
        else
          date = '${diff.inHours} saat önce';

        temp.add(NotificationItem(
          notificationID: key,
          type: type,
          date: date,
          message: notification['message'],
          removeItemFromList: removeNotification,
        ));
      });

      if (mounted)
        setState(() {
          notificationWidgetsList = temp;
        });
    });
  }

  void removeNotification(NotificationItem item) {
    List<Widget> temp = List();
    temp.addAll(notificationWidgetsList);

    temp.remove(item);

    setState(() {
      notificationWidgetsList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      color: Colors.grey[850],
      child: Column(
        children: [
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(left: 30),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ButtonTheme(
                highlightColor: Colors.white,
                hoverColor: Colors.white,
                focusColor: Colors.white,
                splashColor: Colors.white,
                disabledColor: Colors.white,
                child: FlatButton(
                    onPressed: () {
                      db.removeAllNotifications();
                      notificationWidgetsList = null;

                      setState(() {
                        notificationWidgetsList = List();
                      });
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(color: Colors.amber.withAlpha(160)),
                    )),
              )
            ],
          ),
          Expanded(
            child: ListView(
              children: notificationWidgetsList,
            ),
          )
        ],
      ),
    );
  }
}
