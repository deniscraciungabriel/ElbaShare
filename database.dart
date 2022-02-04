import 'package:firebase_auth/firebase_auth.dart';
import 'user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

CollectionReference saveUser(user, username) {
  final db = FirebaseFirestore.instance
      .collection("users/")
      .doc(user.uid)
      .set(user.toJSON());

  FirebaseFirestore.instance
      .collection("usernames")
      .add({"Username": username});

  return FirebaseFirestore.instance.collection('users/');
}

CollectionReference updateUser(user) {
  final db = FirebaseFirestore.instance
      .collection("users/")
      .doc(user.uid)
      .update(user.toJSON());

  return FirebaseFirestore.instance.collection('users/');
}

post(imageURL, authorUID, [caption]) {
  final db = FirebaseFirestore.instance
      .collection("Posts")
      .doc(imageURL.toString().substring(imageURL.toString().length - 15));
  db.set({
    "image": imageURL,
    "UID": authorUID,
    "ups": 0,
    "downs": 0,
    "timestamp": Timestamp.now().millisecondsSinceEpoch,
    "caption": caption,
    "comments": 0,
    "date": DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now())
  });
  final userDB = FirebaseFirestore.instance
      .collection("users")
      .doc(_auth.currentUser!.uid)
      .collection("Posts")
      .doc(imageURL.toString().substring(imageURL.toString().length - 15));
  userDB.set({
    "image": imageURL,
    "UID": authorUID,
    "ups": 0,
    "downs": 0,
    "timestamp": Timestamp.now().millisecondsSinceEpoch,
    "caption": caption,
    "comments": 0,
    "date": DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now())
  });
  FirebaseFirestore.instance
      .collection("users")
      .doc(_auth.currentUser!.uid)
      .update({"PostCount": FieldValue.increment(1)});
}

postStory(imageURL, authorUID, [caption]) {
  final db = FirebaseFirestore.instance.collection("Stories").doc(authorUID);
  db.set({
    "UID": authorUID,
    "timestamp": Timestamp.now().millisecondsSinceEpoch,
    "image": imageURL
  });
  final db2 = FirebaseFirestore.instance
      .collection("users")
      .doc(authorUID)
      .collection("Stories")
      .doc(imageURL.toString().substring(imageURL.toString().length - 15));
  db2.set({
    "image": imageURL,
    "UID": authorUID,
    "timestamp": Timestamp.now().millisecondsSinceEpoch,
    "caption": caption,
    "date": DateTime.now().millisecondsSinceEpoch
  });
}

deleteStory(imageURL, authorUID, [caption]) async {
  var data = await FirebaseFirestore.instance
      .collection("users")
      .doc(authorUID)
      .collection("Stories")
      .get();
  var length = data.size;

  if (length == 1) {
    FirebaseFirestore.instance.collection("Stories").doc(authorUID).delete();
  }

  FirebaseFirestore.instance
      .collection("users")
      .doc(authorUID)
      .collection("Stories")
      .doc(imageURL.toString().substring(imageURL.toString().length - 15))
      .delete();
}

delete(index, ups, image) {
  FirebaseFirestore.instance
      .collection("Posts")
      .doc(image.toString().substring(image.toString().length - 15))
      .delete();
  FirebaseFirestore.instance
      .collection("users")
      .doc(_auth.currentUser!.uid)
      .collection("Posts")
      .doc(image.toString().substring(image.toString().length - 15))
      .delete();
  FirebaseFirestore.instance
      .collection("users")
      .doc(_auth.currentUser!.uid)
      .update({"Ups": FieldValue.increment(-ups)});
  FirebaseFirestore.instance
      .collection("users")
      .doc(_auth.currentUser!.uid)
      .update({"PostCount": FieldValue.increment(-1)});
}

up(index, uid, username, image) {
  final db = FirebaseFirestore.instance.collection("Posts").doc(index);
  db.update({"ups": FieldValue.increment(1)});
  final userDB = FirebaseFirestore.instance
      .collection("users")
      .doc(_auth.currentUser!.uid);
  userDB.update({
    "Liked": FieldValue.arrayUnion([index])
  });
  final user2DB = FirebaseFirestore.instance.collection("users").doc(uid);
  user2DB.update({"Ups": FieldValue.increment(1)});
  final givenDB = FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("Posts")
      .doc(index);
  givenDB.update({"ups": FieldValue.increment(1)});

  if (uid != FirebaseAuth.instance.currentUser!.uid) {
    var notification = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("Notifications");
    notification.add({
      "message": username.toString() + " ha messo up al tuo post",
      "image": image,
      "uid": null
    });
  }
}

