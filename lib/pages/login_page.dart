import 'dart:async';

import 'package:chat_mate/pages/sign_up_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../helper/firebase_helper.dart';
import '../models/user_model.dart';
import 'my_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UserCredential? credential;

  checkValues() {
    var email = emailController.text.toString().trim();
    var password = passwordController.text.toString().trim();
    if (email == "" || password == "") {
      Fluttertoast.showToast(msg: "Please enter all fields");
    } else {
      isLoading = true;
      streamController.sink.add(isLoading);
      login(email, password);
    }
  }

  updateStatus(bool status) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      UserModel? userModel = await FirebaseHelper.getUserModelById(currentUser.uid);
      userModel!.userStatus = status;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .set(userModel.toMap());
    }
  }

  void login(String email, String password) async {
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      isLoading = false;
      streamController.sink.add(isLoading);
      Fluttertoast.showToast(msg: "${ex.message}");
    }
    if (credential != null) {
      isLoading = false;
      streamController.sink.add(isLoading);
      String uid = credential!.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      UserModel userModel = UserModel.fromMap(userData.data() as Map<String, dynamic>);
      updateStatus(true);
      Fluttertoast.showToast(msg: "Login successfully..");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => MyHomePage(
                  userModel: userModel, firebaseUser: credential!.user!)));
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
                                    child: const Text("Login"),
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
          const Text("Don't have an Account?"),
          CupertinoButton(
              child: const Text("SignUp"),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const SignUpPage()));
              })
        ],
      ),
    );
  }
}
