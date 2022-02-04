import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future register(email, password) async {
  try {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return _auth.currentUser;
  } on FirebaseAuthException catch (e) {
    return "error";
  }
}

sendEmailVerification(user) {
  user.sendEmailVerification();
}

Future logIn(email, password) async {
  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    print(e.message);
  }

  if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
    return _auth.currentUser;
  } else {
    return null;
  }

  return _auth.currentUser;
}

Future signOut() async {
  await _auth.signOut();
  return _auth.currentUser;
}
