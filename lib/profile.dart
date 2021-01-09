import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:kpss_tercih/editable_post_widget.dart';
import 'package:kpss_tercih/firebase/database.dart' as db;
import 'package:kpss_tercih/firebase/firestore.dart' as store;
import 'package:kpss_tercih/post_widget.dart';
import 'package:sprintf/sprintf.dart';
import 'notifications.dart' as notifications;
import 'notification_page/notification_item.dart';
import 'profile_page/post_choise_button.dart';

class Profile extends StatefulWidget {
  final bool isAuthProfile;
  final String profileID;

  Profile({Key key, @required this.isAuthProfile, this.profileID})
      : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final profileImageSize = 80.0;
  int followingCount = 0;
  int followersCount = 0;
  int postCount = 0;
  Image profileImage;
  String username = '';
  final picker = ImagePicker();
  File loadedImageFile;
  bool isEditingDescText = false;
  bool isBiographyWidgetVisible = true;
  String biographyText = '';
  bool isFollowingThisUser = false;
  TextEditingController textEditingController = TextEditingController();
  bool floatingActionVisible;
  EditablePostWidget newPostEditablePostWidget;
  EditablePostWidget updatePostEditablePostWidget;

  List<Widget> postWidgets = List();

  bool isAlreadyPostedToAuthUser = false;

  List<PostWidget> createPostWidgetList(Map postMap) {
    List<PostWidget> postWidgets = List();

    if (postMap == null) return postWidgets;

    postMap.forEach((key, value) {
      Map likedBy = value['likedBy'];
      int likes = likedBy == null ? 0 : likedBy.length;

      postWidgets.add(PostWidget(
        postOwnerId: widget.profileID == null
            ? FirebaseAuth.instance.currentUser.uid
            : widget.profileID,
        postKey: key,
        author: value['author'],
        date: value['date'],
        content: value['content'],
        isAuthProfile: widget.isAuthProfile,
        likes: likes,
      ));
      postWidgets.sort();
    });

    return postWidgets;
  }

  void checkFollowing() async {
    db.isFollowing(widget.profileID).then((isFollowing) {
      setState(() {
        isFollowingThisUser = isFollowing;
      });
    });
  }

  @override
  initState() {
    super.initState();
    profileImage = Image.asset('res/user.png', width: profileImageSize);
    floatingActionVisible = !widget.isAuthProfile;
    if (!widget.isAuthProfile) {
      db.isAlreadyPosted(widget.profileID).then((value) {
        setState(() {
          isAlreadyPostedToAuthUser = value;
        });
      });
    }
    initUsername();

    updateFollowers();

    updateFollowings();

    updatePostWidgetsList();

    if (!widget.isAuthProfile) checkFollowing();

    initProfileImage();

    db.getUserInfo('biography', userId: widget.profileID).then((value) {
      if (mounted)
        setState(() {
          biographyText = value;
        });
    });

    initEditablePostWidgets();
  }

  void initEditablePostWidgets() {
    newPostEditablePostWidget = EditablePostWidget(
      profileKey: widget.profileID,
      updatePostWidgets: updatePostWidgetsList,
      isUpdateVersion: false,
      onCancel: () {
        List<Widget> temp = List();
        temp.addAll(postWidgets);
        temp.remove(newPostEditablePostWidget);
        if (mounted)
          setState(() {
            postWidgets = temp;
            if (!widget.isAuthProfile) floatingActionVisible = true;
          });
      },
    );
    updatePostEditablePostWidget = EditablePostWidget(
      profileKey: widget.profileID,
      updatePostWidgets: updatePostWidgetsList,
      isUpdateVersion: true,
      onCancel: () {
        List<Widget> temp = List();
        temp.addAll(postWidgets);
        temp.remove(updatePostEditablePostWidget);

        if (mounted)
          setState(() {
            postWidgets = temp;
            if (!widget.isAuthProfile) floatingActionVisible = true;
          });
      },
    );
  }

