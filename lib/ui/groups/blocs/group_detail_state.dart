part of 'group_detail_bloc.dart';

enum GroupDetailStatus { initial, loading, loaded, failure }

class GroupDetailState extends Equatable {
  const GroupDetailState({
    this.status = GroupDetailStatus.initial,
    this.group,
    this.todayCheckIns = const [],
    this.errorMessage,
  });

  final GroupDetailStatus status;
  final Group? group;
  final List<CheckIn> todayCheckIns;
  final String? errorMessage;

  GroupDetailState copyWith({
    GroupDetailStatus? status,
    Group? group,
    List<CheckIn>? todayCheckIns,
    String? errorMessage,
  }) {
    return GroupDetailState(
      status: status ?? this.status,
      group: group ?? this.group,
      todayCheckIns: todayCheckIns ?? this.todayCheckIns,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, group, todayCheckIns, errorMessage];
}
