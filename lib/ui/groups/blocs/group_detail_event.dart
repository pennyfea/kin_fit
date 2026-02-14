part of 'group_detail_bloc.dart';

sealed class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load a group and subscribe to its today's check-ins.
final class GroupDetailSubscriptionRequested extends GroupDetailEvent {
  const GroupDetailSubscriptionRequested(this.groupId);
  final String groupId;

  @override
  List<Object?> get props => [groupId];
}

/// Refresh group data (e.g. after a member joins).
final class GroupDetailRefreshRequested extends GroupDetailEvent {
  const GroupDetailRefreshRequested(this.groupId);
  final String groupId;

  @override
  List<Object?> get props => [groupId];
}
