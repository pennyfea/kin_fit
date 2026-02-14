import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Represents a user in the application.
///
/// This is the domain model used throughout the app for representing user data.
@JsonSerializable(explicitToJson: true)
class User extends Equatable {
  /// Creates a new [User].
  const User({
    required this.id,
    this.firstName,
    this.lastName,
    this.photoUrl,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCheckInDate,
    this.groupIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// The unique identifier for this user.
  final String id;

  /// The user's first name.
  final String? firstName;

  /// The user's last name.
  final String? lastName;

  /// URL to the user's profile photo.
  final String? photoUrl;

  /// The user's current consecutive check-in streak.
  final int currentStreak;

  /// The user's longest ever consecutive check-in streak.
  final int longestStreak;

  /// The date of the user's most recent check-in.
  final DateTime? lastCheckInDate;

  /// IDs of groups this user belongs to.
  final List<String> groupIds;

  /// When the user account was created.
  final DateTime? createdAt;

  /// When the user account was last updated.
  final DateTime? updatedAt;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  /// The user's full name.
  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  /// Returns a display name for the user.
  ///
  /// Returns the full name if available, or 'Unknown User'.
  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    return 'Unknown User';
  }

  /// Whether the user has checked in today (based on local time).
  bool get hasCheckedInToday {
    if (lastCheckInDate == null) return false;
    final now = DateTime.now();
    return lastCheckInDate!.year == now.year &&
        lastCheckInDate!.month == now.month &&
        lastCheckInDate!.day == now.day;
  }

  /// Creates a [User] from JSON data.
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Converts this [User] to JSON.
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Creates a [User] from Firestore document data.
  ///
  /// The [documentId] is typically the Firebase Auth UID.
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      firstName: data['first_name'] as String?,
      lastName: data['last_name'] as String?,
      photoUrl: data['photo_url'] as String?,
      currentStreak: (data['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (data['longest_streak'] as num?)?.toInt() ?? 0,
      lastCheckInDate: (data['last_check_in_date'] as Timestamp?)?.toDate(),
      groupIds: List<String>.from(data['group_ids'] as List? ?? []),
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts this [User] to a map suitable for Firestore.
  ///
  /// Note: The document ID is not included in the map as it's stored separately.
  Map<String, dynamic> toFirestore() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_check_in_date': lastCheckInDate != null
          ? Timestamp.fromDate(lastCheckInDate!)
          : null,
      'group_ids': groupIds,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a copy of this [User] with the given fields replaced.
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? photoUrl,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCheckInDate,
    List<String>? groupIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      groupIds: groupIds ?? this.groupIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        photoUrl,
        currentStreak,
        longestStreak,
        lastCheckInDate,
        groupIds,
        createdAt,
        updatedAt,
      ];
}
