import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

enum NotificationType { like, followed, post }

class NotificationItem extends StatelessWidget {
  final NotificationType type;

  NotificationItem({Key key, this.type}) : super(key: key);

  Image createIcon(NotificationType type) {
    Image image;
    if (type == NotificationType.like)
      image = Image.asset('res/like.png');
    else if (type == NotificationType.post)
      image = Image.asset('res/new_post.png');

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
              Image.asset(
                'res/like.png',
                width: 24,
                color: Colors.white70,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'user 1 liked user 2',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('1 saat once',
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
