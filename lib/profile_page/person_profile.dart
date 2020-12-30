import 'dart:async';
import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpss_tercih/firebase/database.dart' as db;
import 'package:kpss_tercih/firebase/firestore.dart';
import 'package:kpss_tercih/profile_page/person_card_widget.dart';
import 'package:kpss_tercih/profile_page/slidable_item.dart';

class PersonProfle extends StatefulWidget {
  @override
  _PersonProfleState createState() => _PersonProfleState();
}

class _PersonProfleState extends State<PersonProfle> {
  double _profileWidgetWidth = 80;

  List<dynamic> _followingList = List();
  List<dynamic> _followersList = List();
  List<SlidableItem> slidableItems = List();
  ExpandableController _expandableController = ExpandableController();
  Color _headerColor = Colors.white;
  File _image;
  Image _profileImageWidget;
  final picker = ImagePicker();
  TextEditingController textEditingController = TextEditingController();
  int postsAmount = 0;
  bool isEditingDescText = false;
  bool descEditIconVisible = true;
  Text descTextWidget;

  @override
  void initState() {
    super.initState();

    if (db.authUserID == null) Navigator.pushNamed(context, '/');

    descTextWidget = Text(
      'Description',
      style: TextStyle(color: Colors.white.withOpacity(0.92)),
    );

    db.getListFromDb('followers').then((value) {
      setState(() {
        if (value != null) _followersList = value;
      });
    });

    db.getListFromDb('followings').then((value) {
      setState(() {
        if (value != null) _followingList = value;
      });
    });

    db.getPostsMap(userID: db.authUserID).then((value) {
      if (value == null) return;
      value.entries.forEach((element) {
        slidableItems.add(SlidableItem(
          profileKey: element.value['authorId'],
          postKey: element.key,
          header: element.value['author'],
          content: element.value['content'],
        ));
      });

      List<SlidableItem> temp = List();
      temp.addAll(slidableItems);
      slidableItems = null;
      setState(() {
        postsAmount = value.length;
        slidableItems = temp;
      });
    });

    _expandableController.addListener(() {
      if (_expandableController.expanded)
        setState(() {
          _headerColor = Colors.amber;
        });
      else
        setState(() {
          _headerColor = Colors.white;
        });
    });

    _profileImageWidget = Image(
      image: AssetImage('res/user.png'),
      width: _profileWidgetWidth,
    );

    getDownloadLink().then((value) {
      if (this.mounted)
        setState(() {
          if (value != null)
            _profileImageWidget =
                Image.network(value, width: _profileWidgetWidth);
        });
    });

    _expandableController.expanded = true;
  }

  Future<bool> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {
        _profileImageWidget = Image.file(_image, width: _profileWidgetWidth);
      });
    }
    return pickedFile != null;
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null)
      Navigator.pushNamed(context, '/');

    return Container(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    ExpandablePanel(
                      controller: _expandableController,
                      header: Text(
                        db.displayName,
                        style: TextStyle(
                          color: _headerColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: 0.2,
                        ),
                      ),
                      theme: ExpandableThemeData(
                        headerAlignment: ExpandablePanelHeaderAlignment.center,
                        iconColor: _headerColor,
                      ),
                      expanded: Row(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _profileImageWidget,
                              GestureDetector(
                                onTap: () async {
                                  bool isSuccessfull = await getImage();
                                  if (isSuccessfull) {
                                    Reference ref = await searchReference();
                                    if (ref != null) await ref.delete();
                                    uploadFile(_image);
                                  }
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: isEditingDescText
                                            ? Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      FlatButton(
                                                          onPressed: () {},
                                                          child:
                                                              Text('yayinla')),
                                                      FlatButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              isEditingDescText =
                                                                  false;
                                                              descEditIconVisible =
                                                                  true;
                                                            });
                                                          },
                                                          child: Text('vazgec'))
                                                    ],
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.amber,
                                                          width: 1),
                                                    ),
                                                    child: EditableText(
                                                        controller:
                                                            textEditingController,
                                                        focusNode: FocusNode(),
                                                        style: TextStyle(),
                                                        cursorColor:
                                                            Colors.amber,
                                                        backgroundCursorColor:
                                                            Colors.transparent),
                                                  ),
                                                ],
                                              )
                                            : descTextWidget,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            textEditingController.text =
                                                descTextWidget.data;
                                            isEditingDescText = true;
                                            descEditIconVisible = false;
                                          });
                                        },
                                        child: Visibility(
                                          visible: descEditIconVisible,
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                FlatButton(
                                  onPressed: () {
                                    FirebaseAuth.instance.signOut();
                                  },
                                  child: Text('Log Out'),
                                  color: Colors.green,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
                child: DefaultTabController(
              length: 3,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: TabBar(
                  labelPadding: EdgeInsets.symmetric(vertical: 5),
                  indicator: BoxDecoration(color: Colors.transparent),
                  labelColor: Colors.amber,
                  unselectedLabelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Column(
                        children: [
                          Text(
                            postsAmount.toString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text('Posts', style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        children: [
                          Text(
                            _followersList.length.toString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text('Followers', style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        children: [
                          Text(
                            _followingList.length.toString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text('Following', style: TextStyle(fontSize: 16))
                        ],
                      ),
                    )
                  ],
                ),
                body: TabBarView(children: [
                  ListView(
                    children: slidableItems,
                  ),
                  ListView(
                    children: _followersList
                        .map((e) => PersonCard(personUid: e))
                        .toList(),
                  ),
                  ListView(
                    children: _followingList
                        .map((e) => PersonCard(personUid: e))
                        .toList(),
                  ),
                ]),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
