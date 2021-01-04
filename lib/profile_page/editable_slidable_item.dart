import 'package:flutter/material.dart';
import 'package:kpss_tercih/firebase/database.dart' as db;
import 'package:kpss_tercih/firebase/firestore.dart';
import 'package:kpss_tercih/notification_page/notification_item.dart';
import 'package:kpss_tercih/profile_page/post_choise_button.dart';
import 'package:sprintf/sprintf.dart';
import 'package:kpss_tercih/notifications.dart' as notifications;

class EditableSlidableItem extends StatefulWidget {
  final String profileKey;
  final Function onCancel;
  final Function updatePostWidgets;
  final FocusNode focusNode = FocusNode();

  EditableSlidableItem(
      {Key key, this.updatePostWidgets, this.onCancel, this.profileKey})
      : super(key: key);

  @override
  _EditableSlidableItemState createState() => _EditableSlidableItemState();
}

class _EditableSlidableItemState extends State<EditableSlidableItem> {
  Image _imageWidget;
  TextStyle editTextStyle = TextStyle(fontSize: 14, color: Colors.amber[700]);
  TextEditingController editableController = TextEditingController();
  String username = '';

  @override
  void initState() {
    super.initState();
    _imageWidget = Image(
      image: AssetImage('res/user.png'),
      width: 40,
      color: Colors.white,
    );

    getDownloadLink(uid: widget.profileKey).then((value) => setState(() {
          if (value != null) _imageWidget = Image.network(value, width: 40);
        }));
    editableController.buildTextSpan(withComposing: true);
    db.getUserInfo('username').then((value) {
      setState(() {
        username = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      color: Colors.black.withAlpha(40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(90),
                    child: _imageWidget,
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            children: [
                              Text(
                                username,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.amber),
                              ),
                              SizedBox(width: 20),
                              ChoiseButton(
                                onClick: () {
                                  db
                                      .createPostOnSomeoneWall(
                                          widget.profileKey,
                                          editableController.text)
                                      .whenComplete(() {
                                    db.createNotification(
                                      NotificationType.post,
                                      widget.profileKey,
                                      sprintf(notifications.posted, username),
                                    );
                                  });
                                  widget.onCancel();
                                  widget.updatePostWidgets();
                                },
                                text: 'Yayınla',
                                borderColor: Colors.green,
                                textColor: Colors.green,
                              ),
                              SizedBox(width: 5),
                              ChoiseButton(
                                onClick: widget.onCancel,
                                text: 'Vazgeç',
                                borderColor: Colors.red,
                                textColor: Colors.red,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.amber, width: 1)),
                            child: EditableText(
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                controller: editableController,
                                focusNode: widget.focusNode,
                                style: editTextStyle,
                                cursorColor: Colors.amber,
                                backgroundCursorColor: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.amber, height: 50, thickness: 0.8),
        ],
      ),
    );
  }
}
