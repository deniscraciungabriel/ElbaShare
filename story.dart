import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

import 'mainPage.dart';

class StoryPage extends StatefulWidget {
  final authorUid;
  final user;

  StoryPage(this.authorUid, this.user);

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final controller = StoryController();
  List<StoryItem> stories = [];
  var viewed = [];

  Stream<QuerySnapshot> get returnStories {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(widget.authorUid)
        .collection("Stories")
        .snapshots();
  }

  void initState() {
    super.initState();
    returnStories.listen((event) {
      event.docs.forEach((element) {
        stories.add(element["caption"] == null
            ? StoryItem.pageImage(url: element["image"], controller: controller)
            : StoryItem.pageImage(
                url: element["image"],
                controller: controller,
                caption: element["caption"]));
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (stories.length > 0) {
      return widget.authorUid != widget.user.uid
          ? Material(
              child: StoryView(
                storyItems: stories,
                controller: controller,
                inline: false,
                repeat: false,
                onComplete: () => {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: MainPage(widget.user)))
                },
              ),
            )
          : Material(
              child: Column(
                children: [
                  StoryView(
                    storyItems: stories,
                    controller: controller,
                    inline: false,
                    repeat: false,
                    onComplete: () => {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: MainPage(widget.user)))
                    },
                  ),
                ],
              ),
            );
    } else {
      return Scaffold();
    }
  }
}
