import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'changeBio.dart';
import 'login.dart';
import 'mainPage.dart';
import 'navBar.dart';
import 'auth.dart';

class SettingsPage extends StatefulWidget {
  final user;
  final bio;
  final url;

  SettingsPage(this.user, this.bio, this.url);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _switchValue = true;

  Future<Widget> maps() async {
    DocumentSnapshot allow = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    bool valueD = allow["Allow"];
    return ListTile(
      contentPadding: EdgeInsets.only(left: 30),
      title: Row(
        children: [
          Text("Mostra posizione sulla mappa"),
          new Spacer(),
          CupertinoSwitch(
            value: valueD,
            onChanged: (value) => {
              valueD == true
                  ? FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({"Allow": false})
                  : FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({"Allow": true}),
              (context as Element).reassemble()
            },
          ),
        ],
      ),
    );
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
          padding: const EdgeInsets.only(top: 18.0),
          child: Column(children: [
            Expanded(
                child: ListView(
              children: [
                bio(context, widget),
                FutureBuilder(
                  future: maps(),
                  builder:
                      (BuildContext context, AsyncSnapshot<Widget> widget) {
                    if (widget.hasData) {
                      return widget.requireData;
                    } else {
                      return Container();
                    }
                  },
                ),
                profilePic(context, widget),
                new Spacer(),
              ],
            )),
            signOutButton(context),
            NavigationBar(widget.user)
          ]),
        ));
  }
}

Widget bio(context, widget) {
  return ListTile(
    contentPadding: EdgeInsets.only(left: 30),
    title: Row(
      children: [
        Text("Modifica bio"),
        new Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
              onPressed: () => {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.leftToRightWithFade,
                            child: BioPage(widget.user, widget.bio, widget.url),
                            duration: Duration(milliseconds: 550)))
                  },
              icon: Icon(MdiIcons.pencil)),
        )
      ],
    ),
  );
}

Widget profilePic(context, widget) {
  return ListTile(
      contentPadding: EdgeInsets.only(left: 30),
      title: Row(
        children: [
          Text("Modifica foto profilo"),
          new Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.leftToRightWithFade,
                              child:
                                  BioPage(widget.user, widget.bio, widget.url),
                              duration: Duration(milliseconds: 550)))
                    },
                icon: Icon(Icons.camera_alt)),
          )
        ],
      ));
}

Widget signOutButton(context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Container(
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Color.fromRGBO(255, 147, 147, 2)),
          borderRadius: BorderRadius.circular(5)),
      child: TextButton(
          child: Text("Log Out",
              style: TextStyle(
                  color: Color.fromRGBO(255, 147, 147, 2),
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
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
                                          "Sei sicuro di voler condividere fare il Log Out?",
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
                                                  signOut(),
                                                  Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          type: PageTransitionType
                                                              .leftToRightWithFade,
                                                          child: LoginPage(),
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
              }),
    ),
  );
}
