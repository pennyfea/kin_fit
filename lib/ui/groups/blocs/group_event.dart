part of 'group_bloc.dart';

sealed class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

/// Subscribe to the current user's groups.
final class GroupsSubscriptionRequested extends GroupEvent {
  const GroupsSubscriptionRequested(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Create a new group.
final class GroupCreateRequested extends GroupEvent {
  const GroupCreateRequested({
    required this.name,
    required this.userId,
    this.maxMembers,
  });

  final String name;
  final String userId;
  final int? maxMembers;

  @override
  List<Object?> get props => [name, userId, maxMembers];
}

/// Join an existing group via invite code.
final class GroupJoinRequested extends GroupEvent {
  const GroupJoinRequested({
    required this.inviteCode,
    required this.userId,
  });

  final String inviteCode;
  final String userId;

  @override
  List<Object?> get props => [inviteCode, userId];
}

/// Leave a group.
final class GroupLeaveRequested extends GroupEvent {
  const GroupLeaveRequested({
    required this.groupId,
    required this.userId,
  });

  final String groupId;
  final String userId;

  @override
  List<Object?> get props => [groupId, userId];
}

/// Delete a group (creator only).
final class GroupDeleteRequested extends GroupEvent {
  const GroupDeleteRequested({
    required this.groupId,
    required this.userId,
  });

  final String groupId;
  final String userId;

  @override
  List<Object?> get props => [groupId, userId];
}
