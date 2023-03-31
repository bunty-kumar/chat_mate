import 'package:chat_mate/main.dart';
import 'package:chat_mate/models/chat_room_model.dart';
import 'package:chat_mate/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class ChatRoom extends StatefulWidget {
  final UserModel targetUserModel;
  final UserModel userModel;
  final User firebaseUser;
  final ChatRoomModel chatRoomModel;

  const ChatRoom(
      {Key? key,
      required this.userModel,
      required this.firebaseUser,
      required this.targetUserModel,
      required this.chatRoomModel})
      : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController messageController = TextEditingController();

  sendMessage() async {
    var message = messageController.text.toString().trim();
    messageController.clear();
    if (message != "") {
      MessageModel messageModel = MessageModel(
          messageId: uuid.v1(),
          sender: widget.userModel.uid,
          createdOn: DateTime.now(),
          text: message,
          seen: false);
      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoomModel.chatRoomId)
          .collection("messages")
          .doc(messageModel.messageId)
          .set(messageModel.toMap());

      widget.chatRoomModel.lastMessage = message;
      widget.chatRoomModel.lastDate = DateTime.now();
      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoomModel.chatRoomId)
          .set(widget.chatRoomModel.toMap());

      print("message sent successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.targetUserModel.profilePic!),
            ),
            const SizedBox(
              width: 12,
            ),
            widget.targetUserModel.userStatus!
                ? Container(
                    width: 10,
                    height: 10,
              color: Colors.green,
                  )
                : Container(
                    width: 10,
                    height: 10,
              color: Colors.grey,
                  ),
            const SizedBox(
              width: 12,
            ),
            Text(widget.targetUserModel.fullName!)
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade50,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatRooms")
                    .doc(widget.chatRoomModel.chatRoomId)
                    .collection("messages")
                    .orderBy("createdOn", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      return ListView.builder(
                        reverse: true,
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          MessageModel currentMessage = MessageModel.fromMap(
                              dataSnapshot.docs[index].data()
                                  as Map<String, dynamic>);
                          return Row(
                            mainAxisAlignment:
                                currentMessage.sender == widget.userModel.uid
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  color: currentMessage.sender ==
                                          widget.userModel.uid
                                      ? Colors.grey.shade300
                                      : Colors.red.shade100,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                child: Text(
                                  currentMessage.text.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text(
                              "some error occured! please check your internet connection"));
                    } else {
                      return const Center(child: Text("say hi to your friend"));
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            )),
            Container(
              color: Colors.white70,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Row(
                children: [
                  Flexible(
                      child: TextField(
                    controller: messageController,
                    maxLines: null,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Write Here.."),
                  )),
                  InkWell(
                    onTap: () {
                      sendMessage();
                    },
                    child: const Icon(
                      Icons.send,
                      color: Colors.red,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
