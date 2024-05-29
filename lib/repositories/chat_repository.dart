import 'dart:io';
import 'dart:developer' as dev;

import 'package:chat_box/model/message_model.dart';
import 'package:chat_box/services/local_media_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> sendMessage({
    required String chatKey,
    required MessageModel message,
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
            message = message.copyWith(videoThumbnailUrl: thumbnailUrl);
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
        message = message.copyWith(imageUrl: url);
      }
    }

    await _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('messages')
        .doc(message.timestamp.toString())
        .set(message.toMapTime());
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
}
