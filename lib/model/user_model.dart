class UserModel {
  final String email;
  final String name;
  final String bio;
  final String? profilePicUrl;
  final bool isOnline;
  final List<String> blockedUsers;

  const UserModel({
    required this.email,
    required this.name,
    required this.bio,
    this.profilePicUrl,
    required this.isOnline,
    this.blockedUsers = const [],
  });

  @override
  String toString() {
    return 'UserModel{ isOnline: $isOnline, name: $name, bio: $bio, profilePicUrl: $profilePicUrl, email: $email, blockedUsers: $blockedUsers}';
  }

  UserModel copyWith({
    String? email,
    String? name,
    String? bio,
    String? profilePicUrl,
    bool? isOnline,
    List<String>? blockedUsers,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      isOnline: isOnline ?? this.isOnline,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'profilePicUrl': profilePicUrl ?? '',
      'email': email,
      'is_online': isOnline,
      'blocked_users': blockedUsers,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      bio: map['bio'] as String,
      profilePicUrl:
          (map['profilePicUrl'] as String) == '' ? null : map['profilePicUrl'],
      email: map['email'] as String,
      isOnline: map['is_online'] as bool,
      blockedUsers: (map['blocked_users'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }
}
