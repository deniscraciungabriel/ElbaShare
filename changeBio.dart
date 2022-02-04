import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'mainPage.dart';
import 'database.dart';
import "package:path/path.dart";
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BioPage extends StatefulWidget {
  final user;
  final bio;
  final url;

  BioPage(this.user, this.bio, this.url);

  @override
  _BioPageState createState() => _BioPageState();
}

class _BioPageState extends State<BioPage> {
  bool _switchValue = true;
  TextEditingController bioController = new TextEditingController();
  var users = FirebaseFirestore.instance.collection("users/");
  final ImagePicker _picker = ImagePicker();
  var imageUrl = null;
  bool show = false;

  File? _image = null;

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
        String fileName = basename(widget.user.uid);
        dynamic firebaseStorage =
            FirebaseStorage.instance.ref("ProfileImages").child(fileName);
        dynamic uploadTask = firebaseStorage.putFile(_image);
      }
      setState(() {});
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
    await getProfilePic();
    setState(() {});
  }

  Future<String> getProfilePic() async {
    try {
      final profileRef =
          FirebaseStorage.instance.ref("ProfileImages").child(widget.user.uid);
      var url = await profileRef.getDownloadURL();

      setState(() {
        imageUrl = url;
      });
      return url;
    } on FirebaseException catch (e) {
      print(e);
      setState(() {});
      return "error";
    }
    setState(() {});
  }

  Widget profilePic(widget, context) {
    getProfilePic();
    return show == false
        ? Padding(
            padding: const EdgeInsets.only(bottom: 38.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: CircleAvatar(
                      backgroundImage: Image.network(widget.url).image,
                      radius: 80),
                ),
                IconButton(
                    onPressed: () => {getImage(), getProfilePic(), show = true},
                    icon: Icon(Icons.camera_alt_outlined)),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(bottom: 38.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: CircleAvatar(
                      backgroundImage: Image.network(imageUrl).image,
                      radius: 80),
                ),
                IconButton(
                    onPressed: () => {
                          changeProfilePic(imageUrl),
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRightWithFade,
                                  child: MainPage(widget.user),
                                  duration: Duration(milliseconds: 550)))
                        },
                    icon: Icon(Icons.save)),
              ],
            ),
          );
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          actions: [
            SizedBox(
              width: 40,
            )
          ],
          leading: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: IconButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.leftToRightWithFade,
                              child: MainPage(widget.user),
                              duration: Duration(milliseconds: 550)))
                    },
                icon: Icon(Icons.arrow_back, size: 25)),
          ),
          backgroundColor: Color.fromRGBO(0, 158, 149, 2),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Text("Elba", style: TextStyle(fontSize: 25, color: Colors.white)),
              Text("Share",
                  style: TextStyle(
                      fontSize: 25,
                      color: Color.fromRGBO(255, 147, 147, 2),
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 150.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                profilePic(widget, context),
                bio(widget, bioController, context),
              ],
            ),
          ),
        ));
  }
}

Widget bio(widget, bio, context) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: 100,
              width: 300,
              child: Container(
                  width: 330,
                  height: 400,
                  child: TextField(
                      maxLines: 5,
                      maxLength: 100,
                      controller: bio,
                      cursorColor: Color.fromRGBO(0, 158, 149, 2),
                      decoration: new InputDecoration(
                        hintText: bio.text == "" ? widget.bio : bio.text,
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(255, 147, 147, 2),
                              width: 2.0),
                        ),
                      )))),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, bottom: 30),
            child: IconButton(
                icon: Icon(MdiIcons.send),
                onPressed: () => {
                      changeBio(widget.user.uid, bio.text),
                      FocusScope.of(context).unfocus(),
                      bio.clear(),
                      widget.bio = bio.text,
                    }),
          )
        ],
      ),
    ],
  );
}
