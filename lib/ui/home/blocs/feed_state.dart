import 'package:equatable/equatable.dart';

import '../../../domain/models/check_in.dart';
import '../../../domain/models/user.dart';

enum FeedStatus { initial, loading, loaded, empty, failure }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.checkIns = const [],
    this.hasCheckedIn = false,
    this.users = const {},
    this.allMemberIds = const {},
    this.errorMessage,
  });

  final FeedStatus status;
  final List<CheckIn> checkIns;

  /// Whether the current user has checked in today (gates feed access).
  final bool hasCheckedIn;

  /// Cached user profiles keyed by userId for display names/photos.
  final Map<String, User> users;

  /// All member IDs across all groups (for wall of shame).
  final Set<String> allMemberIds;

  final String? errorMessage;

  FeedState copyWith({
    FeedStatus? status,
    List<CheckIn>? checkIns,
    bool? hasCheckedIn,
    Map<String, User>? users,
    Set<String>? allMemberIds,
    String? errorMessage,
  }) {
    return FeedState(
      status: status ?? this.status,
      checkIns: checkIns ?? this.checkIns,
      hasCheckedIn: hasCheckedIn ?? this.hasCheckedIn,
      users: users ?? this.users,
      allMemberIds: allMemberIds ?? this.allMemberIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        checkIns,
        hasCheckedIn,
        users,
        allMemberIds,
        errorMessage,
      ];
}
