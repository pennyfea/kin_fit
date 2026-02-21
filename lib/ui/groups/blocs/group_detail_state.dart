part of 'group_detail_bloc.dart';

enum GroupDetailStatus { initial, loading, loaded, failure }

class GroupDetailState extends Equatable {
  const GroupDetailState({
    this.status = GroupDetailStatus.initial,
    this.group,
    this.members = const [],
    this.todayCheckIns = const [],
    this.errorMessage,
  });

  final GroupDetailStatus status;
  final Group? group;
  final List<User> members;
  final List<CheckIn> todayCheckIns;
  final String? errorMessage;

  /// Set of user IDs who have checked in today.
  Set<String> get checkedInUserIds =>
      todayCheckIns.map((c) => c.userId).toSet();

  /// How many members have checked in today.
  int get checkedInCount => checkedInUserIds.length;

  GroupDetailState copyWith({
    GroupDetailStatus? status,
    Group? group,
    List<User>? members,
    List<CheckIn>? todayCheckIns,
    String? errorMessage,
  }) {
    return GroupDetailState(
      status: status ?? this.status,
      group: group ?? this.group,
      members: members ?? this.members,
      todayCheckIns: todayCheckIns ?? this.todayCheckIns,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, group, members, todayCheckIns, errorMessage];
}
