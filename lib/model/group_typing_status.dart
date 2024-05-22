class GroupTypingStatus {
  final String userId;
  final bool isTyping;

  const GroupTypingStatus({
    required this.userId,
    required this.isTyping,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupTypingStatus &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          isTyping == other.isTyping);

  @override
  int get hashCode => userId.hashCode ^ isTyping.hashCode;

  @override
  String toString() {
    return 'GroupTypingStatus{ userId: $userId, isTyping: $isTyping,}';
  }

  GroupTypingStatus copyWith({
    String? userId,
    bool? isTyping,
  }) {
    return GroupTypingStatus(
      userId: userId ?? this.userId,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  factory GroupTypingStatus.fromMap(Map<String, dynamic> map) {
    return GroupTypingStatus(
      userId: map['user_id'] as String,
      isTyping: (map['is_typing'] ?? false) as bool,
    );
  }
}