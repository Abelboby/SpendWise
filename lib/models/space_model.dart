import 'package:cloud_firestore/cloud_firestore.dart';

enum SpaceRole {
  owner,
  editor,
  viewer,
}

class SpaceMember {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final SpaceRole role;
  final DateTime joinedAt;

  SpaceMember({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  factory SpaceMember.fromMap(Map<String, dynamic> map) {
    return SpaceMember(
      userId: map['userId'] as String,
      displayName: map['displayName'] as String,
      photoUrl: map['photoUrl'] as String?,
      role: SpaceRole.values.firstWhere(
        (role) => role.toString().split('.').last == map['role'],
      ),
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
    );
  }
}

class SpaceModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final DateTime createdAt;
  final String inviteCode;
  final List<SpaceMember> members;
  final bool isPublic;

  SpaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.createdAt,
    required this.inviteCode,
    required this.members,
    required this.isPublic,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'inviteCode': inviteCode,
      'members': members.map((member) => member.toMap()).toList(),
      'isPublic': isPublic,
    };
  }

  factory SpaceModel.fromMap(Map<String, dynamic> map) {
    return SpaceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      ownerId: map['ownerId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      inviteCode: map['inviteCode'] as String,
      members: (map['members'] as List<dynamic>)
          .map((member) => SpaceMember.fromMap(member as Map<String, dynamic>))
          .toList(),
      isPublic: map['isPublic'] as bool,
    );
  }

  SpaceMember? getMember(String userId) {
    try {
      return members.firstWhere((member) => member.userId == userId);
    } catch (e) {
      return null;
    }
  }

  bool canEditExpenses(String userId) {
    final member = getMember(userId);
    return member != null &&
        (member.role == SpaceRole.owner || member.role == SpaceRole.editor);
  }

  bool canManageMembers(String userId) {
    final member = getMember(userId);
    return member != null &&
        (member.role == SpaceRole.owner || member.role == SpaceRole.editor);
  }

  bool isOwner(String userId) {
    return ownerId == userId;
  }
}
