class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;

  MessageModel(
      {this.sender, this.text, this.seen, this.createdOn, this.messageId});

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'text': text,
      'seen': seen,
      'createdOn': createdOn,
      'messageId': messageId,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      sender: map['sender'] as String,
      text: map['text'] as String,
      seen: map['seen'] as bool,
      createdOn: map['createdOn'].toDate(),
      messageId: map['messageId'] as String,
    );
  }
}
