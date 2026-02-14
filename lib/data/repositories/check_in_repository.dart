import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/check_in.dart';
import '../../domain/models/reaction.dart';

/// Exception thrown when a [CheckInRepository] operation fails.
class CheckInRepositoryException implements Exception {
  const CheckInRepositoryException([
    this.message = 'An unknown error occurred.',
  ]);

  final String message;

  factory CheckInRepositoryException.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const CheckInRepositoryException(
          'You do not have permission to perform this action.',
        );
      case 'not-found':
        return const CheckInRepositoryException(
          'The requested check-in was not found.',
        );
      default:
        return const CheckInRepositoryException();
    }
  }
}

/// Repository for managing check-ins within groups.
///
/// Check-ins are stored as subcollections under groups:
/// `/groups/{groupId}/checkIns/{checkInId}`
class CheckInRepository {
  CheckInRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _checkInsCollection(
    String groupId,
  ) =>
      _firestore.collection('groups').doc(groupId).collection('checkIns');

  CollectionReference<Map<String, dynamic>> _reactionsCollection(
    String groupId,
    String checkInId,
  ) =>
      _checkInsCollection(groupId).doc(checkInId).collection('reactions');

  /// Watches today's check-ins for a group, ordered by creation time.
  Stream<List<CheckIn>> watchTodayCheckIns(String groupId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _checkInsCollection(groupId)
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CheckIn.fromFirestore(doc.data(), doc.id, groupId))
            .toList());
  }

  /// Fetches check-ins for a user across a specific group, for streak calculation.
  Future<List<CheckIn>> getUserCheckIns(
    String groupId,
    String userId, {
    int limit = 30,
  }) async {
    try {
      final snapshot = await _checkInsCollection(groupId)
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CheckIn.fromFirestore(doc.data(), doc.id, groupId))
          .toList();
    } on FirebaseException catch (e) {
      throw CheckInRepositoryException.fromCode(e.code);
    }
  }

  /// Creates a check-in. Returns the created check-in with its generated ID.
  Future<CheckIn> createCheckIn({
    required String groupId,
    required String userId,
    required String photoUrl,
    String? caption,
    String? effortEmoji,
  }) async {
    try {
      final checkIn = CheckIn(
        id: '',
        userId: userId,
        groupId: groupId,
        photoUrl: photoUrl,
        caption: caption,
        effortEmoji: effortEmoji,
      );

      final docRef = await _checkInsCollection(groupId).add(
        checkIn.toFirestore(),
      );

      return checkIn.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw CheckInRepositoryException.fromCode(e.code);
    }
  }

  /// Checks whether a user has already checked in to a group today.
  Future<bool> hasCheckedInToday(String groupId, String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await _checkInsCollection(groupId)
        .where('user_id', isEqualTo: userId)
        .where(
          'created_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Adds a reaction to a check-in.
  Future<Reaction> addReaction({
    required String groupId,
    required String checkInId,
    required String userId,
    required String emoji,
  }) async {
    try {
      final reaction = Reaction(
        id: '',
        userId: userId,
        emoji: emoji,
      );

      final docRef = await _reactionsCollection(groupId, checkInId).add(
        reaction.toFirestore(),
      );

      return reaction.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw CheckInRepositoryException.fromCode(e.code);
    }
  }

  /// Watches reactions for a specific check-in.
  Stream<List<Reaction>> watchReactions(String groupId, String checkInId) {
    return _reactionsCollection(groupId, checkInId)
        .orderBy('created_at')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reaction.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Calculates the current streak for a user based on their check-in history.
  ///
  /// Looks at consecutive days with at least one check-in across any group.
  Future<int> calculateStreak(
    String userId,
    List<String> groupIds,
  ) async {
    if (groupIds.isEmpty) return 0;

    // Gather check-in dates from all groups
    final allDates = <DateTime>{};
    for (final groupId in groupIds) {
      final checkIns = await getUserCheckIns(groupId, userId, limit: 90);
      for (final checkIn in checkIns) {
        if (checkIn.createdAt != null) {
          final d = checkIn.createdAt!;
          allDates.add(DateTime(d.year, d.month, d.day));
        }
      }
    }

    if (allDates.isEmpty) return 0;

    final sortedDates = allDates.toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    // Streak must include today or yesterday
    if (sortedDates.first != todayDate && sortedDates.first != yesterday) {
      return 0;
    }

    var streak = 1;
    for (var i = 0; i < sortedDates.length - 1; i++) {
      final diff = sortedDates[i].difference(sortedDates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
