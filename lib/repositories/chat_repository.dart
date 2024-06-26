import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:blurhash_ffi/blurhash.dart';
import 'package:chat_box/model/message_model.dart';
import 'package:chat_box/services/local_media_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:http/http.dart' as http;

import '../config/onesignal_config.dart';

class ChatRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> sendMessage({
    required String chatKey,
    required MessageModel message,
    required String userName,
    File? image,
    File? video,
  }) async {
    if (video != null) {
      final url = await uploadVideo(
        chatKey: chatKey,
        video: video,
        id: message.timestamp.toString(),
      );
      if (url == null) {
        throw Exception('Cannot upload video!');
      } else {
        message = message.copyWith(videoUrl: url);
        final thumbnailFile = await generateThumbnail(chatKey, url);
        if (thumbnailFile != null) {
          final thumbnailUrl = await uploadThumbnail(
            chatKey: chatKey,
            thumbnail: thumbnailFile,
            id: message.timestamp.toString(),
          );
          if (thumbnailUrl != null) {
            final blurHash = await BlurhashFFI.encode(FileImage(thumbnailFile));
            message = message.copyWith(
              videoThumbnailUrl: thumbnailUrl,
              blurThumbnailHash: blurHash,
            );
          }
        }
      }
    }

    if (image != null) {
      final url = await uploadImage(
        chatKey: chatKey,
        image: image,
        id: message.timestamp.toString(),
      );
      if (url == null) {
        throw Exception('Cannot upload image!');
      } else {
        final blurHash = await BlurhashFFI.encode(FileImage(image));
        message = message.copyWith(imageUrl: url, blurImageHash: blurHash);
      }
    }

    await _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('messages')
        .doc(message.timestamp.toString())
        .set(message.toMapTime());

    String content = message.text;
    if (image != null) {
      content = '📷 Photo';
    }else if (video != null) {
      content = '📹 Video';
    }

    sendPushNotification(
      content: content,
      title: userName,
      message: message,
    );
  }

  Future<void> changeMessageToDelivered(
    String chatKey,
    String messageId,
  ) async {
    await _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('messages')
        .doc(messageId)
        .update(
      {
        'is_delivered': true,
      },
    );
  }

  Future<void> changeMessageToRead(String chatKey, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('messages')
        .doc(messageId)
        .update(
      {
        'is_read': true,
      },
    );
  }

  Future<void> changeTypingStatus(
    String chatKey,
    String userId,
    bool status,
  ) async {
    await _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('typing_status')
        .doc(userId)
        .set(
      {
        'is_typing': status,
      },
    );
  }

  Stream<bool> getTypingStatus(String chatKey, String userId) {
    return _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('typing_status')
        .doc(userId)
        .snapshots()
        .map((e) {
      final data = e.data();
      dev.log('Got snapshot: $data', name: 'Typing');
      if (data != null) {
        return data['is_typing'] as bool;
      } else {
        return false;
      }
    });
  }

  Future<String?> uploadImage({
    required String chatKey,
    required File image,
    required id,
  }) async {
    try {
      await _storage.ref('images/$chatKey/$id').putFile(image);
      final url = await _storage.ref('images/$chatKey/$id').getDownloadURL();
      return url;
    } catch (e) {
      dev.log('Got error: $e', name: 'Chat');
      return null;
    }
  }

  Future<String?> uploadVideo({
    required String chatKey,
    required File video,
    required id,
  }) async {
    try {
      await _storage.ref('videos/$chatKey/$id').putFile(
            video,
            SettableMetadata(contentType: 'video/mp4'),
          );
      final url = await _storage.ref('videos/$chatKey/$id').getDownloadURL();
      return url;
    } catch (e) {
      dev.log('Got error: $e', name: 'Chat');
      return null;
    }
  }

  Future<String?> uploadThumbnail({
    required String chatKey,
    required File thumbnail,
    required id,
  }) async {
    try {
      await _storage.ref('video_thumbnails/$chatKey/$id').putFile(thumbnail);
      final url = await _storage
          .ref(
            'video_thumbnails/$chatKey/$id',
          )
          .getDownloadURL();
      return url;
    } catch (e) {
      dev.log('Got error: $e', name: 'Chat');
      return null;
    }
  }

  Future<File?> generateThumbnail(String chatKey, String videoPath) async {
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 200,
      quality: 100,
    );

    if (thumbnail != null) {
      return File(thumbnail);
    } else {
      return null;
    }
  }

  Future<void> deleteMessage({
    required String chatKey,
    required MessageModel message,
  }) async {
    if (message.imageUrl != null) {
      dev.log('Deleting message images | localPath: ${message.localImagePath}',
          name: 'Image');
      if (message.localImagePath != null) {
        dev.log(
          'Deleting local image: ${message.localImagePath}',
          name: 'Image',
        );
        await LocalMediaService.deleteFile(message.localImagePath!);
      }
      await _storage.ref('images/$chatKey/${message.timestamp}').delete();
    }

    if (message.videoUrl != null) {
      if (message.localVideoPath != null) {
        await LocalMediaService.deleteFile(message.localVideoPath!);
      }
      await _storage.ref('videos/$chatKey/${message.timestamp}').delete();
      if (message.videoThumbnailUrl != null) {
        await _storage
            .ref('video_thumbnails/$chatKey/${message.timestamp}')
            .delete();
      }
    }

    await _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('messages')
        .doc(message.timestamp.toString())
        .delete();
  }

  Stream<List<MessageModel>> getMessages(String chatKey) {
    return _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map((e) => MessageModel.fromMap(e.data()))
            .toList();
      },
    );
  }

  Future<void> sendPushNotification({
    required String content,
    required String title,
    required MessageModel message,
  }) async {
    try {
      var url = Uri.parse(OneSignalConfig.oneSignalApiUrl);
      var client = http.Client();
      var headers = {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Basic ${OneSignalConfig.restApiKey}",
      };
      var body = {
        "app_id": OneSignalConfig.oneSignalAppId,
        "contents": {"en": content},
        // "included_segments": ["All"],
        "include_external_user_ids": [message.receiverId],
        "headings": {"en": title},
        "priority": "HIGH",
        "data" : {
          "sender_id" : message.senderId,
          "receiver_id" : message.receiverId,
        },
        // "small_icon":
        // 'https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png',
      };
      var response =
      await client.post(url, headers: headers, body: json.encode(body));
      if (response.statusCode == 200) {
        dev.log(
          "Notification is sent Successfully ${response.body} ",
          name: 'Notification',
        );
      } else {
        dev.log("Got errors : ${response.body}", name: "Notification");
      }
    } catch (e) {
      dev.log("Got errors : $e", name: "Notification");
    }
  }
}
