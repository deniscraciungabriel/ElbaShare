// ignore: file_names
// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbashare/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ffi';

class CommentPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  final authorUID;
  final index;

  CommentPage(this.uid, this.authorUID, this.index);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Posts")
              .doc(widget.index
                  .toString()
                  .substring(widget.index.toString().length - 15))
              .collection("Comments")
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot data) {
            if (data.hasData) {
              var comment = data.requireData;
              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: comment.size,
                    itemBuilder: (BuildContext context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 0),
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(
                                                  comment.docs[index]["Author"])
                                              .get(),
                                          builder:
                                              (context, AsyncSnapshot data) {
                                            if (data.hasData) {
                                              var user = data.requireData;
                                              var url = user["ImageURL"];
                                              return CircleAvatar(
                                                backgroundImage: (url !=
                                                            "error" &&
                                                        url != null)
                                                    ? Image.network(url!).image
                                                    : AssetImage(
                                                        "images/take1.jpg"),
                                                radius: 20,
                                              );
                                            } else {
                                              return Container();
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: FutureBuilder<DocumentSnapshot>(
                                          future: FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(
                                                  comment.docs[index]["Author"])
                                              .get(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshot) {
                                            dynamic data = "";
                                            if (snapshot.data != null) {
                                              data = snapshot.data!.data()
                                                  as Map<String, dynamic>;
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text(
                                                  data != ""
                                                      ? data["username"]
                                                      : "ciao",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 4),
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      comment.docs[index]["Text"],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                comment.docs[index]["Author"] == widget.uid
                                    ? TextButton(
                                        onPressed: () => {
                                              showDialog(
                                                  context: this.context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                        backgroundColor:
                                                            Colors.grey,
                                                        insetPadding:
                                                            EdgeInsets.all(10),
                                                        child: Stack(
                                                          overflow:
                                                              Overflow.visible,
                                                          alignment:
                                                              Alignment.center,
                                                          children: <Widget>[
                                                            Container(
                                                              width: 300,
                                                              height: 200,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                  color: Colors
                                                                      .grey),
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          20,
                                                                          50,
                                                                          20,
                                                                          0),
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            28.0),
                                                                    child: Text(
                                                                        "Sei sicuro di voler cancellare il commento?",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color: Colors
                                                                                .black),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      TextButton(
                                                                          onPressed: () =>
                                                                              {
                                                                                deleteCommentFunc(widget.uid, comment.docs[index]["Text"], widget.index.toString().substring(widget.index.toString().length - 15), widget.authorUID),
                                                                                Navigator.pop(context)
                                                                              },
                                                                          child: Text(
                                                                              "Si",
                                                                              style: TextStyle(color: Colors.black, fontSize: 17))),
                                                                      TextButton(
                                                                          onPressed: () =>
                                                                              {
                                                                                Navigator.pop(context)
                                                                              },
                                                                          child: Text(
                                                                              "No",
                                                                              style: TextStyle(color: Colors.black, fontSize: 17))),
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
                                                color: Color.fromRGBO(
                                                    255, 147, 147, 2))))
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  new Spacer(),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 18.0, left: 5, right: 5),
                    child: Container(
                        child: TextField(
                      controller: controller,
                      maxLength: 100,
                      decoration: InputDecoration(
                          prefixIcon: IconButton(
                              onPressed: () => {Navigator.pop(context)},
                              icon: Icon(Icons.home)),
                          suffixIcon: IconButton(
                              onPressed: () => {
                                    commentFunc(
                                        widget.uid,
                                        controller.text,
                                        widget.index.toString().substring(
                                            widget.index.toString().length -
                                                15),
                                        widget.authorUID),
                                    controller.clear()
                                  },
                              icon: Icon(Icons.send),
                              color: Color.fromRGBO(255, 147, 147, 2)),
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(255, 147, 147, 2),
                                width: 2.0),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          hintText: "Inserisci un commento",
                          border: OutlineInputBorder()),
                    )),
                  )
                ],
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
