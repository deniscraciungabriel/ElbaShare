import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbashare/database.dart';
import 'package:elbashare/profile.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';

import 'mainPage.dart';

class NotificationPage extends StatefulWidget {
  final user;

  NotificationPage(this.user);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool delete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            SizedBox(
              width: 35,
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
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(widget.user.uid)
                .collection("Notifications")
                .snapshots(),
            builder: (context, AsyncSnapshot data) {
              if (data.hasData) {
                var notifications = data.requireData;

                return ListView.builder(
                  itemCount: notifications.size,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () => {
                                          this.setState(() {
                                            delete = !delete;
                                          })
                                        },
                                    icon: Icon(
                                      MdiIcons.deleteCircleOutline,
                                      size: 30,
                                      color: delete == true
                                          ? Colors.red
                                          : Colors.black,
                                    )),
                                delete == true
                                    ? TextButton(
                                        child: Text(
                                          "Svuota",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () => {
                                              this.setState(() {
                                                deleteNotifications();
                                              })
                                            })
                                    : Container()
                              ],
                            ),
                          ),
                          notifications.docs[index]["image"] != null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 8),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(notifications.docs[index]
                                              ["message"]),
                                          new Spacer(),
                                          Image(
                                            image: Image.network(notifications
                                                    .docs[index]["image"])
                                                .image,
                                            width: 50,
                                          ),
                                        ],
                                      ),
                                      Divider()
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18.0, vertical: 8),
                                      child: Row(
                                        children: [
                                          Text(notifications.docs[index]
                                              ["message"]),
                                          new Spacer(),
                                          FutureBuilder(
                                              future: FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(notifications.docs[index]
                                                      ["uid"])
                                                  .get(),
                                              builder: (context,
                                                  AsyncSnapshot data) {
                                                if (data.hasData) {
                                                  var userImage =
                                                      data.requireData;

                                                  return CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage:
                                                        Image.network(userImage[
                                                                "ImageURL"])
                                                            .image,
                                                  );
                                                } else {
                                                  return CircleAvatar(
                                                    backgroundImage: AssetImage(
                                                        "image/take1.jpg"),
                                                    radius: 30,
                                                  );
                                                }
                                              })
                                        ],
                                      ),
                                    ),
                                    Divider()
                                  ],
                                )
                        ],
                      );
                    } else {
                      return notifications.docs[index]["image"] != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                          notifications.docs[index]["message"]),
                                      new Spacer(),
                                      Image(
                                        image: Image.network(notifications
                                                .docs[index]["image"])
                                            .image,
                                        width: 50,
                                      ),
                                    ],
                                  ),
                                  Divider()
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                          notifications.docs[index]["message"]),
                                      new Spacer(),
                                      FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(notifications.docs[index]
                                                  ["uid"])
                                              .get(),
                                          builder:
                                              (context, AsyncSnapshot data) {
                                            if (data.hasData) {
                                              var userImage = data.requireData;

                                              return CircleAvatar(
                                                radius: 30,
                                                backgroundImage: Image.network(
                                                        userImage["ImageURL"])
                                                    .image,
                                              );
                                            } else {
                                              return CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    "image/take1.jpg"),
                                                radius: 30,
                                              );
                                            }
                                          })
                                    ],
                                  ),
                                ),
                                Divider()
                              ],
                            );
                    }
                  },
                );
              } else {
                return Center(
                  child: Text("Non hai nessuna notifica"),
                );
              }
            }));
  }
}
