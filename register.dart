import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'auth.dart';
import 'login.dart';
import 'mainPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'register.dart';
import 'tutorial.dart';

class LinkTextSpan extends TextSpan {
  LinkTextSpan({url, text})
      : super(
            style: TextStyle(color: Colors.red),
            text: text ?? url,
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                launch(url);
              });
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  dynamic confirmPassword = GlobalKey();
  dynamic email = GlobalKey();
  dynamic password = GlobalKey();
  var error;

  void click() {
    final emailText = emailController.text;
    final passwordText = passwordController.text;
    register(emailText.trim(), passwordText).then((value) => {
          value != "error"
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          RegistrationSuccess(emailText, passwordText)))
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegistrationFailed())),
        });
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
    setState(() {});
    if (email.currentState!.validate() &&
        password.currentState!.validate() &&
        confirmPassword.currentState.validate()) {
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
                              padding: const EdgeInsets.only(bottom: 28.0),
                              child: RichText(
                                text: TextSpan(
                                  text: "Registrandoti accetti le ",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                  children: <TextSpan>[
                                    LinkTextSpan(
                                        url:
                                            'https://deniscraciun.com/privacy.pdf',
                                        text: 'Privacy Politics'),
                                  ],
                                ),
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () => {click()},
                                  child: Text("Accetto",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 13))),
                              TextButton(
                                  onPressed: () => {Navigator.pop(context)},
                                  child: Text("Non accetto",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 13))),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ));
          });
    } else {
      print("Form Error");
    }
  }

  void updateError() {
    setState(() {
      this.error = "User not found";
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
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 20),
              child: Container(
                width: 250,
                child: TextFormField(
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  cursorColor: Color.fromRGBO(255, 147, 147, 2),
                  key: confirmPassword,
                  controller: confirmPasswordController,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return "Le password devono coincidere";
                    }
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(255, 147, 147, 2),
                            width: 2.0),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      hintText: "Confirm Password",
                      border: OutlineInputBorder()),
                ),
              ),
            ),
            showAlert(),
            FloatingActionButton(
              backgroundColor: Color.fromRGBO(255, 147, 147, 2),
              onPressed: () => {setState(() {}), this.validate()},
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
          child: Text("Register",
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
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        width: 250,
        child: TextFormField(
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          cursorColor: Color.fromRGBO(255, 147, 147, 2),
          key: password,
          validator: (value) {
            if (value!.length < 6) {
              return "La password deve essere lunga almeno 6 caratteri";
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Center(
              child: RichText(
            text: TextSpan(
              text: "Già registrato? ",
              style: TextStyle(fontSize: 16, color: Colors.white),
              children: <TextSpan>[
                TextSpan(
                    text: 'Accedi ',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                    style: TextStyle(
                        color: Color.fromRGBO(255, 147, 147, 2),
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ),
      ],
    );
  }
}

class RegistrationSuccess extends StatelessWidget {
  final email;
  final password;

  RegistrationSuccess(this.email, this.password);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Ti sei registrato correttamente.",
                style: TextStyle(fontSize: 16)),
            Text("Per accedere c'è bisogno di verificare la tua mail",
                style: TextStyle(fontSize: 16)),
            TextButton(
                onPressed: () => {
                      logIn(email, password),
                      sendEmailVerification(FirebaseAuth.instance.currentUser!),
                      signOut(),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()))
                    },
                child: Text("Manda email di conferma",
                    style: TextStyle(fontSize: 20)))
          ],
        ),
      ),
    );
  }
}

class RegistrationFailed extends StatefulWidget {
  const RegistrationFailed({Key? key}) : super(key: key);

  @override
  _RegistrationFailedState createState() => _RegistrationFailedState();
}

class _RegistrationFailedState extends State<RegistrationFailed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(
            text: "Hai già creato un account con questa mail. ",
            style: TextStyle(fontSize: 16, color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                  text: 'Login ',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                  style: TextStyle(
                    color: Colors.red,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
