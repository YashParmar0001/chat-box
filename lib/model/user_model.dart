class UserModel {
  final String email;
  final String name;
  final String bio;
  final String? profilePicUrl;
  final bool isOnline;

  const UserModel({
    required this.email,
    required this.name,
    required this.bio,
    this.profilePicUrl,
    required this.isOnline,
  });

  @override
  String toString() {
    return 'UserModel{ isOnline: $isOnline, name: $name, bio: $bio, profilePicUrl: $profilePicUrl, email: $email}';
  }

  UserModel copyWith({
    String? email,
    String? name,
    String? bio,
    String? profilePicUrl,
    bool? isOnline,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'profilePicUrl': profilePicUrl ?? '',
      'email': email,
      'is_online': isOnline,
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
    );
  }
}
