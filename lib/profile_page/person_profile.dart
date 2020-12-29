import 'dart:async';
import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpss_tercih/database.dart' as db;
import 'package:kpss_tercih/firestore.dart';
import 'package:kpss_tercih/profile_page/person_card_widget.dart';
import 'package:kpss_tercih/profile_page/slidable_item.dart';

class PersonProfle extends StatefulWidget {
  @override
  _PersonProfleState createState() => _PersonProfleState();
}

class _PersonProfleState extends State<PersonProfle> {
  double _profileWidgetWidth = 80;
  Map _postList = Map();
  List<dynamic> _followingList = List();
  List<dynamic> _followersList = List();
  ExpandableController _expandableController = ExpandableController();
  Future<dynamic> _userInfo;
  Color _headerColor = Colors.white;
  File _image;
  Image _profileImageWidget;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    db.getListFromDb('followers').then((value) {
      // List tempList = Utils.removeNulls(value);

      setState(() {
        if (value != null) _followersList = value;
      });
    });

    db.getListFromDb('followings').then((value) {
      // List tempList = Utils.removeNulls(value);
      setState(() {
        if (value != null) _followingList = value;
      });
    });

    db.getPostsMap().then((value) {
      setState(() {
        if (value != null) _postList = value;
      });
    });

    _userInfo = db.getUserInfo('displayName');
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

    getDownloadLink().then((value) {
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
                            children: [
                              _profileImageWidget == null
                                  ? Image(
                                      image: AssetImage('res/user.png'),
                                      width: _profileWidgetWidth,
                                    )
                                  : _profileImageWidget,
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
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  'this is a long description of person.This paragraph takes asdasdasdasdasddddlonger area asdasd ',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.92)),
                                ),
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
                            _postList.length.toString(),
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
                      children: _postList.values
                          .map((e) => SlidableItem(
                                header: e['author'],
                                content: e['content'],
                              ))
                          .toList()),
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
