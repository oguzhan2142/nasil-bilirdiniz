import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

FirebaseStorage storage = FirebaseStorage.instance;
String userId = FirebaseAuth.instance.currentUser.uid;

Future uploadFile(File imageFile) async {
  Reference ref = storage.ref().child(userId);
  UploadTask uploadTask = ref.putFile(imageFile);
  uploadTask.then((res) {
    var url = res.ref.getDownloadURL();
    url.then((value) => print(value));
  });
}

Future<String> getDownloadLink({String uid}) async {
  Reference ref;

  if (uid == null)
    ref = await searchReference();
  else
    ref = await searchReference(uid: uid);

  if (ref != null) {
    String link = await ref.getDownloadURL();
    return link;
  } else {
    return null;
  }
}

Future<Reference> searchReference({String uid}) async {
  String lookingUserId = userId;

  if (uid != null) lookingUserId = uid;

  ListResult listResult = await storage.ref().listAll();
  for (var item in listResult.items) {
    if (item.name == lookingUserId) {
      return item;
    }
  }
  return null;
}
