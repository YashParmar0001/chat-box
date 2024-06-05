import 'package:onesignal_flutter/onesignal_flutter.dart';

const groupChatForegroundListener = listener;

void listener(OSNotificationWillDisplayEvent event, String groupId) {
  final data = event.notification.additionalData;
  if (data != null) {
    final id = data['group_id'];
    if (id != null && id == groupId) {
      event.preventDefault();
    }
  }
}
