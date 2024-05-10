class MessageModel {
  // final String messageId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime time;

  MessageModel({
    // required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.time,
  });

  int get timestamp => time.millisecondsSinceEpoch;

  // @override
  // String toString() {
  //   return 'Message{senderId: $senderId, receiverId: $receiverId, text: $text, time: $time}';
  // }

  @override
  String toString() {
    return 'Message{text: $text}';
  }

  Map<String, dynamic> toMap() {
    return {
      // 'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'time': time.millisecondsSinceEpoch,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      // messageId: map['messageId'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      text: map['text'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int),
    );
  }
}