  void initUsername() {
    if (widget.isAuthProfile) {
      db.getUserInfo('username').then((value) {
        username = value;
      });
    } else {
      db.getUserInfo('username', userId: widget.profileID).then((value) {
        if (mounted)
          setState(() {
            username = value;
          });
      });
    }
  }

  void updatePostWidgetsList() async {
    bool isPosted = await db.isAlreadyPosted(widget.profileID);

    Map postMap = await db.getPostsMap(userID: widget.profileID);
    if (postMap == null) {
      setState(() {
        isAlreadyPostedToAuthUser = isPosted;
        if (!widget.isAuthProfile) floatingActionVisible = true;
        postCount = 0;
      });
    }

    List<PostWidget> temp = createPostWidgetList(postMap);

    setState(() {
      postWidgets = temp;
      postCount = postMap == null ? 0 : postMap.length;
      isAlreadyPostedToAuthUser = isPosted;
      if (!widget.isAuthProfile) floatingActionVisible = true;
    });

    temp = null;
  }

  void updateFollowings() {
    db.getListFromDb('followings', userId: widget.profileID).then((value) {
      setState(() {
        if (value != null) followingCount = value.length;
      });
    });
  }

  void updateFollowers() {
    db.getListFromDb('followers', userId: widget.profileID).then((value) {
      setState(() {
        if (value != null) followersCount = value.length;
      });
    });
  }

  Future initProfileImage() async {
    String id = widget.profileID == null
        ? FirebaseAuth.instance.currentUser.uid
        : widget.profileID;

    String imageUrl = await store.getDownloadLink(uid: id);
    if (imageUrl != null) {
      Image temp = Image.network(imageUrl, width: profileImageSize);
      if (mounted)
        setState(() {
          profileImage = temp;
        });
      temp = null;
    }
  }

  void updateBiographyText() {
    db.getUserInfo('biography').then((value) {
      if (value != null)
        setState(() {
          biographyText = value;
        });
    });
  }

