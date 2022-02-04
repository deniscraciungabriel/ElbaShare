// ignore: file_names
// ignore: file_names
// ignore: file_names
// ignore: file_names
// ignore: file_names
// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:page_transition/page_transition.dart';
import "package:path/path.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'followedHome.dart';
import 'mainPage.dart';
import 'maps.dart';
import 'notification_page.dart';
import 'posting.dart';
import 'voice_chat.dart';

class NavigationBar extends StatefulWidget {
  var user;

  NavigationBar(this.user);

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  var imageUrl;
  var users = FirebaseFirestore.instance.collection("users/");
  final ImagePicker _picker = ImagePicker();

  File? _image = null;
  String? uploadMessage;

  Future getImage() async {
    try {
      var image = await _picker.getImage(source: ImageSource.gallery);
      setState(() {
        if (image != null) {
          _image = File(image.path);
        }
      });
      setState(() {});
      //Upload Part
      if (_image != null) {
        String fileName = basename(_image.toString());
        dynamic firebaseStorage =
            FirebaseStorage.instance.ref(widget.user.uid).child(fileName);
        dynamic uploadTask = await firebaseStorage.putFile(_image);
        setState(() {
          uploadMessage = "Your profile picture has ben uploaded";
        });
        return getProfilePic(fileName);
      }
      setState(() {});
      return null;
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
    ;
  }

  Future<String> getProfilePic(filename) async {
    try {
      final profileRef =
          FirebaseStorage.instance.ref(widget.user.uid).child(filename);
      var url = await profileRef.getDownloadURL();
      imageUrl = url;
      return url;
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
      setState(() {});
      return "errore";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(0, 158, 149, 2),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 7.0, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 28.0),
              child: IconButton(
                  onPressed: () => {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: MapsPage(widget.user),
                                duration: Duration(milliseconds: 250)))
                      },
                  icon: Icon(Icons.map, size: 30, color: Colors.white)),
            ),
            // ignore: prefer_const_constructors
            IconButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: MainPage(widget.user),
                              duration: Duration(milliseconds: 250)))
                    },
                icon: Icon(Icons.home, size: 30, color: Colors.white)),
            IconButton(
                onPressed: () => {
                      getImage().then((value) => {
                            value != null
                                ? Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.bottomToTop,
                                        child: PostingPage(widget.user, value)))
                                : Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: MainPage(widget.user)))
                          })
                    },
                icon: Icon(Icons.add_a_photo_rounded, size: 30),
                color: Colors.white),
            IconButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: FollowPage(widget.user)))
                    },
                icon: Icon(Icons.people, size: 30, color: Colors.white)),

            Padding(
              padding: const EdgeInsets.only(right: 28.0),
              child: IconButton(
                  onPressed: () => {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: VoiceChatPage(widget.user)))
                      },
                  icon: Icon(Icons.video_call, size: 30, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
