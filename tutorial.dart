// ignore_for_file: prefer_const_constructors
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';

import 'initialise.dart';

class TutorialPage extends StatelessWidget {
  final user;

  TutorialPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(0, 158, 149, 2),
        body: Column(
          children: [
            Expanded(
              child: Carousel(
                dotBgColor: Color.fromRGBO(0, 158, 149, 2),
                autoplay: false,
                images: [
                  ExactAssetImage("images/1.jpg"),
                  ExactAssetImage("images/2.jpeg"),
                  ExactAssetImage("images/3.jpg")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: TextButton(
                onPressed: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InitialisePage(user)))
                },
                child: Text("Skip",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromRGBO(0, 158, 149, 2))),
              ),
            ),
          ],
        ));
  }
}
