import 'dart:io';
import 'dart:developer' as dev;

import 'package:blurhash_ffi/blurhash.dart';
import 'package:chat_box/model/group_message_model.dart';
import 'package:chat_box/model/group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../model/group_typing_status.dart';
import '../services/local_media_service.dart';

class GroupRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Stream<List<Group>> getGroups() {
    return _firestore.collection('groups').snapshots().map((e) {
      return e.docs.map((e) => Group.fromMap(e.data())).toList();
    });
  }

  Stream<List<GroupMessageModel>> getGroupMessages({required String groupId}) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .map((e) {
      return e.docs.map((e) => GroupMessageModel.fromMap(e.data())).toList();
    });
  }

  Stream<Group?> getGroup(String groupId) {
    return _firestore.collection('groups').doc(groupId).snapshots().map((e) {
      if (e.data() != null) {
        return Group.fromMap(e.data()!);
      } else {
        return null;
      }
    });
  }

  Future<void> createGroup({
    required Group group,
    File? groupProfile,
  }) async {
    final id = const Uuid().v4();
    group = group.copyWith(id: id);

    if (groupProfile != null) {
      await _storage.ref('group_profiles/$id').putFile(groupProfile);
      final url = await _storage.ref('group_profiles/$id').getDownloadURL();
      group = group.copyWith(groupProfilePicUrl: url);
    }

    await _firestore.collection('groups').doc(id).set(group.toMap());
  }

  Future<void> deleteGroup({required String groupId}) async {
    await _firestore.collection('groups').doc(groupId).delete();
  }

  Future<void> exitGroup({
    required String groupId,
    required String userId,
  }) async {
    await _firestore.collection('groups').doc(groupId).update({
      'member_ids': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> updateGroup({
    required String id,
    required String name,
    required String description,
    File? groupProfile,
  }) async {
    final data = {
      'name': name,
      'description': description,
    };
    if (groupProfile != null) {
      await _storage.ref('group_profiles/$id').putFile(groupProfile);
      final url = await _storage.ref('group_profiles/$id').getDownloadURL();
      data['group_profile_url'] = url;
    }

    await _firestore.collection('groups').doc(id).update(data);
  }

  Future<void> addGroupMembers({
    required String id,
    required List<String> members,
  }) async {
    await _firestore.collection('groups').doc(id).update({
      'member_ids': FieldValue.arrayUnion(members),
    });
  }

  Future<void> removeMember({
    required String id,
    required String member,
  }) async {
    await _firestore.collection('groups').doc(id).update({
      'member_ids': FieldValue.arrayRemove([member]),
    });
  }

  Future<GroupMessageModel> sendMessage({
    required String groupId,
    required GroupMessageModel message,
    File? image,
    File? video,
  }) async {
    if (video != null) {
      final url = await uploadVideo(
        groupId: groupId,
        video: video,
        id: message.timestamp.toString(),
      );
      if (url == null) {
        throw Exception('Cannot upload video!');
      } else {
        message = message.copyWith(videoUrl: url);
        final thumbnailFile = await generateThumbnail(groupId, url);
        if (thumbnailFile != null) {
          final thumbnailUrl = await uploadThumbnail(
            groupId: groupId,
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
        groupId: groupId,
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
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(message.timestamp.toString())
        .set(message.toMap());

    return message;
  }

  Future<String?> uploadImage({
    required String groupId,
    required File image,
    required id,
  }) async {
    try {
      await _storage.ref('group_images/$groupId/$id').putFile(image);
      final url =
          await _storage.ref('group_images/$groupId/$id').getDownloadURL();
      return url;
    } catch (e) {
      dev.log('Got error: $e', name: 'Chat');
      return null;
    }
  }

  Future<String?> uploadVideo({
    required String groupId,
    required File video,
    required id,
  }) async {
    try {
      await _storage.ref('group_videos/$groupId/$id').putFile(
            video,
            SettableMetadata(contentType: 'video/mp4'),
          );
      final url =
          await _storage.ref('group_videos/$groupId/$id').getDownloadURL();
      return url;
    } catch (e) {
      dev.log('Got error: $e', name: 'Group');
      return null;
    }
  }

  Future<String?> uploadThumbnail({
    required String groupId,
    required File thumbnail,
    required id,
  }) async {
    try {
      await _storage
          .ref('group_video_thumbnails/$groupId/$id')
          .putFile(thumbnail);
      final url = await _storage
          .ref(
            'group_video_thumbnails/$groupId/$id',
          )
          .getDownloadURL();
      return url;
    } catch (e) {
      dev.log('Got error: $e', name: 'Group');
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

  Future<void> changeTypingStatus(
    String groupId,
    String userId,
    bool status,
  ) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('typing_status')
        .doc(userId)
        .set({
      'is_typing': status,
    });
  }

  Stream<List<GroupTypingStatus>> getTypingStatus(String groupKey) {
    return _firestore
        .collection('groups')
        .doc(groupKey)
        .collection('typing_status')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((e) {
        return GroupTypingStatus.fromMap({
          'user_id': e.id,
          'is_typing': e.data()['is_typing'],
        });
      }).toList();
    });
  }

  Future<void> addReadBy({
    required String groupId,
    required String messageId,
    required String userId,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .update(
      {
        'read_by': FieldValue.arrayUnion([userId]),
      },
    );
  }

  Future<void> deleteMessage({
    required String groupId,
    required GroupMessageModel message,
  }) async {
    if (message.imageUrl != null) {
      if (message.localImagePath != null) {
        dev.log(
          'Deleting local image: ${message.localImagePath}',
          name: 'Image',
        );
        await LocalMediaService.deleteFile(message.localImagePath!);
      }
      await _storage.ref('group_images/$groupId/${message.timestamp}').delete();
    }

    if (message.videoUrl != null) {
      if (message.localVideoPath != null) {
        await LocalMediaService.deleteFile(message.localVideoPath!);
      }
      await _storage.ref('group_videos/$groupId/${message.timestamp}').delete();
      if (message.videoThumbnailUrl != null) {
        await _storage
            .ref('group_video_thumbnails/$groupId/${message.timestamp}')
            .delete();
      }
    }

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(message.timestamp.toString())
        .delete();
  }
}
