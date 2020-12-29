import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kpss_tercih/database.dart';
import 'package:kpss_tercih/firestore.dart';

class SlidableItem extends StatefulWidget {
  final String header;
  final String content;
  final String postKey;
  final String profileKey;
  final String authorId;

  SlidableItem(
      {Key key,
      this.authorId,
      this.profileKey,
      this.postKey,
      this.header,
      this.content})
      : super(key: key);

  @override
  _SlidableItemState createState() => _SlidableItemState();
}

class _SlidableItemState extends State<SlidableItem> {
  final likedImage =
      Image.asset('res/heart1.png', width: 20, color: Colors.amber);
  final unlikedImage =
      Image.asset('res/heart2.png', width: 20, color: Colors.amber);
  Image _currentimage;

  int _likeAmount;
  Image _imageWidget;
  @override
  void initState() {
    super.initState();

    _imageWidget = Image(
      image: AssetImage('res/user.png'),
      width: 40,
    );

    getDownloadLink(uid: widget.authorId).then((value) => setState(() {
          if (value != null) _imageWidget = Image.network(value, width: 40);
        }));

    isPostLiked(widget.postKey, widget.profileKey).then((isLiked) {
      updateLikedImage(isLiked);
    });

    updateLikeAmountText();
  }

  void updateLikeAmountText() {
    getLikeAmount(widget.postKey, widget.profileKey).then((value) {
      setState(() {
        _likeAmount = value;
      });
    });
  }

  void updateLikedImage(bool isLiked) {
    if (isLiked)
      setState(() {
        _currentimage = likedImage;
      });
    else
      setState(() {
        _currentimage = unlikedImage;
      });
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
                            Text(
                              widget.header,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.amber),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.content,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.amber[700]),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(_likeAmount.toString(),
                          style: TextStyle(color: Colors.amber, fontSize: 12)),
                      GestureDetector(
                        onTap: () async {
                          bool isLiked = await isPostLiked(
                              widget.postKey, widget.profileKey);

                          if (isLiked) {
                            await unLikePost(widget.postKey, widget.profileKey);
                          } else {
                            await likePost(widget.postKey, widget.profileKey);
                          }

                          var liked = await isPostLiked(
                              widget.postKey, widget.profileKey);
                          updateLikedImage(liked);
                          updateLikeAmountText();
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: _currentimage),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
                Icons.share,
                size: step == SlidableRenderingMode.slide
                    ? 30 * animation.value
                    : 30,
              ),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            );
          }),
    );
  }
}
