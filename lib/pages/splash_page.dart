import 'package:chat_mate/helper/firebase_helper.dart';
import 'package:chat_mate/models/user_model.dart';
import 'package:chat_mate/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'complete_profile.dart';
import 'my_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    openScreen();
  }

  void openScreen() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      UserModel? userModel =
          await FirebaseHelper.getUserModelById(currentUser.uid);
      if (userModel != null) {
        if (userModel.fullName!.isNotEmpty || userModel.profilePic!.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 2400), () async {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => MyHomePage(
                          userModel: userModel,
                          firebaseUser: currentUser,
                        )));
          });
        } else {
          Future.delayed(const Duration(milliseconds: 2400), () async {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => CompleteProfilePage(
                        userModel: userModel, firebaseUser: currentUser)));
          });
        }
      } else {
        Future.delayed(const Duration(milliseconds: 2400), () async {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const LoginPage()));
        });
      }
    } else {
      Future.delayed(const Duration(milliseconds: 2400), () async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const LoginPage()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/chat.png",
                height: 80,
                width: 80,
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Chat Mate",
                style: TextStyle(fontSize: 50, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
