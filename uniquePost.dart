// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbashare/navBar.dart';
import 'package:elbashare/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';

import 'commentPage.dart';
import 'database.dart';
import 'mainPage.dart';
import 'profile.dart';

class UniquePost extends StatefulWidget {
  final uid;
  final url;
  final ups;
  final downs;
  final index;
  final caption;
  final comments;
  final date;

  UniquePost(this.uid, this.url, this.ups, this.downs, this.index, this.caption,
      this.comments, this.date);

  @override
  _UniquePostState createState() => _UniquePostState();
}

class _UniquePostState extends State<UniquePost> {
  late String username;

  getUsername() async {
    var dataUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    this.username = dataUser["username"];
  }

  Widget post(uid, url, ups, downs, index, caption, comments, date) {
    getUsername();
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
                          onTap: () => {null},
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
                    future: FirebaseFirestore.instance
                        .collection("users")
                        .doc(uid)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      dynamic data = "";
                      if (snapshot.data != null) {
                        data = snapshot.data!.data() as Map<String, dynamic>;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(data != "" ? data["username"] : "ciao",
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
                              .doc(FirebaseAuth.instance.currentUser!.uid)
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
                                                : () => {},
                                            (context as Element).reassemble()
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
                                                : () => {},
                                            (context as Element).reassemble()
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
                              .doc(FirebaseAuth.instance.currentUser!.uid)
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
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
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
                                                              delete(
                                                                  index
                                                                      .toString(),
                                                                  ups,
                                                                  url),
                                                              Navigator.pop(
                                                                  context),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              child:
                                  MainPage(FirebaseAuth.instance.currentUser!),
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
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: post(widget.uid, widget.url, widget.ups, widget.downs,
                    widget.index, widget.caption, widget.comments, widget.date),
              ),
            ),
          ],
        ));
  }
}
