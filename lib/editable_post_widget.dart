import 'package:flutter/material.dart';
import 'package:kpss_tercih/profile.dart';

import 'notification_page/notification_item.dart';
import 'profile_page/post_choise_button.dart';
import 'package:kpss_tercih/firebase/database.dart' as db;

class EditablePostWidget extends StatelessWidget {
  final TextStyle editTextStyle =
      TextStyle(fontSize: 14, color: Colors.amber[700]);
  final TextEditingController editableController = TextEditingController();
  final String profileKey;
  final Function onCancel;
  final bool isUpdateVersion;
  final Function updatePostWidgets;
  final FocusNode focusNode = FocusNode();

  EditablePostWidget(
      {Key key,
      this.profileKey,
      this.onCancel,
      this.updatePostWidgets,
      @required this.isUpdateVersion})
      : super(key: key);

  void setText(String text) {
    editableController.text = text;
  }

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
                if (!isUpdateVersion)
                  createPost();
                else
                  updatePost();
              },
              text: isUpdateVersion ? 'Güncelle' : 'Yayınla',
              borderColor: Colors.green,
              textColor: Colors.green,
            ),
            isUpdateVersion ? SizedBox(width: 6) : Container(),
            isUpdateVersion
                ? ChoiseButton(
                    onClick: deletePost,
                    text: 'Sil',
                    borderColor: Colors.red,
                    textColor: Colors.red,
                  )
                : Container(),
            SizedBox(width: 6),
            ChoiseButton(
              onClick: onCancel,
              text: 'Vazgeç',
              borderColor: Colors.amber,
              textColor: Colors.amber,
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
              future: db.getUserInfo('username'),
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
        Divider(color: Colors.amber, height: 50, thickness: 0.8),
      ],
    );
  }

  Future createPost() async {
    db
        .createPostOnSomeoneWall(profileKey, editableController.text)
        .whenComplete(() async {
      String username = await db.getUserInfo('username');
      String message = '$username duvarinda gonderi paylaştı';
      db.createNotification(NotificationType.post, profileKey, message);
      updatePostWidgets();
      // onCancel();
    });
  }

  Future updatePost() async {
    db.updatePost(profileKey, editableController.text).whenComplete(() async {
      String username = await db.getUserInfo('username');
      String message = '$username duvarinda gonderisini güncelledi';
      db.createNotification(NotificationType.post, profileKey, message);
      updatePostWidgets();
      // onCancel();
    });
  }

  deletePost() async {
    db.deletePost(profileKey);
    String username = await db.getUserInfo('username');
    String message = '$username duvarinda gonderisini güncelledi';
    await db.createNotification(NotificationType.post, profileKey, message);

    updatePostWidgets();
    // onCancel();
  }
}
