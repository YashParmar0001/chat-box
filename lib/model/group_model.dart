import 'group_message_model.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String? groupProfilePicUrl;
  final List<String> memberIds;
  final String createdByUserId;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    this.groupProfilePicUrl,
    required this.memberIds,
    required this.createdByUserId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name && description == other.description &&
          groupProfilePicUrl == other.groupProfilePicUrl &&
          memberIds == other.memberIds &&
          createdByUserId == other.createdByUserId);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Group{ id: $id, name: $name, description: $description, createdBy: $createdByUserId, groupProfilePicUrl: $groupProfilePicUrl, memberIds: $memberIds,}';
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? groupProfilePicUrl,
    List<String>? memberIds,
    List<GroupMessageModel>? messages,
    String? createdByUserId,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      groupProfilePicUrl: groupProfilePicUrl ?? this.groupProfilePicUrl,
      memberIds: memberIds ?? this.memberIds,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description' : description,
      'group_profile_url': groupProfilePicUrl ?? '',
      'member_ids': memberIds,
      'created_by': createdByUserId,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      groupProfilePicUrl:
          map['group_profile_url'] == '' ? null : map['group_profile_url'],
      memberIds: (map['member_ids'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      createdByUserId: map['created_by'] as String,
    );
  }
}
