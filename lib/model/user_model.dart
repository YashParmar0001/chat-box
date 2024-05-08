class UserModel {
  final String name;
  final String bio;
  final String? profilePicUrl;

//<editor-fold desc="Data Methods">
  const UserModel({
    required this.name,
    required this.bio,
    this.profilePicUrl,
  });

  @override
  String toString() {
    return 'UserModel{ name: $name, bio: $bio, profilePicUrl: $profilePicUrl,}';
  }

  UserModel copyWith({
    String? name,
    String? bio,
    String? profilePicUrl,
  }) {
    return UserModel(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'profilePicUrl': profilePicUrl ?? '',
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      bio: map['bio'] as String,
      profilePicUrl:
          (map['profilePicUrl'] as String) == '' ? null : map['profilePicUrl'],
    );
  }

//</editor-fold>
}
