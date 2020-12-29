import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:kpss_tercih/database.dart' as db;
import 'package:kpss_tercih/firestore.dart';
import 'package:kpss_tercih/profile_page/editable_slidable_item.dart';
import 'package:kpss_tercih/profile_page/person_card_widget.dart';
import 'package:kpss_tercih/profile_page/slidable_item.dart';

class DeauthProfile extends StatefulWidget {
  Map _postsMap = Map();
  String profileKey;
  Map profileData;

  DeauthProfile({Key key, this.profileKey, this.profileData}) : super(key: key);

  @override
  _DeauthProfileState createState() => _DeauthProfileState();
}

class _DeauthProfileState extends State<DeauthProfile> {
  List<dynamic> _followingList = List();
  List<dynamic> _followersList = List();
  ExpandableController _expandableController = ExpandableController();
  Color _headerColor = Colors.white;
  bool _isFollowingThisUser = true;
  List<Widget> postsWidgets = List();
  Image _profileImageWidget;
  EditableSlidableItem editableSlidableItem;
  bool floatingActionVisible = true;

  @override
  void initState() {
    super.initState();

    if (widget.profileData['posts'] != null)
      widget._postsMap = widget.profileData['posts'];
    List _followers = mapToList(widget.profileData['followers']);
    if (_followers != null) _followersList = _followers;

    List followings = mapToList(widget.profileData['followings']);
    if (followings != null) _followingList = followings;

    _expandableController.expanded = true;

    _profileImageWidget = Image.asset(
      'res/user.png',
      width: 80,
    );
    getDownloadLink(uid: widget.profileKey).then((value) => setState(() {
          if (value != null)
            _profileImageWidget = Image.network(value, width: 80);
        }));

    checkFollowing();

    updatePostWidgetsList();

    editableSlidableItem = EditableSlidableItem(
      profileKey: widget.profileKey,
      updatePostWidgets: updatePostWidgetsList,
      onCancel: () {
        List<Widget> temp = List();
        temp.addAll(postsWidgets);
        temp.remove(editableSlidableItem);

        setState(() {
          postsWidgets = temp;
          floatingActionVisible = true;
        });
      },
    );
  }

  void updatePostWidgetsList() async {
    List<Widget> widgets = List();

    Map postMap = await db.getPostsMap(userID: widget.profileKey);

    postMap.entries.forEach((element) {
      widgets.add(SlidableItem(
        profileKey: widget.profileKey,
        postKey: element.key,
        header: element.value['author'],
        content: element.value['content'],
      ));
    });

    setState(() {
      postsWidgets = widgets;
    });
  }

  void checkFollowing() async {
    db.isFollowing(widget.profileKey).then((isFollowing) {
      setState(() {
        _isFollowingThisUser = isFollowing;
      });
    });
  }

  List<dynamic> mapToList(Map map) {
    List<dynamic> list = List();
    if (map == null) return null;
    map.forEach((key, value) {
      list.add(value);
    });
    return list;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      backgroundColor: Colors.grey[850],
      floatingActionButton: Visibility(
        visible: floatingActionVisible,
        child: FloatingActionButton(
          onPressed: () {
            _expandableController.expanded = false;
            List<Widget> temp = List();
            temp.addAll(postsWidgets);
            temp.add(editableSlidableItem);

            setState(() {
              postsWidgets = temp;
              floatingActionVisible = false;
            });
            editableSlidableItem.focusNode.requestFocus();
          },
          child: Icon(
            Icons.add,
            color: Colors.amber,
          ),
          backgroundColor: Colors.black.withAlpha(120),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      ExpandablePanel(
                        controller: _expandableController,
                        header: Text(
                          widget.profileData['displayName'],
                          style: TextStyle(
                            color: _headerColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            letterSpacing: 0.2,
                          ),
                        ),
                        theme: ExpandableThemeData(
                          headerAlignment:
                              ExpandablePanelHeaderAlignment.center,
                          iconColor: _headerColor,
                        ),
                        expanded: Row(
                          children: [
                            _profileImageWidget,
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text(
                                    'this is a long description of person.This paragraph takes longer area asdasd ',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.92)),
                                  ),
                                  SizedBox(height: 10),
                                  !_isFollowingThisUser
                                      ? FlatButton(
                                          onPressed: () {
                                            db
                                                .addUserToFollowings(
                                                    widget.profileKey)
                                                .whenComplete(
                                                    () => checkFollowing());
                                          },
                                          child: Text('Follow',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            side:
                                                BorderSide(color: Colors.green),
                                          ),
                                        )
                                      : FlatButton(
                                          onPressed: () {
                                            db
                                                .removeUserFromFollowings(
                                                    widget.profileKey)
                                                .whenComplete(
                                                    () => checkFollowing());
                                          },
                                          child: Text('unFollow',
                                              style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            side:
                                                BorderSide(color: Colors.amber),
                                          ),
                                        ),
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
              SizedBox(height: 10),
              Expanded(
                  child: DefaultTabController(
                length: 3,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: TabBar(
                      labelPadding: EdgeInsets.symmetric(vertical: 1),
                      indicator: BoxDecoration(color: Colors.transparent),
                      labelColor: Colors.amber,
                      unselectedLabelColor: Colors.white,
                      tabs: [
                        Tab(
                          child: Column(
                            children: [
                              Text(
                                widget._postsMap.length.toString(),
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
                        ),
                      ]),
                  body: TabBarView(children: [
                    ListView(children: postsWidgets),
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
      ),
    );
  }
}
