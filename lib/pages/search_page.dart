import 'dart:async';

import 'package:chat_mate/main.dart';
import 'package:chat_mate/models/chat_room_model.dart';
import 'package:chat_mate/pages/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

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

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoomModel;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
      ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoomModel = existingChatroom;
      print("already exists fetch ");
    } else {
      ChatRoomModel newChatRoomModel = ChatRoomModel(
          chatRoomId: uuid.v1(),
          lastMessage: "",
          lastDate: DateTime.now(),
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          },
          user: [
            widget.userModel.uid.toString(),
            targetUser.uid.toString()
          ]);
      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(newChatRoomModel.chatRoomId)
          .set(newChatRoomModel.toMap());
      chatRoomModel = newChatRoomModel;
      print("not exists");
      print("new chat room created");
    }
    return chatRoomModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where("email", isNotEqualTo: widget.userModel.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                if (dataSnapshot.docs.isNotEmpty) {
                  return ListView.builder(
                      itemCount: dataSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> userData = dataSnapshot
                            .docs[index].data() as Map<String, dynamic>;
                        UserModel searchedUser = UserModel.fromMap(
                            userData);
                        return InkWell(
                          onTap: () async {
                            ChatRoomModel? chatRoomModel =
                            await getChatRoomModel(searchedUser);
                            if (chatRoomModel != null) {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ChatRoom(
                                            userModel: widget.userModel,
                                            firebaseUser: widget
                                                .firebaseUser,
                                            targetUserModel: searchedUser,
                                            chatRoomModel: chatRoomModel,
                                          )));
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 8.0,
                                  ),
                                ]),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: ClipOval(
                                  child: Image.network(
                                    searchedUser.profilePic!,
                                    width: 40,
                                    height: 40,
                                  )),
                              title: Text(searchedUser.fullName!),
                              subtitle: Text(searchedUser.email!),
                              trailing: const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(CupertinoIcons.arrow_right),
                              ),
                            ),
                          ),
                        );
                      });
                } else {
                  return const Center(child: Text("No result found"));
                }
              } else if (snapshot.hasError) {
                return const Center(child: Text("No result found"));
              } else {
                return const Center(child: Text("No result found"));
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
