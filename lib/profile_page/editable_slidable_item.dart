import 'package:flutter/material.dart';
import 'package:kpss_tercih/firebase/database.dart' as db;
import 'package:kpss_tercih/firebase/firestore.dart';
import 'package:kpss_tercih/notification_page/notification_item.dart';

class EditableSlidableItem extends StatefulWidget {
  final String profileKey;
  Function onCancel;
  Function updatePostWidgets;
  FocusNode focusNode = FocusNode();

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
                                db.displayName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.amber),
                              ),
                              SizedBox(width: 20),
                              FlatButton(
                                onPressed: () {
                                  db
                                      .createPostOnSomeoneWall(
                                    widget.profileKey,
                                    db.authUserID,
                                    editableController.text,
                                  ).whenComplete(() {
                                    String message =
                                        '${db.displayName} duvarinda gonderi paylaştı';
                                    db.createNotification(NotificationType.post,
                                        widget.profileKey, message);
                                  });
                                  widget.onCancel();
                                  widget.updatePostWidgets();
                                },
                                splashColor: Colors.amber,
                                child: Text('Yayınla',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 13,
                                    )),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: BorderSide(color: Colors.green),
                                ),
                              ),
                              SizedBox(width: 5),
                              FlatButton(
                                onPressed: widget.onCancel,
                                child: Text('Vazgeç',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    )),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: BorderSide(color: Colors.red),
                                ),
                              ),
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
        ],
      ),
    );
  }
}
