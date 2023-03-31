import 'dart:async';
import 'dart:developer';

import 'package:chat_mate/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'complete_profile.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  UserCredential? credential;

  checkValues() {
    var email = emailController.text.toString().trim();
    var password = passwordController.text.toString().trim();
    var cPassword = confirmPasswordController.text.toString().trim();
    if (email == "" || password == "" || cPassword == "") {
      Fluttertoast.showToast(msg: "Please enter all fields");
    } else if (password != cPassword) {
      Fluttertoast.showToast(msg: "Password didn't matched");
    } else {
      isLoading = true;
      streamController.sink.add(isLoading);
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      isLoading = false;
      streamController.sink.add(isLoading);
      Fluttertoast.showToast(msg: "${ex.message}");
    }
    if (credential != null) {
      //isLoading = false;
      streamController.sink.add(isLoading);
      String uid = credential!.user!.uid;
      UserModel userModel =
          UserModel(uid: uid, email: email, fullName: "", profilePic: "",userStatus: true);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(userModel.toMap())
          .then((value) async {
        Fluttertoast.showToast(msg: "Registered successfully..");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => CompleteProfilePage(
                    userModel: userModel, firebaseUser: credential!.user!)));
      });
    }
  }

  bool isLoading = false;
  StreamController<bool> streamController = StreamController();
  late Stream myStream;

  @override
  void initState() {
    super.initState();
    myStream = streamController.stream.asBroadcastStream();
    isLoading = false;
    streamController.sink.add(isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/chat.png",
                    height: 80,
                    width: 80,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Chat Mate",
                    style: TextStyle(fontSize: 50, color: Colors.red),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(hintText: "Email Address"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(hintText: "Password"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    decoration:
                        const InputDecoration(hintText: "Confirm Password"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  StreamBuilder(
                    stream: myStream,
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? snapshot.data == true
                              ? SizedBox(
                                  width: 250,
                                  height: 50,
                                  child: CupertinoButton(
                                    color: Colors.red,
                                    onPressed: () {},
                                    child: const Center(
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  width: 250,
                                  height: 50,
                                  child: CupertinoButton(
                                    color: Colors.red,
                                    onPressed: () {
                                      checkValues();
                                    },
                                    child: const Text("Sign Up"),
                                  ),
                                )
                          : const SizedBox();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already have an Account?"),
          CupertinoButton(
              child: const Text("Login"),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
      ),
    );
  }
}
