import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kpss_tercih/notification_page/notification_item.dart';

final firebaseRef = FirebaseDatabase.instance.reference();

String displayName;

void initDisplayName() async {
  displayName = await getUserInfo('displayName');
}

Future<bool> isAuthUserExistInDb() async {
  User user = FirebaseAuth.instance.currentUser;
  var mailSnapshot =
      await firebaseRef.child('persons/${user.uid}/email').once();

  return mailSnapshot.value != null;
}

Future<Map> fetchAllUsers() async {
  var ref = firebaseRef.child('persons');
  var snap = await ref.once();
  Map<dynamic, dynamic> values = snap.value;
  return values;
}

Future<dynamic> getUserInfo(String info, {String userId}) async {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  if (userId != null) authUserID = userId;

  var ref = firebaseRef.child('persons/$authUserID/$info');
  var snapshot = await ref.once();
  return snapshot.value;
}

Future<void> addUserToFollowings(String deauthUserID) async {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  bool isFollowingUser = await isFollowing(deauthUserID);
  
  if (!isFollowingUser) {
    postDataToAuthUser(deauthUserID, 'followings');
    var x = firebaseRef.child('persons/$deauthUserID/followers').push();
    x.set(authUserID);

    print('auth user id $authUserID');
  }
}

Future<void> removeUserFromFollowings(String uId) async {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  DatabaseReference followingsRef =
      firebaseRef.child('persons').child(authUserID).child('followings');
  DataSnapshot followingSnap = await followingsRef.once();
  Map followingUsers = followingSnap.value;
  var key = followingUsers.keys.firstWhere((key) => followingUsers[key] == uId);

  DatabaseReference removeRef = firebaseRef
      .child('persons')
      .child(authUserID)
      .child('followings')
      .child(key);

  DatabaseReference followersRef =
      firebaseRef.child('persons').child(uId).child('followers');

  DataSnapshot followersSnap = await followersRef.once();
  Map followersOfFollowingUser = followersSnap.value;

  var keyOfFollowers = followersOfFollowingUser.keys
      .firstWhere((key) => followersOfFollowingUser[key] == authUserID);
  DatabaseReference followersRemoveRef = followersRef.child(keyOfFollowers);

  removeRef.remove();
  followersRemoveRef.remove();
}

Future<int> getLikeAmount(String postId, String personID) async {
  DatabaseReference likedByRef = firebaseRef
      .child('persons')
      .child(personID)
      .child('posts')
      .child(postId)
      .child('likedBy');

  DataSnapshot snapshot = await likedByRef.once();
  if (snapshot == null) return 0;
  Map likeMap = snapshot.value;
  if (likeMap == null) return 0;
  return likeMap.values.length;
}

Future<void> unLikePost(String postId, String likedPersonId) async {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  DatabaseReference removeRef = firebaseRef
      .child('persons')
      .child(likedPersonId)
      .child('posts')
      .child(postId)
      .child('likedBy');

  DataSnapshot likedBySnap = await removeRef.once();
  Map likedByMap = likedBySnap.value;

  String likeKey;
  if (likedByMap == null) return;
  for (var item in likedByMap.entries) {
    if (item.value == authUserID) likeKey = item.key;
  }

  if (likeKey != null) removeRef.child(likeKey).remove();
}

Future<void> likePost(String postId, String likedPersonId) async {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  DatabaseReference likedPostRef = firebaseRef
      .child('persons')
      .child(likedPersonId)
      .child('posts')
      .child(postId)
      .child('likedBy');

  var id = likedPostRef.push();
  id.set(authUserID);
}

Future<bool> isPostLiked(String postId, String likedPersonId) async {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  DatabaseReference likedPostRef = firebaseRef
      .child('persons')
      .child(likedPersonId)
      .child('posts')
      .child(postId)
      .child('likedBy');

  DataSnapshot likedPostSnap = await likedPostRef.once();
  Map likedPostMap = likedPostSnap.value;
  if (likedPostMap == null) return false;
  return likedPostMap.values.contains(authUserID);
}

Future<bool> isFollowing(String uId) async {
  Map data = await getUserInfo('followings');

  if (data == null) return false;
  return data.containsValue(uId);
}

void addUserToDb(String name) async {
  User user = FirebaseAuth.instance.currentUser;
  bool isExist = await isAuthUserExistInDb();
  if (isExist) return;
  var x = firebaseRef.child('persons').child(user.uid);

  x.set({
    'displayName': name,
    'email': user.email,
    'photoUrl': user.photoURL,
  });
}

void createDatabaseRecordForUser() async {
  if (FirebaseAuth.instance.currentUser == null) {
    print('authentication yok');
    return;
  }

  String uId = FirebaseAuth.instance.currentUser.uid;

  firebaseRef.child('persons/$uId').remove();
}

Future<void> createPostOnSomeoneWall(
    String postedToUserId, String authorId, String content) async {
  DateTime dateTime = DateTime.now();

  var id =
      firebaseRef.child('persons').child(postedToUserId).child('posts').push();
  id.set({
    'author': displayName,
    'content': content,
    'authorId': authorId,
    'date': dateTime.toString()
  });
}

void postDataToAuthUser(dynamic data, String child) {
  String uId = FirebaseAuth.instance.currentUser.uid;
  var x = firebaseRef.child('persons/$uId/$child').push();
  x.set(data);
}

Future<void> updateBiography(String biography) async {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  var ref = firebaseRef.child('persons').child(authUserID);
  ref.update({'biography': biography});
}

Future<Map> getPostsMap({String userID}) async {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  String id = userID == null ? authUserID : userID;

  DatabaseReference ref = firebaseRef.child('persons').child(id).child('posts');
  DataSnapshot snapshot = await ref.once();
  return snapshot.value;
}

Future<List> getListFromDb(String child, {String userId}) async {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  String id;
  if (userId != null)
    id = userId;
  else
    id = authUserID;

  List<String> list = List();

  DatabaseReference ref = firebaseRef.child('persons').child(id).child(child);
  var snapshot = await ref.once();
  Map<dynamic, dynamic> values = snapshot.value;
  if (values != null) {
    values.forEach((key, value) {
      list.add(value);
    });
  }
  return list;
}

Future<void> createNotification(
    NotificationType type, String userID, String message) async {
  DateTime datetime = DateTime.now();

  var id =
      firebaseRef.child('persons').child(userID).child('notifications').push();

  id.set({
    'type': type.toString(),
    'from': displayName,
    'message': message,
    'date': datetime.toString(),
  });
}

void removeAllNotifications() {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  DatabaseReference ref =
      firebaseRef.child('persons').child(authUserID).child('notifications');

  ref.remove();
}

void removeNotification(String notificationID) {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  DatabaseReference ref = firebaseRef
      .child('persons')
      .child(authUserID)
      .child('notifications')
      .child(notificationID);

  ref.remove();
}

Future<Map> fetchNotifications() async {
  String authUserID = FirebaseAuth.instance.currentUser.uid;
  DataSnapshot snapshot = await firebaseRef
      .child('persons')
      .child(authUserID)
      .child('notifications')
      .once();
  return snapshot.value as Map;
}
