import 'package:elbashare/database.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';

import 'mainPage.dart';

class StoryPostingPage extends StatefulWidget {
  final user;
  final url;

  StoryPostingPage(this.user, this.url);

  @override
  _StoryPostingPageState createState() => _StoryPostingPageState();
}

class _StoryPostingPageState extends State<StoryPostingPage> {
  bool typing = false;
  TextEditingController caption = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(child: Image(image: Image.network(widget.url).image)),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24, bottom: 2),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                      child: Icon(MdiIcons.cancel),
                      onPressed: () => {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: MainPage(widget.user)))
                          }),
                  FloatingActionButton(
                      child: Icon(MdiIcons.formatText),
                      onPressed: () => {
                            super.setState(() {
                              typing = !typing;
                            })
                          }),
                  FloatingActionButton(
                      child: Icon(Icons.arrow_forward_ios),
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
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.grey),
                                            padding: EdgeInsets.fromLTRB(
                                                20, 50, 20, 0),
                                            child: Column(
                                              children: [
                                                // ignore: prefer_const_constructors
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 28.0),
                                                  // ignore: prefer_const_constructors
                                                  child: Text(
                                                      "Sei sicuro di voler condividere la storia?",
                                                      // ignore: prefer_const_constructors
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
                                                              postStory(
                                                                  widget.url,
                                                                  widget
                                                                      .user.uid,
                                                                  caption.text !=
                                                                          ""
                                                                      ? caption
                                                                          .text
                                                                      : null),
                                                              Navigator.push(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .bottomToTop,
                                                                      child: MainPage(
                                                                          widget
                                                                              .user)))
                                                            },
                                                        child: const Text("Si",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 17))),
                                                    TextButton(
                                                        onPressed: () => {
                                                              Navigator.pop(
                                                                  context)
                                                            },
                                                        child: const Text("No",
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
                          })
                ],
              ),
            ),
          ),
          typing == true
              ? Container(
                  width: 330,
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                    child: TextField(
                        maxLength: 200,
                        controller: caption,
                        cursorColor: Color.fromRGBO(0, 158, 149, 2),
                        decoration: new InputDecoration(
                          hintText: "Inserisci una descrizione...",
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.white, width: 2.0),
                          ),
                        )),
                  ))
              : Container()
        ],
      ),
    );
  }
}
