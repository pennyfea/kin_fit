part of 'group_bloc.dart';

enum GroupStatus { initial, loading, loaded, empty, failure }

enum GroupActionStatus { idle, loading, success, failure }

class GroupState extends Equatable {
  const GroupState({
    this.status = GroupStatus.initial,
    this.groups = const [],
    this.actionStatus = GroupActionStatus.idle,
    this.actionError,
  });

  final GroupStatus status;
  final List<Group> groups;
  final GroupActionStatus actionStatus;
  final String? actionError;

  GroupState copyWith({
    GroupStatus? status,
    List<Group>? groups,
    GroupActionStatus? actionStatus,
    String? actionError,
  }) {
    return GroupState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [status, groups, actionStatus, actionError];
}
