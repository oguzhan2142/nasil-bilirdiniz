import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PostWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Slidable.builder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 30),
            child: Text(
              'text ajndkas askjdaksd ajsndkasnd ajksdnakjsdnak asjndkandjansd aksjdaksndkajsd ajkndakdajdnakjnsdkansdakjnsdajkd',
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
                '01.01.2021',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Text(
                'username',
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
          actionCount: 1,
          builder: (context, index, animation, step) {
            return RawMaterialButton(
              onPressed: () {},
              elevation:
                  step == SlidableRenderingMode.slide ? 6 * animation.value : 6,
              fillColor: step == SlidableRenderingMode.slide
                  ? Colors.red.withOpacity(animation.value)
                  : Colors.red,
              child: Icon(
                Icons.share,
                size: step == SlidableRenderingMode.slide
                    ? 14 * animation.value
                    : 14,
              ),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            );
          }),
    );
  }
}
