// ignore: file_names
// ignore: file_names
// ignore: file_names
// ignore: file_names
// ignore_for_file: prefer_const_constructors_in_immutables, prefer_typing_uninitialized_variables, prefer_const_constructors, duplicate_ignore, file_names
import 'package:elbashare/commentPage.dart';
import 'package:elbashare/mainPageTendenze.dart';
// ignore: file_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'database.dart';
import 'navBar.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:path/path.dart";
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'auth.dart';
import 'notification_page.dart';
import 'profile.dart';
import "dart:ffi";
import 'package:intl/intl.dart';

import 'search.dart';
import 'story.dart';
import 'story_posting.dart';

class MainPage extends StatefulWidget {
  final user;
  bool recent = true;
  // ignore: use_key_in_widget_constructors

  MainPage(this.user);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var imageUrl;
  var users = FirebaseFirestore.instance.collection("users/");
  final ImagePicker _picker = ImagePicker();
  File? _image = null;
  String? uploadMessage;
  Location location = new Location();
  var viewed = [];
  String username = "";

  void initState() {
    super.initState;

    getViewedList();
    getUsername();
    usersStream.listen((event) {
      event.docs.forEach((element) async {
        var data = await FirebaseFirestore.instance
            .collection("users")
            .doc(element["UID"])
            .collection("Stories")
            .snapshots();

        data.forEach((value) {
          value.docs.forEach((element) {
            if (DateTime.now()
                    .difference(
                        DateTime.fromMillisecondsSinceEpoch(element["date"]))
                    .inHours >
                24) {
              deleteStory(element["image"], element["UID"]);
            }
            ;
          });
        });
      });
    });
  }

