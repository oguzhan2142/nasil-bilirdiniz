import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kpss_tercih/firebase/database.dart';
import 'package:kpss_tercih/firebase/firestore.dart';

class PersonCard extends StatefulWidget {
  final String personUid;

  PersonCard({Key key, this.personUid}) : super(key: key);

  @override
  _PersonCardState createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  Future _userNameFuture;
  Future _imageDownloadLink;

  @override
  void initState() {
    super.initState();

    _userNameFuture = getUserInfo('username', userId: widget.personUid);
    _imageDownloadLink = getDownloadLink(uid: widget.personUid);
  }

  @override
  Widget build(BuildContext context) {
    return Slidable.builder(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        elevation: 20,
        color: Colors.grey[100],
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
                        child: FutureBuilder(
                          future: _imageDownloadLink,
                          builder: (context, snapshot) {
                            if (snapshot.hasData)
                              return Image.network(snapshot.data, width: 40);
                            else
                              return Image.asset('res/user.png', width: 40);
                          },
                        )),
                  ),
                  Expanded(
                    child: Container(
                      // color: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                        child: FutureBuilder(
                          future: _userNameFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                    ),
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
                  ? 20 * animation.value
                  : 20,
              fillColor: step == SlidableRenderingMode.slide
                  ? Colors.red.withOpacity(animation.value)
                  : Colors.red,
              child: Icon(
                Icons.share,
                size: step == SlidableRenderingMode.slide
                    ? 36 * animation.value
                    : 36,
              ),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            );
          }),
    );
  }
}
