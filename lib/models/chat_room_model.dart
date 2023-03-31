class ChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  DateTime? lastDate;
  List<dynamic>? user;

  ChatRoomModel({this.chatRoomId, this.participants,this.lastMessage,this.lastDate,this.user});

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastDate': lastDate,
      'user': user,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      chatRoomId: map['chatRoomId'] as String,
      lastMessage: map['lastMessage'] as String,
      user: map['user'],
      participants: map['participants'] as Map<String, dynamic>,
      lastDate: map['lastDate'].toDate(),
    );
  }
}
