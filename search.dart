import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'database.dart';
import 'mainPage.dart';
import 'profile.dart';
import 'search2.dart';
import 'user.dart';
import 'dart:ffi';
import 'database.dart';

class SearchPage extends StatefulWidget {
  final user;

  SearchPage(this.user);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController controller = new TextEditingController();
  bool showusers = true;

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
                            child: MainPage(FirebaseAuth.instance.currentUser),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 70),
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Search2Page(widget.user, controller.text)))
                      },
                    ),
                    hintText: "Username",
                    border: new OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black38),
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ),
          userList(widget.user)
        ],
      ),
    );
  }
}

Widget search(user) {
  final Stream<QuerySnapshot> userSnaps = FirebaseFirestore.instance
      .collection("users")
      .where("username", isEqualTo: "Denis")
      .snapshots();
  return Expanded(
    child: StreamBuilder(
        stream: userSnaps,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text("Qualcosa è andato storto");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final data = snapshot.requireData;

          return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .get(),
              builder: (context, AsyncSnapshot snapshot2) {
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                final collection = snapshot2.requireData;
                return Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: ListView.builder(
                    itemCount: data.size,
                    itemBuilder: (context, index) {
                      return user.uid == data.docs[index]["UID"]
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black38),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: CircleAvatar(
                                        backgroundImage: Image.network(
                                                data.docs[index]["ImageURL"])
                                            .image,
                                        radius: 30,
                                      ),
                                    ),
                                    Text(
                                      data.docs[index]["username"],
                                    ),
                                    new Spacer(),
                                    !collection["Contacts"]
                                            .contains(data.docs[index]["UID"])
                                        ? Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: FloatingActionButton(
                                              onPressed: () => {
                                                print("ok"),
                                                UserData(user.uid, user.email)
                                                    .addContact(
                                                        data.docs[index]["UID"])
                                              },
                                              child: Icon(Icons.add),
                                              mini: true,
                                            ),
                                          )
                                        : Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: FloatingActionButton(
                                              onPressed: () => {
                                                print("ok"),
                                                UserData(user.uid, user.email)
                                                    .removeContact(
                                                        data.docs[index]["UID"])
                                              },
                                              child: Icon(Icons.remove),
                                              mini: true,
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
                );
              });
        }),
  );
}

Widget userList(user) {
  var username;

  getUsername() async {
    var dataUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    username = dataUser["username"];
  }

  ;

  getUsername();
  final Stream<QuerySnapshot> userSnaps =
      FirebaseFirestore.instance.collection("users").snapshots();
  return Expanded(
    child: StreamBuilder(
        stream: userSnaps,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final data = snapshot.requireData;

          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot2) {
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                final collection = snapshot2.requireData;
                return Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: ListView.builder(
                    itemCount: data.size,
                    itemBuilder: (context, index) {
                      return user.uid == data.docs[index]["UID"]
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black38),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType
                                                    .leftToRightWithFade,
                                                child: ProfilePage(
                                                    FirebaseAuth
                                                        .instance.currentUser,
                                                    data.docs[index]["UID"]),
                                                duration: Duration(
                                                    milliseconds: 550)))
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: CircleAvatar(
                                          backgroundImage: Image.network(
                                                  data.docs[index]["ImageURL"])
                                              .image,
                                          radius: 30,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType
                                                    .leftToRightWithFade,
                                                child: ProfilePage(
                                                    FirebaseAuth
                                                        .instance.currentUser,
                                                    data.docs[index]["UID"]),
                                                duration: Duration(
                                                    milliseconds: 550)))
                                      },
                                      child: Text(
                                        data.docs[index]["username"],
                                      ),
                                    ),
                                    new Spacer(),
                                    !collection["Followed"]
                                            .contains(data.docs[index]["UID"])
                                        ? Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: FloatingActionButton(
                                              backgroundColor: Color.fromRGBO(
                                                  0, 158, 149, 2),
                                              onPressed: () => {
                                                follow(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    data.docs[index]["UID"],
                                                    username)
                                              },
                                              child: Icon(Icons.add),
                                              mini: true,
                                            ),
                                          )
                                        : Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: FloatingActionButton(
                                              backgroundColor: Color.fromRGBO(
                                                  0, 158, 149, 2),
                                              onPressed: () => {
                                                followDown(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    data.docs[index]["UID"])
                                              },
                                              child: Icon(Icons.remove),
                                              mini: true,
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
                );
              });
        }),
  );
}
