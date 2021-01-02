import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kpss_tercih/firebase/database.dart' as db;
import 'notification_page/notification_item.dart';

class PostWidget extends StatefulWidget {
  final String author;
  final String content;
  final String postKey;
  final String postOwnerId;
  final String authorId;
  final String date;
  final bool isAuthProfile;
  PostWidget({
    Key key,
    @required this.authorId,
    @required this.postOwnerId,
    @required this.postKey,
    @required this.author,
    @required this.date,
    @required this.content,
    @required this.isAuthProfile,
  }) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  int likeAmount = 0;
  String currentImagePath = '';

  @override
  void initState() {
    super.initState();

    updateCurrentImagePath();

    updateLikeAmountText();
  }

  void updateCurrentImagePath() {
    db.isPostLiked(widget.postKey, widget.postOwnerId).then((value) {
      setState(() {
        currentImagePath = value ? 'res/heart1.png' : 'res/heart2.png';
      });
    });
  }

  void updateLikeAmountText() {
    db.getLikeAmount(widget.postKey, widget.postOwnerId).then((value) {
      setState(() {
        likeAmount = value;
      });
    });
  }

  String getFormattedDate() {
    DateTime dateTime = DateTime.parse(widget.date);

    return '${dateTime.day}.${dateTime.month}.${dateTime.year}  ${dateTime.hour}:${dateTime.minute}';
  }

  like() async {
    bool isLiked = await db.isPostLiked(widget.postKey, widget.postOwnerId);

    if (isLiked) {
      await db.unLikePost(widget.postKey, widget.postOwnerId);
      String message = '${db.displayName} beğenisini kaldırdı';
      db.createNotification(NotificationType.like, widget.postOwnerId, message);
    } else {
      await db.likePost(widget.postKey, widget.postOwnerId);
      String message = '${db.displayName} bir gönderiyi beğendi';
      db.createNotification(NotificationType.like, widget.postOwnerId, message);
    }
    updateCurrentImagePath();
    updateLikeAmountText();
  }

  @override
  Widget build(BuildContext context) {
    return Slidable.builder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 30),
            child: Text(
              widget.content,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                getFormattedDate(),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Image.asset(
                    currentImagePath,
                    color: Colors.amber,
                    width: 10,
                  ),
                  SizedBox(width: 5),
                  Text(
                    likeAmount.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Text(
                widget.author,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      secondaryActionDelegate: SlideActionBuilderDelegate(
          actionCount: widget.isAuthProfile ? 1 : 2,
          builder: (context, index, animation, step) {
            if (index == 0)
              return RawMaterialButton(
                onPressed: () {},
                elevation: step == SlidableRenderingMode.slide
                    ? 6 * animation.value
                    : 6,
                fillColor: step == SlidableRenderingMode.slide
                    ? Colors.red.withOpacity(animation.value)
                    : Colors.red,
                child: Image.asset(
                  'res/share.png',
                  width: step == SlidableRenderingMode.slide
                      ? 50 * animation.value
                      : 50,
                ),
                padding: EdgeInsets.all(15.0),
                shape: CircleBorder(),
              );
            else if (index == 1 && !widget.isAuthProfile)
              return RawMaterialButton(
                onPressed: () {
                  like();
                },
                elevation: step == SlidableRenderingMode.slide
                    ? 6 * animation.value
                    : 6,
                fillColor: step == SlidableRenderingMode.slide
                    ? Colors.amber.withOpacity(animation.value)
                    : Colors.amber,
                child: Image.asset(
                  currentImagePath,
                  color: Colors.black,
                  width: step == SlidableRenderingMode.slide
                      ? 50 * animation.value
                      : 50,
                ),
                padding: EdgeInsets.all(15.0),
                shape: CircleBorder(),
              );
            else
              return Container();
          }),
    );
  }
}
