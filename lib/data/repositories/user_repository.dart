import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/user.dart';

/// Exception thrown when a [UserRepository] operation fails.
class UserRepositoryException implements Exception {
  const UserRepositoryException([
    this.message = 'An unknown error occurred.',
  ]);

  final String message;

  factory UserRepositoryException.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const UserRepositoryException(
          'You do not have permission to perform this action.',
        );
      case 'not-found':
        return const UserRepositoryException(
          'The requested user was not found.',
        );
      default:
        return const UserRepositoryException();
    }
  }
}

/// Repository for managing user profile data in Firestore.
class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Watches a user document in real time.
  Stream<User?> watchUser(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return User.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  /// Fetches a user by ID.
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return User.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw UserRepositoryException.fromCode(e.code);
    }
  }

  /// Creates or updates a user document (merge).
  Future<void> saveUser(User user) async {
    try {
      await _usersCollection
          .doc(user.id)
          .set(user.toFirestore(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw UserRepositoryException.fromCode(e.code);
    }
  }

  /// Updates specific fields on a user document.
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(userId).update({
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw UserRepositoryException.fromCode(e.code);
    }
  }

  /// Adds a group ID to the user's groupIds list.
  Future<void> addGroupToUser(String userId, String groupId) async {
    try {
      await _usersCollection.doc(userId).set({
        'group_ids': FieldValue.arrayUnion([groupId]),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw UserRepositoryException.fromCode(e.code);
    }
  }

  /// Removes a group ID from the user's groupIds list.
  Future<void> removeGroupFromUser(String userId, String groupId) async {
    try {
      await _usersCollection.doc(userId).set({
        'group_ids': FieldValue.arrayRemove([groupId]),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw UserRepositoryException.fromCode(e.code);
    }
  }
}
