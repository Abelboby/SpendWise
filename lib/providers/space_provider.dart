import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/space_model.dart';
import '../providers/auth_provider.dart';

class SpaceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _spacesCollection = 'spaces';
  List<SpaceModel> _spaces = [];
  bool _isLoading = false;
  String? _userId;
  final AuthProvider _authProvider;

  SpaceProvider(this._authProvider);

  List<SpaceModel> get spaces => _spaces;
  bool get isLoading => _isLoading;
  String get userId => _userId ?? '';

  void initialize(String userId) {
    _userId = userId;
    _listenToSpaces();
  }

  void _listenToSpaces() {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    // Listen to spaces where user is a member
    _firestore
        .collection(_spacesCollection)
        .where('memberIds', arrayContains: _userId)
        .snapshots()
        .listen((snapshot) {
      _spaces =
          snapshot.docs.map((doc) => SpaceModel.fromMap(doc.data())).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<SpaceModel> createSpace({
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    if (_userId == null) {
      throw Exception('User not initialized');
    }

    final String id = const Uuid().v4();
    final String inviteCode = const Uuid().v4().substring(0, 8).toUpperCase();

    final space = SpaceModel(
      id: id,
      name: name,
      description: description,
      ownerId: _userId!,
      createdAt: DateTime.now(),
      inviteCode: inviteCode,
      members: [
        SpaceMember(
          userId: _userId!,
          displayName: _authProvider.userName,
          photoUrl: _authProvider.userPhotoUrl,
          role: SpaceRole.owner,
          joinedAt: DateTime.now(),
        ),
      ],
      isPublic: isPublic,
    );

    final spaceData = space.toMap();
    spaceData['memberIds'] = [_userId];

    await _firestore.collection(_spacesCollection).doc(id).set(spaceData);

    return space;
  }

  Future<void> joinSpace(String inviteCode) async {
    if (_userId == null) {
      throw Exception('User not initialized');
    }

    final spaceDoc = await _firestore
        .collection(_spacesCollection)
        .where('inviteCode', isEqualTo: inviteCode)
        .get();

    if (spaceDoc.docs.isEmpty) {
      throw Exception('Invalid invite code');
    }

    final spaceData = spaceDoc.docs.first.data();
    final space = SpaceModel.fromMap(spaceData);

    // Check if user is already a member
    if (space.members.any((member) => member.userId == _userId)) {
      throw Exception('You are already a member of this space');
    }

    // Add user as a member with viewer role
    final updatedMembers = [
      ...space.members,
      SpaceMember(
        userId: _userId!,
        displayName: _authProvider.userName,
        photoUrl: _authProvider.userPhotoUrl,
        role: SpaceRole.viewer,
        joinedAt: DateTime.now(),
      ),
    ];

    await _firestore.collection(_spacesCollection).doc(space.id).update({
      'members': updatedMembers.map((member) => member.toMap()).toList(),
      'memberIds': FieldValue.arrayUnion([_userId]),
    });
  }

  Future<void> updateMemberRole(
    String spaceId,
    String memberId,
    SpaceRole newRole,
  ) async {
    if (_userId == null) {
      throw Exception('User not initialized');
    }

    final space = _spaces.firstWhere((space) => space.id == spaceId);

    // Only owner can update roles
    if (!space.isOwner(_userId!)) {
      throw Exception('Only the owner can update member roles');
    }

    // Cannot change owner's role
    if (memberId == space.ownerId) {
      throw Exception('Cannot change owner\'s role');
    }

    final updatedMembers = space.members.map((member) {
      if (member.userId == memberId) {
        return SpaceMember(
          userId: member.userId,
          displayName: member.displayName,
          photoUrl: member.photoUrl,
          role: newRole,
          joinedAt: member.joinedAt,
        );
      }
      return member;
    }).toList();

    await _firestore.collection(_spacesCollection).doc(spaceId).update({
      'members': updatedMembers.map((member) => member.toMap()).toList(),
    });
  }

  Future<void> leaveSpace(String spaceId) async {
    if (_userId == null) {
      throw Exception('User not initialized');
    }

    final space = _spaces.firstWhere((space) => space.id == spaceId);

    // Owner cannot leave, they must delete the space
    if (space.isOwner(_userId!)) {
      throw Exception('Owner cannot leave the space');
    }

    final updatedMembers =
        space.members.where((member) => member.userId != _userId).toList();

    await _firestore.collection(_spacesCollection).doc(spaceId).update({
      'members': updatedMembers.map((member) => member.toMap()).toList(),
      'memberIds': FieldValue.arrayRemove([_userId]),
    });
  }

  Future<void> deleteSpace(String spaceId) async {
    if (_userId == null) {
      throw Exception('User not initialized');
    }

    final space = _spaces.firstWhere((space) => space.id == spaceId);

    // Only owner can delete the space
    if (!space.isOwner(_userId!)) {
      throw Exception('Only the owner can delete the space');
    }

    await _firestore.collection(_spacesCollection).doc(spaceId).delete();
  }
}
