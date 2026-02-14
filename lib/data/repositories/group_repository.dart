import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/group.dart';

/// Exception thrown when a [GroupRepository] operation fails.
class GroupRepositoryException implements Exception {
  const GroupRepositoryException([
    this.message = 'An unknown error occurred.',
  ]);

  final String message;

  factory GroupRepositoryException.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const GroupRepositoryException(
          'You do not have permission to perform this action.',
        );
      case 'not-found':
        return const GroupRepositoryException(
          'The requested group was not found.',
        );
      default:
        return const GroupRepositoryException();
    }
  }
}

/// Repository for managing groups in Firestore.
class GroupRepository {
  GroupRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _groupsCollection =>
      _firestore.collection('groups');

  /// Watches all groups the user belongs to.
  Stream<List<Group>> watchUserGroups(String userId) {
    return _groupsCollection
        .where('member_ids', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Group.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Fetches a single group by ID.
  Future<Group?> getGroup(String groupId) async {
    try {
      final doc = await _groupsCollection.doc(groupId).get();
      if (!doc.exists || doc.data() == null) return null;
      return Group.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw GroupRepositoryException.fromCode(e.code);
    }
  }

  /// Looks up a group by its invite code.
  Future<Group?> getGroupByInviteCode(String inviteCode) async {
    try {
      final snapshot = await _groupsCollection
          .where('invite_code', isEqualTo: inviteCode)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return Group.fromFirestore(doc.data(), doc.id);
    } on FirebaseException catch (e) {
      throw GroupRepositoryException.fromCode(e.code);
    }
  }

  /// Creates a new group and returns it with the generated ID.
  Future<Group> createGroup({
    required String name,
    required String creatorId,
    String? emoji,
    int? maxMembers,
  }) async {
    try {
      final inviteCode = _generateInviteCode();
      final group = Group(
        id: '',
        name: name,
        emoji: emoji,
        inviteCode: inviteCode,
        creatorId: creatorId,
        memberIds: [creatorId],
        maxMembers: maxMembers,
        createdAt: DateTime.now(),
      );

      final docRef = await _groupsCollection.add(group.toFirestore());
      return group.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw GroupRepositoryException.fromCode(e.code);
    }
  }

  /// Adds a member to a group.
  Future<void> addMember(String groupId, String userId) async {
    try {
      await _groupsCollection.doc(groupId).update({
        'member_ids': FieldValue.arrayUnion([userId]),
      });
    } on FirebaseException catch (e) {
      throw GroupRepositoryException.fromCode(e.code);
    }
  }

  /// Removes a member from a group.
  Future<void> removeMember(String groupId, String userId) async {
    try {
      await _groupsCollection.doc(groupId).update({
        'member_ids': FieldValue.arrayRemove([userId]),
      });
    } on FirebaseException catch (e) {
      throw GroupRepositoryException.fromCode(e.code);
    }
  }

  /// Generates a 6-character alphanumeric invite code.
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
