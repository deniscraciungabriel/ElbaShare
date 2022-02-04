import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:io';
import 'database.dart';
import 'mainPage.dart';
import 'profile.dart';

class PostingPage extends StatefulWidget {
  final user;
  final url;

  PostingPage(this.user, this.url);

  @override
  _PostingPageState createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  TextEditingController caption = new TextEditingController();

  Widget textBar() {
    return Container(
        width: 330,
        height: 400,
        child: TextField(
            maxLength: 200,
            controller: caption,
            cursorColor: Color.fromRGBO(0, 158, 149, 2),
            decoration: new InputDecoration(
              hintText: "Inserisci una descrizione...",
              enabledBorder: const OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color.fromRGBO(255, 147, 147, 2), width: 2.0),
              ),
            )));
  }

  Widget image() {
    return widget.url != null
        ? Padding(
            padding: const EdgeInsets.only(left: 28.0, right: 28, bottom: 35),
            child: Container(
              child: AspectRatio(
                aspectRatio: 3 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image(
                    image: Image.network(widget.url).image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  Widget postButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 48.0),
        child: TextButton(
            onPressed: () => {
                  showDialog(
                      context: context,
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
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.grey),
                                  padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 28.0),
                                        child: Text(
                                            "Sei sicuro di voler condividere il post?",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black),
                                            textAlign: TextAlign.center),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                              onPressed: () => {
                                                    post(
                                                        widget.url,
                                                        widget.user.uid,
                                                        caption.text),
                                                    Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            type:
                                                                PageTransitionType
                                                                    .fade,
                                                            child: MainPage(
                                                                widget.user),
                                                            duration: Duration(
                                                                milliseconds:
                                                                    550)))
                                                  },
                                              child: Text("Si",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17))),
                                          TextButton(
                                              onPressed: () =>
                                                  {Navigator.pop(context)},
                                              child: Text("No",
                                                  style: TextStyle(
                                                      color: Colors.black,
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
            child: Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Text("Condividi",
                  style: TextStyle(
                      fontSize: 17, color: Color.fromRGBO(255, 147, 147, 2))),
            )),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            postButton(),
            image(),
            textBar(),
          ]),
        ));
  }
}
