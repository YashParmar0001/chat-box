class UserModel {
  final String email;
  final String name;
  final String bio;
  final String? profilePicUrl;

  const UserModel({
    required this.email,
    required this.name,
    required this.bio,
    this.profilePicUrl,
  });

  @override
  String toString() {
    return 'UserModel{ name: $name, bio: $bio, profilePicUrl: $profilePicUrl, email: $email}';
  }

  UserModel copyWith({
    String? email,
    String? name,
    String? bio,
    String? profilePicUrl,
  }) {
    return UserModel(
      email: email ?? this.email,
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
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      bio: map['bio'] as String,
      profilePicUrl:
          (map['profilePicUrl'] as String) == '' ? null : map['profilePicUrl'],
      email: map['email'] as String,
    );
  }
}