upNot(post, uid) {
  final db = FirebaseFirestore.instance.collection("Posts").doc(post);
  db.update({"ups": FieldValue.increment(-1)});
  final userDB = FirebaseFirestore.instance
      .collection("users")
      .doc(_auth.currentUser!.uid);
  userDB.update({
    "Liked": FieldValue.arrayRemove([post])
  });
  final user2DB = FirebaseFirestore.instance.collection("users").doc(uid);
  user2DB.update({"Ups": FieldValue.increment(-1)});
  final givenDB = FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("Posts")
      .doc(post);
  givenDB.update({"ups": FieldValue.increment(-1)});
}

down(index, uid) {
  final db = FirebaseFirestore.instance.collection("Posts").doc(index);
  db.update({"downs": FieldValue.increment(1)});
  final userDB = FirebaseFirestore.instance
      .collection("users")
      .doc(_auth.currentUser!.uid);
  userDB.update({
    "NotLiked": FieldValue.arrayUnion([index])
  });
  final givenDB = FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("Posts")
      .doc(index);
  givenDB.update({"downs": FieldValue.increment(1)});
}

downNot(post, uid) {
  final db = FirebaseFirestore.instance.collection("Posts").doc(post);
  db.update({"downs": FieldValue.increment(-1)});
  final userDB = FirebaseFirestore.instance
      .collection("users")
      .doc(_auth.currentUser!.uid);
  userDB.update({
    "NotLiked": FieldValue.arrayRemove([post])
  });
  final givenDB = FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("Posts")
      .doc(post);
  givenDB.update({"downs": FieldValue.increment(-1)});
}

follow(myUID, uid, username) {
  final db = FirebaseFirestore.instance.collection("users").doc(myUID);
  db.update({
    "Followed": FieldValue.arrayUnion([uid])
  });

  final db2 = FirebaseFirestore.instance.collection("users").doc(uid);
  db2.update({"Followers": FieldValue.increment(1)});
  if (uid != FirebaseAuth.instance.currentUser!.uid) {
    var notification = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("Notifications");
    notification.add({
      "message": username.toString() + " ha iniziato a seguirti",
      "image": null,
      "uid": uid
    });
  }
}

followDown(myUID, uid) {
  final db = FirebaseFirestore.instance.collection("users").doc(myUID);
  db.update({
    "Followed": FieldValue.arrayRemove([uid])
  });

  final db2 = FirebaseFirestore.instance.collection("users").doc(uid);
  db2.update({"Followers": FieldValue.increment(-1)});
}

commentFunc(username, text, index, author) {
  FirebaseFirestore.instance
      .collection("Posts")
      .doc(index)
      .collection("Comments")
      .doc(author.toString() + text.toString())
      .set({
    "Author": username,
    "Text": text,
  });
  FirebaseFirestore.instance
      .collection("Posts")
      .doc(index)
      .update({"comments": FieldValue.increment(1)});
  FirebaseFirestore.instance
      .collection("users")
      .doc(author)
      .collection("Posts")
      .doc(index)
      .update({"comments": FieldValue.increment(1)});
}

deleteCommentFunc(username, text, index, author) {
  FirebaseFirestore.instance
      .collection("Posts")
      .doc(index)
      .collection("Comments")
      .doc(author.toString() + text.toString())
      .delete();
  FirebaseFirestore.instance
      .collection("Posts")
      .doc(index)
      .update({"comments": FieldValue.increment(-1)});
  FirebaseFirestore.instance
      .collection("users")
      .doc(author)
      .collection("Posts")
      .doc(index)
      .update({"comments": FieldValue.increment(-1)});
}

changeBio(uid, bio) {
  final db = FirebaseFirestore.instance.collection("users").doc(uid);
  db.update({"Bio": bio});
}

changeProfilePic(url) {
  final db = FirebaseFirestore.instance
      .collection("users")
      .doc(_auth.currentUser!.uid);
  db.update({"ImageURL": url});
}

uploadPosition(lat, long) {
  FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .update({
    "Position": [lat, long]
  });
}

deleteNotifications() {
  FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("Notifications")
      .get()
      .then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
}
