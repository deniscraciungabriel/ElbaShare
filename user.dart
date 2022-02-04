import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ffi';

class UserData {
  var uid;
  var imageURL;
  var username;
  var email;
  var bio;
  String contacts = "";

  UserData(this.uid, this.email, [this.imageURL, this.username]);

  void addContact(person) {
    FirebaseFirestore.instance.collection("users").doc(uid).update({
      "Contacts": FieldValue.arrayUnion([person])
    });
  }

  void removeContact(person) {
    FirebaseFirestore.instance.collection("users").doc(uid).update({
      "Following": FieldValue.arrayRemove([person])
    });
  }

  Map<String, dynamic> toJSON() {
    return {
      "username": this.username,
      "email": this.email,
      "UID": this.uid,
      "ImageURL": this.imageURL,
      "Bio": "Ciao! Sto usando ElbaShare",
      "Liked": [],
      "NotLiked": [],
      "Followers": 0,
      "Ups": 0,
      "Followed": [],
      "PostCount": 0,
      "Position": [],
      "Allow": true,
      "Viewed": []
    };
  }
}
