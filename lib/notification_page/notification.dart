import 'package:flutter/material.dart';
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

    notificationWidgetsList.addAll([
      NotificationItem(),
      NotificationItem(),
      NotificationItem(),
      NotificationItem(),
    ]);
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
                    onPressed: () {},
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
