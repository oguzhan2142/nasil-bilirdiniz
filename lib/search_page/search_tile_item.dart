import 'package:flutter/material.dart';
import 'package:kpss_tercih/database.dart';

import '../deauth_profile.dart';

class SearchTileItem extends StatefulWidget {
  @override
  _SearchTileItemState createState() => _SearchTileItemState();

  Future futureProfileImage;
  Map userData;
  String userKey;

  SearchTileItem(
      {Key key, this.futureProfileImage, this.userKey, this.userData})
      : super(key: key);
}

class _SearchTileItemState extends State<SearchTileItem> {
  bool _isFollowingThisUser = false;

  @override
  void initState() {
    super.initState();
    checkFollowing();
  }

  void checkFollowing() async {
    isFollowing(widget.userKey).then((isFollowing) {
      setState(() {
        _isFollowingThisUser = isFollowing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridTile(
          child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Stack(children: [
          FutureBuilder(
            future: widget.futureProfileImage,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (!snapshot.hasData)
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeauthProfile(
                                  profileKey: widget.userKey,
                                  profileData: widget.userData,
                                )));
                  },
                  child: Image.asset('res/user.png'),
                );
              else
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeauthProfile(
                                  profileKey: widget.userKey,
                                  profileData: widget.userData,
                                )));
                  },
                  child: Image.network(snapshot.data),
                );
            },
          ),
          _isFollowingThisUser
              ? GestureDetector(
                  onTap: () {
                    removeUserFromFollowings(widget.userKey)
                        .whenComplete(() => checkFollowing());
                  },
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: EdgeInsets.only(right: 8, bottom: 8),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(360),
                            child: Container(
                                color: Colors.black,
                                child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image(
                                      image: AssetImage('res/minus.png'),
                                      color: Colors.amber,
                                      width: 15,
                                    )))),
                      )),
                )
              : GestureDetector(
                  onTap: () {
                    addUserToFollowings(widget.userKey)
                        .whenComplete(() => checkFollowing());
                  },
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: EdgeInsets.only(right: 8, bottom: 8),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(360),
                            child: Container(
                                color: Colors.black,
                                child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image(
                                      image: AssetImage('res/add.png'),
                                      color: Colors.amber,
                                      width: 15,
                                    )))),
                      )),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              widget.userData['displayName'],
              style: TextStyle(color: Colors.white70),
            ),
          )
        ]),
      )),
    );
  }
}
