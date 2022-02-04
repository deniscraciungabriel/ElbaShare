import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final imageURL;
  final ups;
  final downs;
  final author;
  final authorUID;

  Post(this.imageURL, this.ups, this.downs, this.author, this.authorUID);

  Map<String, dynamic> toJSON() {
    return {
      "author": this.author,
      "image": this.imageURL,
      "UID": this.authorUID,
      "ups": this.imageURL,
      "downs": this.downs,
      "timestamp": Timestamp.now().millisecondsSinceEpoch
    };
  }
}
