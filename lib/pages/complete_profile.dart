import 'dart:async';

import 'package:chat_mate/models/user_model.dart';
import 'package:chat_mate/pages/my_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class CompleteProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfilePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  TextEditingController fullNameController = TextEditingController();

  File? imageFile;

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper.platform.cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a photo"),
                ),
              ],
            ),
          );
        });
  }

  bool isLoading = false;
  StreamController<bool> streamController = StreamController();
  late Stream myStream;

  checkValues() {
    var fullName = fullNameController.text.toString().trim();
    if (fullName == "") {
      Fluttertoast.showToast(msg: "Please enter full name");
    } else if (imageFile == null) {
      Fluttertoast.showToast(msg: "Please select an image");
    } else {
      isLoading = true;
      streamController.sink.add(isLoading);
      uploadData(fullName, imageFile);
    }
  }

  uploadData(String fullName, File? imageFile) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilePictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullName = fullNameController.text.trim();
    widget.userModel.fullName = fullName;
    widget.userModel.profilePic = imageUrl;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      Fluttertoast.showToast(msg: "profile Successfully added");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return MyHomePage(
              userModel: widget.userModel, firebaseUser: widget.firebaseUser);
        }),
      );
    });
  }

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
      appBar: AppBar(
        title: const Text("Complete Profile"),
      ),
      body: SafeArea(
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
                  height: 50,
                ),
                Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    ClipOval(
                      child: Container(
                        width: 120,
                        height: 120,
                        color: Colors.red.shade100,
                        child: imageFile != null
                            ? Image.file(imageFile!)
                            : Image.asset("assets/images/profile.png"),
                      ),
                    ),
                    ClipOval(
                      child: InkWell(
                        onTap: () {
                          showPhotoOptions();
                        },
                        child: Container(
                          alignment: Alignment.bottomRight,
                          width: 40,
                          height: 40,
                          color: Colors.white70,
                          child:
                              const Center(child: Icon(CupertinoIcons.camera)),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(hintText: "Full Name"),
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
                                  child: const Text("Submit"),
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
    );
  }
}
