class MessageModel {
  // final String messageId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime time;
  final String? imageUrl;
  final String? videoUrl;
  final String? videoThumbnailUrl;

  MessageModel({
    // required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.time,
    this.imageUrl,
    this.videoUrl,
    this.videoThumbnailUrl,
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
      'imageUrl': imageUrl ?? '',
      'videoUrl': videoUrl ?? '',
      'thumbnailUrl' : videoThumbnailUrl ?? '',
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      // messageId: map['messageId'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      text: map['text'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int),
      imageUrl: map['imageUrl'] == '' ? null : map['imageUrl'],
      videoUrl: map['videoUrl'] == '' ? null : map['videoUrl'],
      videoThumbnailUrl: map['thumbnailUrl'] == '' ? null : map['thumbnailUrl'],
    );
  }

  MessageModel copyWith({
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? time,
    String? imageUrl,
    String? videoUrl,
    String? videoThumbnailUrl,
  }) {
    return MessageModel(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
    );
  }
}