  getUsername() async {
    var dataUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user.uid)
        .get();
    this.username = dataUser["username"];
  }

  getViewedList() async {
    var data = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user.uid)
        .get();
    viewed = data["Viewed"];
    return viewed;
  }

  Stream<QuerySnapshot> get usersStream {
    return FirebaseFirestore.instance.collection("users").snapshots();
  }

  Future<String> getProfilePic(uid) async {
    try {
      final profileRef =
          FirebaseStorage.instance.ref("ProfileImages").child(uid);
      var url = await profileRef.getDownloadURL();
      imageUrl = url;
      setState(() {});
      if (url != null) {
        return url;
      } else {
        return "error";
      }
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
      setState(() {});
      return "error";
    }
  }

  Widget post(uid, url, ups, downs, index, caption, comments, date) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: Column(
        children: [
          //AUTHOR
          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Column(
              children: [
                //Image
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(uid)
                        .snapshots(),
                    builder: (context, AsyncSnapshot data) {
                      if (data.hasData) {
                        var user = data.requireData;
                        var url = user["ImageURL"];
                        return GestureDetector(
                          onTap: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfilePage(widget.user, uid)))
                          },
                          child: CircleAvatar(
                            backgroundImage: (url != "error" && url != null)
                                ? Image.network(url!).image
                                : AssetImage("images/take1.jpg"),
                            radius: 25,
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }),

                //username
                FutureBuilder<DocumentSnapshot>(
                    future: users.doc(uid).get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      dynamic data = "";
                      if (snapshot.data != null) {
                        data = snapshot.data!.data() as Map<String, dynamic>;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                            data != "" ? data["username"] : "caricamento",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      );
                    })
              ],
            ),
          ),

          //IMAGE
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              child: AspectRatio(
                aspectRatio: 3 / 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                          color: const Color.fromRGBO(255, 255, 255, 0.9),
                          colorBlendMode: BlendMode.modulate,
                          image: Image.network(url).image,
                          fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(date),
          ),
          //CAPTION
          caption != ""
              ? Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, bottom: 4, top: 10),
                  child: Container(
                      alignment: Alignment.center,
                      child: Text(caption, style: TextStyle(fontSize: 17))),
                )
              : Container(),

          //FUNCTIONS
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(widget.user.uid)
                              .snapshots(),
                          builder: (context, AsyncSnapshot data) {
                            if (data.hasData) {
                              var user = data.requireData;
                              return user["Liked"].contains(index.toString())
                                  ? IconButton(
                                      onPressed: () => {
                                            !user["NotLiked"]
                                                    .contains(index.toString())
                                                ? upNot(index.toString(), uid)
                                                : () => {}
                                          },
                                      icon: Icon(MdiIcons.arrowUpBold,
                                          size: 30,
                                          color:
                                              Color.fromRGBO(0, 158, 149, 2)))
                                  : IconButton(
                                      onPressed: () => {
                                            !user["NotLiked"]
                                                    .contains(index.toString())
                                                ? up(index.toString(), uid,
                                                    username, url)
                                                : () => {}
                                          },
                                      icon: Icon(MdiIcons.arrowUpBold,
                                          size: 30, color: Colors.black));
                            } else {
                              return Container();
                            }
                          },
                        )),
                    Text(ups.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18))
                  ],
                ),
                Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(widget.user.uid)
                              .snapshots(),
                          builder: (context, AsyncSnapshot data) {
                            if (data.hasData) {
                              var user = data.requireData;
                              return user["NotLiked"].contains(index.toString())
                                  ? IconButton(
                                      onPressed: () => {
                                            !user["Liked"]
                                                    .contains(index.toString())
                                                ? downNot(index.toString(), uid)
                                                : () => {}
                                          },
                                      icon: Icon(MdiIcons.arrowDownBold,
                                          size: 30,
                                          color:
                                              Color.fromRGBO(255, 147, 147, 2)))
                                  : IconButton(
                                      onPressed: () => {
                                            !user["Liked"]
                                                    .contains(index.toString())
                                                ? down(index.toString(), uid)
                                                : () => {}
                                          },
                                      icon: Icon(MdiIcons.arrowDownBold,
                                          size: 30, color: Colors.black));
                            } else {
                              return Container();
                            }
                          },
                        )),
                    Text(downs.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 13.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => {
                            Navigator.push(
                                this.context,
                                MaterialPageRoute(
                                    builder: (context) => CommentPage(
                                          widget.user.uid,
                                          uid,
                                          index,
                                        )))
                          },
                          icon: Icon(MdiIcons.comment, size: 25),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: Text(comments.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        )
                      ]),
                ),
                uid == FirebaseAuth.instance.currentUser!.uid
                    ? Padding(
                        padding: const EdgeInsets.only(left: 28.0),
                        child: TextButton(
                          onPressed: () => {
                            showDialog(
                                context: this.context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                      backgroundColor: Colors.grey,
                                      insetPadding: EdgeInsets.all(10),
                                      child: Stack(
                                        overflow: Overflow.visible,
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: 300,
                                            height: 200,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.grey),
                                            padding: EdgeInsets.fromLTRB(
                                                20, 50, 20, 0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 28.0),
                                                  child: Text(
                                                      "Sei sicuro di voler cancellare il post?",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black),
                                                      textAlign:
                                                          TextAlign.center),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    TextButton(
                                                        onPressed: () => {
                                                              delete(index, ups,
                                                                  url),
                                                              Navigator.pop(
                                                                  context)
                                                            },
                                                        child: Text("Si",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 17))),
                                                    TextButton(
                                                        onPressed: () => {
                                                              Navigator.pop(
                                                                  context)
                                                            },
                                                        child: Text("No",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 17))),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ));
                                })
                          },
                          child: Text("Elimina",
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 147, 147, 2))),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ],
      ),
    );
  }

  getLocaiton() async {
    var position = await location.getLocation();
    if (position.latitude! > 42.680977 && position.latitude! < 42.896903) {
      if (position.longitude! > 9.979657 && position.longitude! < 10.492581) {
        return true;
      } else {
        return false;
      }
    }
  }

  @override
  // ignore: duplicate_ignore
  Widget build(BuildContext context) {
    Future<String> getStory(filename) async {
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

    getImage() async {
      try {
        var image = await _picker.getImage(source: ImageSource.camera);
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
          return getStory(fileName);
        }
        setState(() {});
        return null;
      } on PlatformException catch (e) {
        print("Failed to pick image: $e");
      }
      ;
    }

    stories() {
      print(viewed);
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Stories")
              .orderBy("timestamp")
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot data) {
            if (data.hasData) {
              var story = data.requireData;

              if (story.size == 0) {
                return Padding(
                  padding: const EdgeInsets.only(left: 13.0, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FloatingActionButton(
                          child: Icon(Icons.add),
                          onPressed: () => {
                                getImage().then((value) => {
                                      value != null
                                          ? Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .bottomToTop,
                                                  child: StoryPostingPage(
                                                      widget.user, value)))
                                          : Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType.fade,
                                                  child: MainPage(widget.user)))
                                    })
                              }),
                    ],
                  ),
                );
              } else {
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: story.size,
                    itemBuilder: (BuildContext context, index) {
                      if (index == 0) {
                        return Row(
                          children: [
                            FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(story.docs[index]["UID"])
                                    .get(),
                                builder: (context, AsyncSnapshot data2) {
                                  if (data2.hasData) {
                                    var user = data2.requireData;
                                    var url = user["ImageURL"];

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          right: 28.0, left: 10),
                                      child: FloatingActionButton(
                                          child: Icon(Icons.add),
                                          onPressed: () => {
                                                getImage().then((value) => {
                                                      value != null
                                                          ? Navigator.push(
                                                              context,
                                                              PageTransition(
                                                                  type: PageTransitionType
                                                                      .bottomToTop,
                                                                  child: StoryPostingPage(
                                                                      widget
                                                                          .user,
                                                                      value)))
                                                          : Navigator.push(
                                                              context,
                                                              PageTransition(
                                                                  type:
                                                                      PageTransitionType
                                                                          .fade,
                                                                  child: MainPage(
                                                                      widget
                                                                          .user)))
                                                    })
                                              }),
                                    );
                                  } else {
                                    return CircleAvatar(
                                        backgroundImage:
                                            AssetImage("images/take1.jpg"),
                                        radius: 30);
                                  }
                                }),
                            FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(story.docs[index]["UID"])
                                    .get(),
                                builder: (context, AsyncSnapshot data2) {
                                  if (data2.hasData) {
                                    var user = data2.requireData;
                                    var url = user["ImageURL"];

                                    return !user["Viewed"].contains(story
                                            .docs[index]["image"]
                                            .toString()
                                            .substring(story.docs[index]
                                                        ["image"]
                                                    .toString()
                                                    .length -
                                                15))
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: GestureDetector(
                                              onTap: () => {
                                                FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(widget.user.uid)
                                                    .update({
                                                  "Viewed":
                                                      FieldValue.arrayUnion([
                                                    story.docs[index]["image"]
                                                        .toString()
                                                        .substring(story
                                                                .docs[index]
                                                                    ["image"]
                                                                .toString()
                                                                .length -
                                                            15)
                                                  ])
                                                }),
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        type: PageTransitionType
                                                            .fade,
                                                        child: StoryPage(
                                                            user["UID"],
                                                            widget.user)))
                                              },
                                              child: CircleAvatar(
                                                  backgroundImage: (url !=
                                                              "error" &&
                                                          url != null)
                                                      ? Image.network(url!)
                                                          .image
                                                      : AssetImage(
                                                          "images/take1.jpg"),
                                                  radius: 30),
                                            ),
                                          )
                                        : Container();
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 13.0, top: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          FloatingActionButton(
                                              child: Icon(Icons.add),
                                              onPressed: () => {
                                                    getImage().then((value) => {
                                                          value != null
                                                              ? Navigator.push(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .bottomToTop,
                                                                      child: StoryPostingPage(
                                                                          widget
                                                                              .user,
                                                                          value)))
                                                              : Navigator.push(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .fade,
                                                                      child: MainPage(
                                                                          widget
                                                                              .user)))
                                                        })
                                                  }),
                                        ],
                                      ),
                                    );
                                  }
                                })
                          ],
                        );
                      } else {
                        return FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection("users")
                                .doc(story.docs[index]["UID"])
                                .get(),
                            builder: (context, AsyncSnapshot data2) {
                              if (data2.hasData) {
                                var user = data2.requireData;
                                var url = user["ImageURL"];

                                return !viewed.contains(story.docs[index]
                                            ["image"]
                                        .toString()
                                        .substring(story.docs[index]["image"]
                                                .toString()
                                                .length -
                                            15))
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: GestureDetector(
                                          onTap: () => {
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(widget.user.uid)
                                                .update({
                                              "Viewed": FieldValue.arrayUnion([
                                                story.docs[index]["image"]
                                                    .toString()
                                                    .substring(story.docs[index]
                                                                ["image"]
                                                            .toString()
                                                            .length -
                                                        15)
                                              ])
                                            }),
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    type:
                                                        PageTransitionType.fade,
                                                    child: StoryPage(
                                                        user["UID"],
                                                        widget.user)))
                                          },
                                          child: CircleAvatar(
                                              backgroundImage: (url !=
                                                          "error" &&
                                                      url != null)
                                                  ? Image.network(url!).image
                                                  : AssetImage(
                                                      "images/take1.jpg"),
                                              radius: 30),
                                        ),
                                      )
                                    : Container();
                              } else {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(left: 13.0, top: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      FloatingActionButton(
                                          child: Icon(Icons.add),
                                          onPressed: () => {
                                                getImage().then((value) => {
                                                      value != null
                                                          ? Navigator.push(
                                                              context,
                                                              PageTransition(
                                                                  type: PageTransitionType
                                                                      .bottomToTop,
                                                                  child: StoryPostingPage(
                                                                      widget
                                                                          .user,
                                                                      value)))
                                                          : Navigator.push(
                                                              context,
                                                              PageTransition(
                                                                  type:
                                                                      PageTransitionType
                                                                          .fade,
                                                                  child: MainPage(
                                                                      widget
                                                                          .user)))
                                                    })
                                              }),
                                    ],
                                  ),
                                );
                              }
                            });
                      }
                    },
                  ),
                );
              }
            } else {
              return Padding(
                padding: const EdgeInsets.only(left: 13.0, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FloatingActionButton(
                        child: Icon(Icons.add),
                        onPressed: () => {
                              getImage().then((value) => {
                                    value != null
                                        ? Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType
                                                    .bottomToTop,
                                                child: StoryPostingPage(
                                                    widget.user, value)))
                                        : Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: MainPage(widget.user)))
                                  })
                            }),
                  ],
                ),
              );
            }
          });
    }

    Widget postFilter() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.only(left: 0.0, right: 20),
            child: Text("Ordina post per: ",
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      width: widget.recent != true ? 2.0 : 0,
                      color: widget.recent != true
                          ? Color.fromRGBO(255, 147, 147, 2)
                          : Colors.grey),
                ),
                onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MainPageTendenze(widget.user)))
                    },
                child: Text("Tendenze",
                    style: TextStyle(color: Color.fromRGBO(0, 158, 149, 2)))),
          ),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    width: widget.recent == true ? 2.0 : 0,
                    color: widget.recent == true
                        ? Color.fromRGBO(255, 147, 147, 2)
                        : Colors.grey),
              ),
              onPressed: () => {},
              child: Text("Recenti",
                  style: TextStyle(color: Color.fromRGBO(0, 158, 149, 2)))),
        ]),
      );
    }

    return /*(getLocaiton() == true || widget.user.uid == "WFm77q5qNSc8J6O9NmEOGzh5TAe2")
        ? */
        Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: IconButton(
              icon: Icon(Icons.search, size: 25),
              onPressed: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchPage(widget.user)))
                  }),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProfilePage(widget.user, widget.user.uid)))
                    },
                icon: Icon(Icons.person, size: 27)),
          )
        ],
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
      body: Column(children: [
        Expanded(
          child: Center(
              child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("Posts")
                .orderBy("timestamp", descending: true)
                .get(),
            builder: (context, AsyncSnapshot data) {
              if (data.hasData ||
                  data.connectionState == ConnectionState.done) {
                var postdata = data.requireData;
                return ListView.builder(
                    itemCount: postdata.size,
                    itemBuilder: (context, index) {
                      if (index.toString() == "0") {
                        return Center(
                            child: Column(
                          children: [
                            stories(),
                            postFilter(),
                            post(
                                postdata.docs[index]["UID"],
                                postdata.docs[index]["image"],
                                postdata.docs[index]["ups"],
                                postdata.docs[index]["downs"],
                                postdata.docs[index].id.toString(),
                                postdata.docs[index]["caption"],
                                postdata.docs[index]["comments"],
                                postdata.docs[index]["date"])
                          ],
                        ));
                      } else {
                        return post(
                            postdata.docs[index]["UID"],
                            postdata.docs[index]["image"],
                            postdata.docs[index]["ups"],
                            postdata.docs[index]["downs"],
                            postdata.docs[index].id.toString(),
                            postdata.docs[index]["caption"],
                            postdata.docs[index]["comments"],
                            postdata.docs[index]["date"]);
                      }
                    });
              }

              return Center(
                child: Text("Nessun Post"),
              );
            },
          )),
        ),
        Container(
            color: Color.fromRGBO(0, 191, 180, 2),
            child: NavigationBar(widget.user))
      ]),
    )
        /*: Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(0, 158, 149, 2),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text("Elba",
                      style: TextStyle(fontSize: 25, color: Colors.white)),
                  Text("Share",
                      style: TextStyle(
                          fontSize: 25,
                          color: Color.fromRGBO(255, 147, 147, 2),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            body: Image(
              fit: BoxFit.cover,
              image: AssetImage("images/denied.jpg"),
            ),
          )*/
        ;
  }
}
