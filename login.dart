// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'mainPage.dart';
import 'register.dart';
import 'tutorial.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  dynamic email = GlobalKey();
  dynamic password = GlobalKey();
  var error;

  void click() async {
    final email = emailController.text;
    final password = passwordController.text;
    var users = FirebaseFirestore.instance.collection("users/");

    await logIn(email.trim(), password).then((user) =>
        user == null ? updateError() : checkExistance(user, user.uid));
  }

  Future<bool> checkExistance(user, uid) async {
    var collectionRef = FirebaseFirestore.instance.collection("users");
    var doc = await collectionRef.doc(uid).get();
    if (doc.exists) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainPage(user)));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => TutorialPage(user)));
    }
    return doc.exists;
  }

  void validate() {
    if (email.currentState!.validate()) {
      click();
    } else {
      print("Form Error");
    }
  }

  void updateError() {
    setState(() {
      this.error = "Utente non trovato o mail non verificata";
    });
    showAlert();
  }

  Widget showAlert() {
    if (error == null) {
      return SizedBox(
        height: 0,
      );
    } else {
      return Container(
          child: Text(
        error,
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(0, 158, 149, 2),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Title(),
            EmailForm(emailController, email),
            PasswordForm(passwordController, password),
            showAlert(),
            FloatingActionButton(
              backgroundColor: Color.fromRGBO(255, 147, 147, 2),
              onPressed: () => {this.validate()},
              child: Icon(Icons.check),
            ),
            Register()
          ],
        ));
  }
}

class Title extends StatelessWidget {
  const Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Text("Elba", style: TextStyle(fontSize: 45, color: Colors.white)),
            Text("Share",
                style: TextStyle(
                    fontSize: 45,
                    color: Color.fromRGBO(255, 147, 147, 2),
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 58.0, bottom: 10),
          child: Text("Login",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              )),
        )
      ],
    );
  }
}

class EmailForm extends StatelessWidget {
  TextEditingController controller;
  dynamic email;

  EmailForm(this.controller, this.email);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      child: TextFormField(
        cursorColor: Color.fromRGBO(255, 147, 147, 2),
        key: email,
        validator: (value) {
          if (value!.isEmpty || !value.contains("@") || !value.contains(".")) {
            return "Mail not valid";
          } else {
            return null;
          }
        },
        controller: controller,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Color.fromRGBO(255, 147, 147, 2), width: 2.0),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            hintText: "Email",
            border: OutlineInputBorder()),
      ),
    );
  }
}

class PasswordForm extends StatelessWidget {
  TextEditingController controller;
  dynamic password;

  PasswordForm(this.controller, this.password);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 20),
      child: Container(
        width: 250,
        child: TextFormField(
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          cursorColor: Color.fromRGBO(255, 147, 147, 2),
          key: password,
          validator: (value) {
            if (value!.isEmpty ||
                !value.contains("@") ||
                !value.contains(".")) {
              return "Mail not valid";
            } else {
              return null;
            }
          },
          controller: controller,
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color.fromRGBO(255, 147, 147, 2), width: 2.0),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              hintText: "Password",
              border: OutlineInputBorder()),
        ),
      ),
    );
  }
}

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Center(
          child: RichText(
        text: TextSpan(
          text: "Don't have and account? ",
          style: TextStyle(fontSize: 16, color: Colors.white),
          children: <TextSpan>[
            TextSpan(
                text: 'Register ',
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage()));
                  },
                style: TextStyle(
                    color: Color.fromRGBO(255, 147, 147, 2),
                    fontWeight: FontWeight.bold)),
          ],
        ),
      )),
    );
  }
}
