import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessageModel {
  // final String messageId;
  final String senderId;
  final String groupId;
  final String text;
  final DateTime time;
  final String? imageUrl;
  final String? blurImageHash;
  final String? videoUrl;
  final String? videoThumbnailUrl;
  final String? blurThumbnailHash;
  String? localImagePath;
  String? localThumbnailPath;
  String? localVideoPath;
  final List<String> readBy;

  GroupMessageModel({
    required this.senderId,
    required this.groupId,
    required this.text,
    required this.time,
    this.imageUrl,
    this.blurImageHash,
    this.videoUrl,
    this.videoThumbnailUrl,
    this.blurThumbnailHash,
    this.localImagePath,
    this.localVideoPath,
    this.localThumbnailPath,
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
    String? blurImageHash,
    String? videoUrl,
    String? videoThumbnailUrl,
    String? blurThumbnailHash,
    String? localThumbnailPath,
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
      blurImageHash: blurImageHash ?? this.blurImageHash,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
      blurThumbnailHash: blurThumbnailHash ?? this.blurThumbnailHash,
      localThumbnailPath: localThumbnailPath ?? this.localThumbnailPath,
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
      'blur_image_hash': blurImageHash ?? '',
      'video_url': videoUrl ?? '',
      'video_thumbnail_url': videoThumbnailUrl ?? '',
      'blur_thumbnail_hash': blurThumbnailHash ?? '',
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
      'blur_image_hash': blurImageHash ?? '',
      'video_url': videoUrl ?? '',
      'video_thumbnail_url': videoThumbnailUrl ?? '',
      'local_image_path': localImagePath ?? '',
      'local_video_path': localVideoPath ?? '',
      'blur_thumbnail_hash': blurThumbnailHash ?? '',
      'local_thumbnail_path': localThumbnailPath ?? '',
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
      blurImageHash:
          map['blur_image_hash'] == '' ? null : map['blur_image_hash'],
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
      blurThumbnailHash:
          map['blur_thumbnail_hash'] == '' ? null : map['blur_thumbnail_hash'],
      localThumbnailPath: map['local_thumbnail_path'] == ''
          ? null
          : map['local_thumbnail_path'],
      readBy:
          (map['read_by'] as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }
}
