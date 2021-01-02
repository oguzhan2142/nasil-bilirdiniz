import 'package:kpss_tercih/firebase/database.dart' as db;

class Post implements Comparable {
  String authorUsername;
  String content;
  String postKey;
  String date;
  String authorID;
  String postOwnerUserID;
  int likes = 0;
  bool _fetchedLikes = false;
  Post(
    this.authorUsername,
    this.authorID,
    this.content,
    this.postKey,
    this.date,
    this.postOwnerUserID,
  ) {
    updateLikeAmountText();
  }

  void updateLikeAmountText() {
    db.getLikeAmount(postKey, postOwnerUserID).then((value) {
      likes = value;
      _fetchedLikes = true;
    });
  }

  bool canComparable() {
    return _fetchedLikes;
  }

  @override
  int compareTo(other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }
}
