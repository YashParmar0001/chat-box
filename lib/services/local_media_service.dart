import 'dart:io';
import 'dart:developer' as dev;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class LocalMediaService {
  static Future<String?> getLocalPhotoPath({
    required String chatKey,
    required int messageId,
  }) async {
    final localFile = File(
      '${(await getApplicationDocumentsDirectory()).path}/images/$chatKey/'
      '$messageId.jpg',
    );

    if (await localFile.exists()) {
      return localFile.path;
    }

    return null;
  }

  static Future<String?> getLocalGroupPhotoPath({
    required String groupId,
    required int messageId,
  }) async {
    final localFile = File(
      '${(await getApplicationDocumentsDirectory()).path}/group_images/$groupId'
      '/$messageId.jpg',
    );

    if (await localFile.exists()) {
      return localFile.path;
    }

    return null;
  }

  static Future<String?> getLocalVideoPath({
    required String chatKey,
    required int messageId,
  }) async {
    final localFile = File(
      '${(await getApplicationDocumentsDirectory()).path}/videos/$chatKey/'
      '$messageId.mp4',
    );

    if (await localFile.exists()) {
      return localFile.path;
    }
    return null;
  }

  static Future<String?> getLocalGroupVideoThumbnailPath({
    required String groupId,
    required int messageId,
  }) async {
    final localFile = File(
      '${(await getApplicationDocumentsDirectory()).path}/group_video_thumbnails'
      '/$groupId/$messageId.jpg',
    );

    if (await localFile.exists()) {
      return localFile.path;
    }
    return null;
  }

  static Future<String?> getLocalGroupVideoPath({
    required String groupId,
    required int messageId,
  }) async {
    final localFile = File(
      '${(await getApplicationDocumentsDirectory()).path}/group_videos/$groupId'
      '$messageId.mp4',
    );

    if (await localFile.exists()) {
      return localFile.path;
    }
    return null;
  }

  static Future<String> downloadAndCachePhoto({
    required String chatKey,
    required int messageId,
  }) async {
    final path =
        '${(await getApplicationDocumentsDirectory()).path}/images/$chatKey/'
        '$messageId.jpg';
    final localFile = File(path);

    if (!await localFile.exists()) {
      final response = await FirebaseStorage.instance
          .ref(
            'images/$chatKey/$messageId',
          )
          .getData();
      if (response != null) {
        await localFile.parent.create(recursive: true);
        await localFile.writeAsBytes(response.toList());
        dev.log('Image stored: $messageId', name: 'LocalStorage');
      }
    }
    return path;
  }

  static Future<String> downloadAndCacheGroupPhoto({
    required String groupId,
    required int messageId,
  }) async {
    final path = '${(await getApplicationDocumentsDirectory()).path}/'
        'group_images/$groupId/$messageId.jpg';
    final localFile = File(path);

    if (!await localFile.exists()) {
      final response = await FirebaseStorage.instance
          .ref(
            'group_images/$groupId/$messageId',
          )
          .getData();
      if (response != null) {
        await localFile.parent.create(recursive: true);
        await localFile.writeAsBytes(response.toList());
        dev.log('Image stored: $messageId', name: 'LocalStorage');
      }
    }
    return path;
  }

  static Future<String> downloadAndCacheVideo({
    required String chatKey,
    required int messageId,
  }) async {
    final path =
        '${(await getApplicationDocumentsDirectory()).path}/videos/$chatKey/'
        '$messageId.mp4';
    final localFile = File(path);

    if (!await localFile.exists()) {
      final response = await FirebaseStorage.instance
          .ref(
            'videos/$chatKey/$messageId',
          )
          .getData();
      if (response != null) {
        await localFile.parent.create(recursive: true);
        await localFile.writeAsBytes(response.toList());
        dev.log('Video stored: $messageId', name: 'LocalStorage');
      }
    }
    return path;
  }

  static Future<String> downloadAndCacheGroupVideo({
    required String groupId,
    required int messageId,
  }) async {
    final path = '${(await getApplicationDocumentsDirectory()).path}/'
        'group_videos/$groupId/$messageId.mp4';
    final localFile = File(path);

    if (!await localFile.exists()) {
      final response = await FirebaseStorage.instance
          .ref(
            'group_videos/$groupId/$messageId',
          )
          .getData();
      if (response != null) {
        await localFile.parent.create(recursive: true);
        await localFile.writeAsBytes(response.toList());
        dev.log('Video stored: $messageId', name: 'LocalStorage');
      }
    }
    return path;
  }

  static Future<String> downloadAndCacheGroupVideoThumbnail({
    required String groupId,
    required int messageId,
  }) async {
    final path =
        '${(await getApplicationDocumentsDirectory()).path}/group_video_thumbnails/$groupId/$messageId.jpg';
    final localFile = File(path);

    if (!await localFile.exists()) {
      final response = await FirebaseStorage.instance
          .ref(
            'group_video_thumbnails/$groupId/$messageId',
          )
          .getData();

      if (response != null) {
        await localFile.parent.create(recursive: true);
        await localFile.writeAsBytes(response.toList());
        dev.log('Video thumbnail stored: $messageId', name: 'LocalStorage');
      }
    }
    return path;
  }

  static Future<void> deleteFile(String path) async {
    final localFile = File(path);

    if (await localFile.exists()) {
      localFile.delete();
    }
  }
}
