import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  // final String messageId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime time;
  final String? imageUrl;
  final String? videoUrl;
  final String? videoThumbnailUrl;
  String? localImagePath;
  String? localVideoPath;

  MessageModel({
    // required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.time,
    this.imageUrl,
    this.videoUrl,
    this.videoThumbnailUrl,
    this.localImagePath,
    this.localVideoPath,
  });

  int get timestamp => time.millisecondsSinceEpoch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModel &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp;

  @override
  int get hashCode => timestamp.hashCode;

  // @override
  // String toString() {
  //   return 'Message{senderId: $senderId, receiverId: $receiverId, text: $text, time: $time}';
  // }

  @override
  String toString() {
    return 'Message{text: $text, videoPath: $localVideoPath, imagePath: $localImagePath}';
  }

  Map<String, dynamic> toMapTime() {
    return {
      // 'messageId': messageId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': text,
      'time': time.toUtc(),
      'image_url': imageUrl ?? '',
      // 'local_image_uri': localImagePath ?? '',
      'video_url': videoUrl ?? '',
      'video_thumbnail_url': videoThumbnailUrl ?? '',
    };
  }

  // For sql
  Map<String, dynamic> toMapTimestamp() {
    return {
      // 'messageId': messageId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': text,
      'timestamp': timestamp,
      'image_url': imageUrl,
      'local_image_uri': localImagePath,
      'video_url': videoUrl,
      'local_video_uri': localVideoPath,
      'video_thumbnail_url': videoThumbnailUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      // messageId: map['messageId'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      text: map['content'] as String,
      time: (map['time'] != null)
          ? (map['time'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      imageUrl: map['image_url'] == '' ? null : map['image_url'],
      videoUrl: map['video_url'] == '' ? null : map['video_url'],
      videoThumbnailUrl:
          map['video_thumbnail_url'] == '' ? null : map['video_thumbnail_url'],
      localImagePath:
          map['local_image_uri'] == '' ? null : map['local_image_uri'],
      localVideoPath:
          map['local_video_uri'] == '' ? null : map['local_video_uri'],
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
    String? localImagePath,
    String? localVideoPath,
  }) {
    return MessageModel(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      localVideoPath: localVideoPath ?? this.localVideoPath,
    );
  }
}
