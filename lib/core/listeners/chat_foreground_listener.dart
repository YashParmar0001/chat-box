import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../utils/formatting_utils.dart';

const chatForegroundListener = listener;

void listener(OSNotificationWillDisplayEvent event, String chatKey) {
  final data = event.notification.additionalData;
  if (data != null) {
    final senderId = data['sender_id'];
    final receiverId = data['receiver_id'];
    final key = FormattingUtils.getChatKey(senderId, receiverId);
    if (key == chatKey) {
      event.preventDefault();
    }
  }
}