  Future<bool> getImageFromDisc() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      loadedImageFile = File(pickedFile.path);
      setState(() {
        profileImage = Image.file(loadedImageFile, width: profileImageSize);
      });
    }
    return pickedFile != null;
  }

  Widget getCardButton() {
    if (!widget.isAuthProfile) {
      if (!isFollowingThisUser) {
        return FlatButton(
          onPressed: () {
            db.addUserToFollowings(widget.profileID).whenComplete(() {
              checkFollowing();

              db.createNotification(
                NotificationType.followed,
                widget.profileID,
                sprintf(notifications.followed, [username]),
              );
              updateFollowers();
              updateFollowings();
            });
          },
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            'Takip Et',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          color: Colors.amber,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      } else {
        return FlatButton(
          onPressed: () {
            db.removeUserFromFollowings(widget.profileID).whenComplete(() {
              checkFollowing();

              db.createNotification(
                NotificationType.unfollowed,
                widget.profileID,
                sprintf(notifications.unfollowed, [username]),
              );
              updateFollowers();
              updateFollowings();
            });
          },
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            'Takipten Çık',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          color: Colors.amber,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }
    } else {
      return FlatButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
        },
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          'Çıkış Yap',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.amber,
          ),
        ),
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
    }
  }

  void setEditingMode(bool isEditing) {
    setState(() {
      textEditingController.text = biographyText;
      isEditingDescText = isEditing;
      isBiographyWidgetVisible = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      backgroundColor: Colors.amber,
      elevation: 0,
    );
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: widget.isAuthProfile ? null : appBar,
      floatingActionButton: Visibility(
        visible: floatingActionVisible,
        child: FloatingActionButton(
          onPressed: () {
            if (!isAlreadyPostedToAuthUser)
              createNewPostMode();
            else
              updatePostMode();
          },
          child: Icon(
            isAlreadyPostedToAuthUser ? Icons.update : Icons.add,
            color: Colors.amber,
          ),
          backgroundColor: Colors.black.withAlpha(120),
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: constraints.copyWith(
                minHeight: constraints.maxHeight, maxHeight: double.infinity),
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.36,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(150, 40),
                      bottomRight: Radius.elliptical(150, 40),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        widget.isAuthProfile
                            ? SizedBox(height: appBar.preferredSize.height)
                            : Container(),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                          ),
                          child: Card(
                            elevation: 22,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            color: Colors.grey[200],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(
                                    overflow: Overflow.visible,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(360),
                                        child: SizedBox(
                                          height: profileImageSize,
                                          child: profileImage,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: widget.isAuthProfile
                                            ? Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    bool isSuccessfull =
                                                        await getImageFromDisc();

                                                    if (isSuccessfull) {
                                                      Reference ref = await store
                                                          .searchReference();
                                                      if (ref != null)
                                                        await ref.delete();
                                                      store.uploadFile(
                                                          loadedImageFile);
                                                    }
                                                  },
                                                  child: Icon(
                                                    Icons.edit,
                                                    color: Colors.amber,
                                                    size: 35,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    username == null ? 'Bilinmiyor' : username,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 50),
                                    child: isEditingDescText &&
                                            widget.isAuthProfile
                                        ? Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  ChoiseButton(
                                                    text: 'Yayınla',
                                                    borderColor: Colors.green,
                                                    textColor: Colors.grey[850],
                                                    onClick: () {
                                                      db
                                                          .updateBiography(
                                                              textEditingController
                                                                  .text)
                                                          .whenComplete(() {
                                                        updateBiographyText();
                                                        setEditingMode(false);
                                                      });
                                                    },
                                                  ),
                                                  SizedBox(width: 10),
                                                  ChoiseButton(
                                                    text: 'Vazgeç',
                                                    borderColor: Colors.red,
                                                    textColor: Colors.grey[850],
                                                    onClick: () {
                                                      setState(() {
                                                        setEditingMode(false);
                                                      });
                                                    },
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey[850],
                                                      width: 1),
                                                ),
                                                child: EditableText(
                                                    controller:
                                                        textEditingController,
                                                    focusNode: FocusNode(),
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[850]),
                                                    cursorColor: Colors.amber,
                                                    backgroundCursorColor:
                                                        Colors.transparent),
                                              ),
                                            ],
                                          )
                                        : RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: biographyText,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                widget.isAuthProfile
                                                    ? WidgetSpan(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setEditingMode(
                                                                true);
                                                          },
                                                          child: Icon(
                                                            Icons.edit,
                                                            size: 14,
                                                            color: Colors.amber,
                                                          ),
                                                        ),
                                                      )
                                                    : WidgetSpan(
                                                        child: Container())
                                              ],
                                            ),
                                          ),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        child: Column(
                                          children: [
                                            Text(
                                              postCount.toString(),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text('Post',
                                                style: TextStyle(fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Column(
                                          children: [
                                            Text(
                                              followingCount.toString(),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text('Takip Edilen',
                                                style: TextStyle(fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Column(
                                          children: [
                                            Text(
                                              followersCount.toString(),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text('Takipçi',
                                                style: TextStyle(fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  getCardButton(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Divider(
                            color: Colors.amber, height: 50, thickness: 0.8),
                        Column(
                          children: postWidgets,
                        ),
                        SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void createNewPostMode() {
    List<Widget> temp = List();
    temp.addAll(postWidgets);
    temp.add(newPostEditablePostWidget);
    setState(() {
      postWidgets = temp;
      floatingActionVisible = false;
    });
    newPostEditablePostWidget.focusNode.requestFocus();
  }

  void updatePostMode() {
    List<Widget> temp = List();
    temp.addAll(postWidgets);
    String authUserID = FirebaseAuth.instance.currentUser.uid;
    int index = postWidgets.indexWhere((w) {
      PostWidget postWidget = w;

      if (postWidget.postKey == authUserID) return true;
      return false;
    });

    if (index < 0) return;

    PostWidget postWidget = temp[index];
    String content = postWidget.content;
    updatePostEditablePostWidget.setText(content);
    temp.removeAt(index);
    temp.insert(index, updatePostEditablePostWidget);
    setState(() {
      postWidgets = temp;
    });
  }
}
