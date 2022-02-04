import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'auth.dart';
import 'login.dart';
import 'mainPage.dart';
import 'user.dart';
import 'database.dart';
import "package:path/path.dart";
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InitialisePage extends StatefulWidget {
  final user;

  InitialisePage(this.user);

  @override
  _InitialisePageState createState() => _InitialisePageState();
}

class _InitialisePageState extends State<InitialisePage> {
  TextEditingController username = new TextEditingController();
  var users = FirebaseFirestore.instance.collection("users/");
  final ImagePicker _picker = ImagePicker();
  var imageUrl;
  dynamic usernameKey = new GlobalKey();
  var usernames = [];

  void initState() {
    super.initState();
    getUserNames();
  }

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
        String fileName = basename(widget.user.uid);
        dynamic firebaseStorage =
            FirebaseStorage.instance.ref("ProfileImages").child(fileName);
        dynamic uploadTask = firebaseStorage.putFile(_image);
        setState(() {
          uploadMessage = "Your profile picture has ben uploaded";
        });
      }
      setState(() {});
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
    getProfilePic();
    setState(() {});
  }

  Future<String> getProfilePic() async {
    try {
      final profileRef =
          FirebaseStorage.instance.ref("ProfileImages").child(widget.user.uid);
      var url = await profileRef.getDownloadURL();
      imageUrl = url;
      setState(() {});
      return url;
    } on FirebaseException catch (e) {
      print(e);
      setState(() {});
      return "error";
    }
    setState(() {});
  }

  getUserNames() async {
    var data = await FirebaseFirestore.instance.collection("usernames").get();
    data.docs.forEach((element) {
      usernames.add(element["Username"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_new
    return new FutureBuilder(
        future: getProfilePic(),
        initialData: "Loading",
        builder: (BuildContext context, AsyncSnapshot<String> url) {
          // ignore: unnecessary_new
          return new Scaffold(
              body: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      this.uploadMessage != null
                          ? Text(uploadMessage!)
                          : Text(""),
                      Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: url.data != "error"
                                ? Image.network(url.data!).image
                                : AssetImage("images/take1.jpg"),
                            radius: 80,
                          ),
                          IconButton(
                              onPressed: () => {
                                    this.setState(() {
                                      getImage();
                                    })
                                  },
                              icon: Icon(Icons.camera_alt_outlined)),
                          Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Container(
                                child: TextFormField(
                                  key: usernameKey,
                                  controller: this.username,
                                  validator: (value) {
                                    if (usernames.contains(value)) {
                                      return "Il nome utente è gia stato preso";
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: "Enter Username",
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.send),
                                        onPressed: () => {
                                          if (usernameKey.currentState!
                                              .validate())
                                            {
                                              saveUser(
                                                  UserData(
                                                      widget.user.uid,
                                                      widget.user.email,
                                                      url.data!,
                                                      username.text),
                                                  username.text),
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(widget.user.uid)
                                                  .update({"Following": []}),
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MainPage(
                                                              widget.user)))
                                            }
                                        },
                                      )),
                                ),
                                width: 250,
                              )),
                          Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 30),
                              child: Container(
                                child: Column(
                                  children: [
                                    Text(
                                      "Email:",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(widget.user.email),
                                    )
                                  ],
                                ),
                                width: 200,
                              )),
                        ],
                      ),
                      ElevatedButton(
                          onPressed: () => {
                                signOut().then((value) => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginPage()))
                                    })
                              },
                          child: Text("Sign Out"))
                    ],
                  )));
        });
  }
}
