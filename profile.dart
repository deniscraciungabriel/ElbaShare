import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbashare/auth.dart';
import 'package:elbashare/database.dart';
import 'package:elbashare/login.dart';
import 'package:elbashare/uniquePost.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:ffi';
import 'mainPage.dart';
import 'navBar.dart';
import 'notification_page.dart';
import 'settings.dart';

class ProfilePage extends StatefulWidget {
  final user;
  var uid = null;

  ProfilePage(this.user, [this.uid]);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var imageUrl;
  late String username;

  void initState() {
    super.initState();
    getUsername();
  }

  getUsername() async {
    var dataUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user.uid)
        .get();
    this.username = dataUser["username"];
  }

  Widget posts() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uid == null ? widget.user.uid : widget.uid)
            .collection("Posts")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot data) {
          if (data.hasData) {
            var postdata = data.requireData;
            return GridView.count(
              crossAxisCount: 3,
              children: List.generate(postdata.size, (index) {
                return GestureDetector(
                  onTap: () => {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: UniquePost(
                                postdata.docs[index]["UID"],
                                postdata.docs[index]["image"],
                                postdata.docs[index]["ups"],
                                postdata.docs[index]["downs"],
                                postdata.docs[index].id,
                                postdata.docs[index]["caption"],
                                postdata.docs[index]["comments"],
                                postdata.docs[index]["date"]),
                            duration: Duration(milliseconds: 350)))
                  },
                  child: Image(
                      fit: BoxFit.cover,
                      image:
                          Image.network(postdata.docs[index]["image"]).image),
                );
              }),
            );
          } else {
            return Center(child: Text("Nessun post"));
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                  onPressed: () => {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: NotificationPage(widget.user)))
                      },
                  icon:
                      Icon(Icons.notifications, size: 27, color: Colors.white)),
            ),
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
        // ignore: prefer_const_constructors
        body: Column(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(widget.uid != null ? widget.uid : widget.user.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot data) {
                  if (data.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (data.hasData) {
                    var userData = data.requireData;
                    var url = userData["ImageURL"];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 28.0, left: 28.0, top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundImage: (url != "error" && url != null)
                                    ? Image.network(url!).image
                                    : AssetImage("images/take1.jpg"),
                                radius: 60,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ProfileDetails(widget.user, widget.uid),
                                    widget.uid == widget.user.uid
                                        ? OutlinedButton(
                                            onPressed: () => {
                                                  Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          type:
                                                              PageTransitionType
                                                                  .fade,
                                                          child: SettingsPage(
                                                              widget.user,
                                                              userData["Bio"],
                                                              userData[
                                                                  "ImageURL"]),
                                                          duration: Duration(
                                                              milliseconds:
                                                                  250)))
                                                },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 18.0),
                                              child: Text("Modifica profilo",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromRGBO(
                                                          255, 107, 117, 20))),
                                            ))
                                        : (StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(widget.user.uid)
                                                .snapshots(),
                                            builder:
                                                (context, AsyncSnapshot data) {
                                              if (data.connectionState ==
                                                  ConnectionState.waiting) {
                                                return CircularProgressIndicator();
                                              }
                                              if (data.hasData) {
                                                var followed = data.requireData;

                                                if (followed["Followed"]
                                                    .toList()
                                                    .contains(widget.uid)) {
                                                  return OutlinedButton(
                                                      onPressed: () => {
                                                            followDown(
                                                                widget.user.uid,
                                                                widget.uid)
                                                          },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    28.0),
                                                        child: Text(
                                                            "Smetti di seguire",
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        255,
                                                                        107,
                                                                        117,
                                                                        20))),
                                                      ));
                                                } else {
                                                  return OutlinedButton(
                                                      onPressed: () => {
                                                            follow(
                                                                widget.user.uid,
                                                                widget.uid,
                                                                username)
                                                          },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    28.0),
                                                        child: Text("Segui",
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        255,
                                                                        107,
                                                                        117,
                                                                        20))),
                                                      ));
                                                }
                                              } else {
                                                return Container();
                                              }
                                            })),
                                    userData["Followed"]
                                            .contains(widget.user.uid)
                                        ? Text("Ti segue")
                                        : Container()
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Bio(userData["username"], userData["Bio"])
                      ],
                    );
                  } else {
                    return Container();
                  }
                }),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
            Expanded(child: posts()),
            NavigationBar(widget.user)
          ],
        ));
  }
}

class ProfileDetails extends StatefulWidget {
  final user;
  final uid;

  ProfileDetails(this.user, this.uid);

  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 20.0, bottom: 10),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(widget.uid != null ? widget.uid : widget.user.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot data) {
              if (data.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (data.hasData) {
                var user = data.requireData;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text("Post"),
                        Text(user["PostCount"].toString())
                      ],
                    ),
                    Column(
                      children: [Text("Ups"), Text(user["Ups"].toString())],
                    ),
                    Column(
                      children: [
                        Text("Followers"),
                        Text(user["Followers"].toString())
                      ],
                    )
                  ],
                );
              }
              return Container();
            }));
  }
}

class Bio extends StatefulWidget {
  var username;
  var bio;
  Bio(this.username, this.bio);

  @override
  _BioState createState() => _BioState();
}

class _BioState extends State<Bio> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.username,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(widget.bio != null ? widget.bio : ""),
        ],
      ),
    );
  }
}
