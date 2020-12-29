import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

enum NotificationType { like, followed, unfollowed, post }

class NotificationItem extends StatelessWidget {
  final NotificationType type;
  final String message;
  final String date;

  NotificationItem({Key key, this.type, this.message, this.date})
      : super(key: key);

  Image createIcon(NotificationType type) {
    Image image;
    if (type == NotificationType.like)
      image = Image.asset('res/like.png', width: 24, color: Colors.white70);
    else if (type == NotificationType.post)
      image = Image.asset('res/new_post.png', width: 24, color: Colors.white70);
    else if (type == NotificationType.followed)
      image = Image.asset('res/follow.png', width: 24, color: Colors.white70);
    else if (type == NotificationType.followed)
      image = Image.asset('res/unfollow.png', width: 24, color: Colors.white70);

    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Slidable.builder(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 5),
        color: Colors.black.withAlpha(40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              createIcon(type),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(date,
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      secondaryActionDelegate: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, index, animation, step) {
            return RawMaterialButton(
              onPressed: () {},
              elevation: step == SlidableRenderingMode.slide
                  ? 10 * animation.value
                  : 10,
              fillColor: step == SlidableRenderingMode.slide
                  ? Colors.red.withOpacity(animation.value)
                  : Colors.red,
              child: Icon(
                Icons.delete,
                size: step == SlidableRenderingMode.slide
                    ? 20 * animation.value
                    : 20,
              ),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            );
          }),
    );
  }
}
