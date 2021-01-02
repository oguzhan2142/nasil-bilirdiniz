import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'notification_page/notification_item.dart';
import 'profile_page/post_choise_button.dart';
import 'package:kpss_tercih/firebase/database.dart' as db;

class EditablePostWidget extends StatelessWidget {
  TextStyle editTextStyle = TextStyle(fontSize: 14, color: Colors.amber[700]);
  TextEditingController editableController = TextEditingController();
  final String profileKey;
  final Function onCancel;
  final Function updatePostWidgets;
  final FocusNode focusNode = FocusNode();
  String userName;

  EditablePostWidget(
      {Key key, this.profileKey, this.onCancel, this.updatePostWidgets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ChoiseButton(
              onClick: () {
                db
                    .createPostOnSomeoneWall(
                  profileKey,
                  FirebaseAuth.instance.currentUser.uid,
                  editableController.text,
                )
                    .whenComplete(() {
                  String message =
                      '${db.displayName} duvarinda gonderi paylaştı';
                  db.createNotification(
                      NotificationType.post, profileKey, message);
                });
                onCancel();
                updatePostWidgets();
              },
              text: 'Yayınla',
              borderColor: Colors.green,
              textColor: Colors.green,
            ),
            SizedBox(width: 14),
            ChoiseButton(
              onClick: onCancel,
              text: 'Vazgeç',
              borderColor: Colors.red,
              textColor: Colors.red,
            )
          ],
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 30),
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.amber, width: 1)),
            child: EditableText(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: editableController,
                focusNode: focusNode,
                style: editTextStyle,
                cursorColor: Colors.amber,
                backgroundCursorColor: Colors.black),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FutureBuilder(
              future: db.getUserInfo('displayName'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
