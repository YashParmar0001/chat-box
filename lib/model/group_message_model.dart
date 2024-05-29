import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessageModel {
  // final String messageId;
  final String senderId;
  final String groupId;
  final String text;
  final DateTime time;
  final String? imageUrl;
  final String? videoUrl;
  final String? videoThumbnailUrl;
  String? localImagePath;
  String? localVideoPath;
  final List<String> readBy;

  GroupMessageModel({
    required this.senderId,
    required this.groupId,
    required this.text,
    required this.time,
    this.imageUrl,
    this.videoUrl,
    this.videoThumbnailUrl,
    this.localImagePath,
    this.localVideoPath,
    this.readBy = const [],
  });

  int get timestamp => time.millisecondsSinceEpoch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMessageModel &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp); // &&
  // text == other.text &&
  // readBy.length == other.readBy.length);

  @override
  int get hashCode => timestamp.hashCode;

  // @override
  // String toString() {
  //   return 'GroupMessageModel{ senderId: $senderId, groupId: $groupId, text: $text, time: $time, imageUrl: $imageUrl, videoUrl: $videoUrl, videoThumbnailUrl: $videoThumbnailUrl, localImagePath: $localImagePath, localVideoPath: $localVideoPath,}';
  // }

  @override
  String toString() {
    return 'GroupMessage{ text: $text, localImage: $localImagePath, localVideo: $localVideoPath}';
  }

  GroupMessageModel copyWith({
    String? senderId,
    String? groupId,
    String? text,
    DateTime? time,
    String? imageUrl,
    String? videoUrl,
    String? videoThumbnailUrl,
    String? localImagePath,
    String? localVideoPath,
    List<String>? readBy,
  }) {
    return GroupMessageModel(
      senderId: senderId ?? this.senderId,
      groupId: groupId ?? this.groupId,
      text: text ?? this.text,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      localVideoPath: localVideoPath ?? this.localVideoPath,
      readBy: readBy ?? this.readBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'group_id': groupId,
      'content': text,
      'time': time.toUtc(),
      'image_url': imageUrl ?? '',
      'video_url': videoUrl ?? '',
      'video_thumbnail_url': videoThumbnailUrl ?? '',
      'read_by': readBy,
    };
  }

  Map<String, dynamic> toMapTimestamp() {
    return {
      'sender_id': senderId,
      'group_id': groupId,
      'content': text,
      'timestamp': timestamp,
      'image_url': imageUrl ?? '',
      'video_url': videoUrl ?? '',
      'video_thumbnail_url': videoThumbnailUrl ?? '',
      'local_image_path': localImagePath ?? '',
      'local_video_path': localVideoPath ?? '',
      'read_by': readBy.isEmpty ? null : readBy.join(','),
    };
  }

  factory GroupMessageModel.fromMap(Map<String, dynamic> map) {
    return GroupMessageModel(
      senderId: map['sender_id'] as String,
      groupId: map['group_id'] as String,
      text: map['content'] as String,
      time: (map['time'] != null)
          ? (map['time'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      imageUrl: map['image_url'] == '' ? null : map['image_url'],
      videoUrl: map['video_url'] == '' ? null : map['video_url'],
      videoThumbnailUrl:
          map['video_thumbnail_url'] == '' || map['video_thumbnail_url'] == null
              ? null
              : map['video_thumbnail_url'],
      localImagePath:
          map['local_image_path'] == '' || map['local_image_path'] == null
              ? null
              : map['local_image_path'],
      localVideoPath:
      map['local_video_path'] == '' || map['local_video_path'] == null
          ? null
          : map['local_video_path'],
      readBy:
          (map['read_by'] as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }
}
