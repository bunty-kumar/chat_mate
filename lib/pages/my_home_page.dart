import 'package:chat_mate/helper/firebase_helper.dart';
import 'package:chat_mate/models/chat_room_model.dart';
import 'package:chat_mate/models/user_model.dart';
import 'package:chat_mate/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_room.dart';
import 'login_page.dart';

class MyHomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyHomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Chat Mate"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    }),
                  );
                },
                child: Icon(Icons.logout)),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chatRooms")
            .where("user", arrayContains: widget.userModel.uid)
            .orderBy("lastDate")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
              return ListView.separated(
                itemCount: dataSnapshot.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                      dataSnapshot.docs[index].data() as Map<String, dynamic>);
                  Map<String, dynamic> participants =
                      chatRoomModel.participants!;
                  List<String> participantKey = participants.keys.toList();
                  participantKey.remove(widget.userModel.uid);
                  return FutureBuilder(
                      future:
                          FirebaseHelper.getUserModelById(participantKey[0]),
                      builder: (context, data) {
                        if (data.connectionState == ConnectionState.done) {
                          if (data.data != null) {
                            UserModel targetUser = data.data as UserModel;
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ChatRoom(
                                              userModel: widget.userModel,
                                              firebaseUser: widget.firebaseUser,
                                              targetUserModel: targetUser,
                                              chatRoomModel: chatRoomModel,
                                            )));
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(8),
                                  leading: ClipOval(
                                      child: Image.network(
                                    targetUser.profilePic!,
                                    width: 40,
                                    height: 40,
                                  )),
                                  title: Text(targetUser.fullName!),
                                  subtitle: chatRoomModel
                                          .lastMessage!.isNotEmpty
                                      ? Text(chatRoomModel.lastMessage!)
                                      : const Text(
                                          "Say hi to yor friend",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                  trailing: showDate(chatRoomModel
                                      .lastDate.toString())
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      });
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return const Center(child: Text("No Chats"));
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => SearchPage(
                        userModel: widget.userModel,
                        firebaseUser: widget.firebaseUser,
                      )));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.chat),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget showDate(String lastDate) {
    var date = DateFormat('dd-MM-yyyy, hh:mm a').format(DateTime.parse(lastDate).toLocal());
    var splitDate = date.split(",");
    String todayDate =  DateFormat('dd-MM-yyyy').format(DateTime.now());
    if(splitDate[0] == todayDate){
      return Text("${splitDate[0]} \n ${splitDate[1]}");
    }else{
      return Text("Today:${splitDate[0]}");
    }
  }
}
